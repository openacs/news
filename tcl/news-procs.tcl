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

    array set datasource [acs_sc_call FtsContentProvider \
	    datasource [list $object_id] content_revision]

    return [array get datasource]

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
