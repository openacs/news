# /packages/news/tcl/news-procs.tcl

ad_library {

    Utility functions for News Application
    
    @author stefan@arsdigita.com
    @creation-date 12-14-00
    @cvs-id $Id$
}


# News specific db-API wrapper functions and interpreters

ad_proc news_items_archive { id_list when } { 
    
    immediately gives all news items in list id_list
    a status of archived as of ANSI date in when, i.e. when must be like 2000-10-11.
    
} {
   
    foreach id $id_list {	
	db_exec_plsql news_item_archive {
	    begin
	    news.archive(
	        item_id => :id,
	        archive_date => :when);
	    end;
	}
    }   

}


ad_proc news_items_make_permanent { id_list } {    

    immediately gives all news items in list id_list
    a status of permanently published

} {
    
    foreach id  $id_list {
	db_exec_plsql news_item_make_permanent {
	    begin
	        news.make_permanent(:id);
	    end;
	}	    
    }

}


ad_proc news_items_delete { id_list } {

    deletes all news items with news_id in id_list

} { 

    foreach id $id_list {
	db_exec_plsql news_item_delete {
	    begin
	        news.del(:id);
	    end;
	}
    }

}


ad_proc news_util_get_url {
    package_id
} {
    @author Robert Locke
} {

    set url_stub ""

    db_0or1row get_url_stub "
        select site_node__url(node_id) as url_stub
        from site_nodes
        where object_id=:package_id
    "

    return $url_stub

}


ad_proc news__datasource {
    object_id
} {
    We currently use the default content repository
    datasource proc.
    @author Robert Locke
} {

    return [content_search__datasource $object_id]

}


ad_proc news__url {
    object_id
} {
    @author Robert Locke
} {

    set package_id [db_string get_package_id {}]
    set url_stub [news_util_get_url $package_id]

    db_1row get_item_id "
        select item_id
        from cr_revisions
        where revision_id=:object_id
    "

    set url "${url_stub}item?item_id=$item_id"

    return $url
}

ad_proc news_pretty_status { 
    {-publish_date:required}
    {-archive_date:required}
    {-status:required}
} {
    Given the publish status of a news items  return a localization human readable
    sentence for the status.

    @param status Publish status short name. Valid values are returned
    by the plsql function news_status.

    @author Peter Marklund
} {
    array set news_status_keys {
        unapproved news.Unapproved
        going_live_no_archive news.going_live_no_archive
        going_live_with_archive news.going_live_with_archive
        published_no_archive news.published_no_archive
        published_with_archive news.published_scheduled_for_archive
        archived news.Archived
    }

    set now_seconds [clock scan now]
    set n_days_until_archive {}

    if { ![empty_string_p $archive_date] } { 
        set archive_date_seconds [clock scan $archive_date]

        if { $archive_date_seconds > $now_seconds } {
            # Scheduled for archive
            set n_days_until_archive [expr ($archive_date_seconds - $now_seconds) / 86400]
        }
    }

    if { ![empty_string_p $publish_date] } {
        # The item has been published or is scheduled to be published

        set publish_date_seconds [clock scan $publish_date]
        if { $publish_date_seconds > $now_seconds } {
            # Will be published in the future

            set n_days_until_publish [expr ($publish_date_seconds - $now_seconds) / 86400]
        }
    }

    # Message lookup may use vars n_days_until_archive and n_days_until_publis
    return [_ $news_status_keys($status)]
}


# register news search implementation
namespace eval news::sc {}

ad_proc -private news::sc::unregister_news_fts_impl {} {
    db_transaction {
        acs_sc::impl::delete -contract_name FtsContentProvider -impl_name news
    }
}

ad_proc -private news::sc::register_news_fts_impl {} {
    set spec {
        name "news"
        aliases {
            datasource news__datasource
            url news__url
        }
        contract_name FtsContentProvider
        owner news
    }

    acs_sc::impl::new_from_spec -spec $spec
}


ad_proc -public news__last_updated {
    package_id
} {
    
    Return the timestamp of the most recent item in this news instance
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-01-22
    
    @param package_id

    @return 
    
    @error 
} {
    return [db_string get_last_updated ""]
}

ad_proc -private news__rss_datasource {
    summary_context_id
} {
    This procedure implements the "datasource" operation of the 
    RssGenerationSubscriber service contract.  

    @author Dave Bauer (dave@thedesignexperience.org)
} {
    # TODO make limit a parameter
    set limit 15 

    set items [list]
    set counter 0
    set package_url [news_util_get_url $summary_context_id]
    db_foreach get_news_items {} {
        set entry_url [export_vars -base "[ad_url]${package_url}item" {item_id}]
        
        set content_as_text [ad_html_text_convert -from $mime_type -to text/plain $content]
        # for now, support only full content in feed
        set description $content_as_text

        # Always convert timestamp to GMT
        set entry_date_ansi [lc_time_tz_convert -from [lang::system::timezone] -to "Etc/GMT" -time_value $last_modified]
        set entry_timestamp "[clock format [clock scan $entry_date_ansi] -format "%a, %d %b %Y %H:%M:%S"] GMT"

        lappend items [list \
                           link $entry_url \
                           title $title \
                           description $description \
                           value $content_as_text \
                           timestamp $entry_timestamp]

        if { $counter == 0 } {
            set column_array(channel_lastBuildDate) $entry_timestamp
            incr counter
        }
    }
    set column_array(channel_title) "News"
    set column_array(channel_description) "News"
    set column_array(items) $items
    set column_array(channel_language) ""
    set column_array(channel_copyright) ""
    set column_array(channel_managingEditor) ""
    set column_array(channel_webMaster) ""
    set column_array(channel_rating) ""
    set column_array(channel_skipDays) ""
    set column_array(channel_skipHours) ""
    set column_array(version) 2.0
    set column_array(image) ""
    set column_array(channel_link) "$package_url"
    return [array get column_array]
}

ad_proc -private news_update_rss {
    -summary_context_id
} {
    
    Regenerate RSS feed
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-02-04
    
    @param summary_context_id

    @return 
    
    @error 
} {
    set subscr_id [rss_support::get_subscr_id \
                       -summary_context_id $summary_context_id \
                       -impl_name "news" \
                       -owner "news"]
    rss_gen_report $subscr_id
}

