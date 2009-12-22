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

ad_proc test_file_type {
    imgsrc
} {
    Used in form validation to check that the uploaded file type really is
    what it's meant to be (invokes 'identify' on the file).

    @author Tom Ayles (tom@beatniq.net)
} {
    set mime_types [split \
                        [parameter::get -parameter ImageUploadTypes] \
                        {,}]
    if {[catch \
             {array set img_props [ImageMagick::identify $imgsrc]} \
             errmsg]} {
        return 0
    }
    set mime_type "image/[string tolower $img_props(format)]"
    if {[lsearch $mime_types $mime_type] < 0} {
        return 0
    }
    return 1
}

ad_proc news_revision_set_image_id {
    revision_id
    image_id
} {
    Associates an image with a revision of a news item.
    
    @author simon@simonbuckle.com
} {
    set creation_user [ad_conn user_id]
    set peeraddr [ad_conn peeraddr]

    db_exec_plsql set_image_rel {}
}

ad_proc news_revision_get_image_id {
    revision_id
} {
    Returns the image id if there is one associated with this image, empty string otherwise
    
    @author simon@simonbuckle.com
} {
    return [relation::get_object_two -object_id_one $revision_id -rel_type "relationship"]
}

ad_proc news_get_image_id {
    item_id
} {
    Retrieves the image associated with the given news item.

    @author Tom Ayles (tom@beatniq.net)
} {
    return [db_string img {} -default {}]
}

ad_proc news__datasource {
    object_id
} {
    

    @author Jeff Davis (davis@xarg.net)
} {
    db_1row get {
        select
        item_id,
        package_id,
        live_revision,
        publish_title,
        publish_lead,
        publish_format,
        publish_date,
        publish_body,
        creation_user,
        item_creator
        from news_items_live_or_submitted
        where item_id = :object_id
        or item_id = (select item_id from cr_revisions where revision_id = :object_id)}

    set url_stub [news_util_get_url $package_id]
    set url "[ad_url]${url_stub}item/$item_id"

    if {[empty_string_p $publish_lead]} {
        set publish_lead $publish_body
    }

    set content [template::adp_include /packages/news/www/news \
                     [list \
                          item_id $object_id \
                          publish_title $publish_title \
                          publish_title $publish_lead \
                          publish_body $publish_body \
                          publish_format $publish_format \
                          publish_image {} \
                          creator_link $item_creator ]]

    return [list \
                object_id $object_id \
                title $publish_title \
                content $content \
                mime text/html \
                keywords {} \
                storage_type text \
                syndication [list link $url \
                                 description $publish_lead \
                                 author $item_creator \
                                 category News \
                                 guid "[ad_url]/o/$item_id" \
                                 pubDate $publish_date \
                                ] \
               ]
}


ad_proc news__url {
    object_id
} {
    @author Robert Locke
} {
    db_1row get {}
    return "[ad_url][news_util_get_url $package_id]item/$item_id"
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

        set content_as_text [ad_html_text_convert -from $mime_type -to text/plain -- $content]
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
    set column_array(channel_title) "OpenACS News"
    set column_array(channel_description) "OpenACS News"
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
    set column_array(channel_link) "[ad_url]$package_url"
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

# add news notification
ad_proc -public news_notification_get_url {
       news_package_id
} {
       returns a full url to the news item.       
} { 
    return "[news_util_get_url $news_package_id]"
}

ad_proc -public news_do_notification {
    news_package_id
    news_id
} { 

    set package_id [ad_conn package_id]
    set node_id [ad_conn node_id]
    set instance_name [application_group::closest_ancestor_element  -include_self  -node_id $node_id  -element "instance_name"]

    # get the title and teaser for latest news item for the given package id
    if { [db_0or1row "get_news" "select item_id, publish_date, publish_title as title, publish_lead as lead, publish_body, publish_format from news_items_live_or_submitted where news_id =
 :news_id"] } {
        set new_content "$title\n\n$lead\n\n[ad_html_text_convert -from $publish_format -to text/plain -- $publish_body]"
        set html_content [ad_html_text_convert -from $publish_format -to text/html -- $publish_body]
        append new_content "\n\n[string repeat - 70]"
        append new_content "\n\n[parameter::get_from_package_key -package_key acs-kernel -parameter SystemURL][news_util_get_url $news_package_id]]item?item_id=$item_id \n\n"
        append html_content "<br><br><hr>[ad_html_text_convert "\n [parameter::get_from_package_key -package_key acs-kernel -parameter SystemURL][news_util_get_url $news_package_id]item?item_id=$item_id"]<br><br>"
    }

    # Notifies the users that requested notification for the specific news item

    notification::new \
        -type_id [notification::type::get_type_id -short_name one_news_item_notif] \
        -object_id $news_package_id \
        -notif_subject "\[$instance_name\] #news.Latest_News#" \
        -notif_text $new_content \
        -notif_html $html_content \
        -notif_date $publish_date

}
