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

ad_proc news_pretty_status_key {
    {-publish_date:required}
    {-archive_date:required}
} {
    Given the the publish and archive date of a news item, return
    a human readable and localized string explaining the publish and archive status
    of the item. For example, "Published, scheduled to be archived in 5 days"

    @param publish_date The publish date on ANSI format
    @param archive_date The archive date on ANSI format

    @return The message key (package_key.message_key) for the text.

    @author Peter Marklund
} {
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

            if { [empty_string_p $archive_date] } { 
                # Not scheduled for archive
                # Message with vars n_days_until_publish
                set status_key news.going_live_no_archive
            } else {
                # Scheduled for archive
                # Message with vars n_days_until_publish, n_days_until_archive
                set status_key news.going_live_with_archive
            }
        } else {
            # Has already been published

            if { [empty_string_p $archive_date] } { 
                # Not scheduled for archive
                set status_key news.published_no_archive
            } elseif { $archive_date_seconds > $now_seconds } {                
                # Scheduled for archive
                # Message with vars n_days_until_archive
                set status_key news.published_scheduled_for_archive
            } else {
                # Already archived
                set status_key news.Archived
            }            
        }

    } else {
        # Item has no publish date - it's unapproved
        set status_key news.Unapproved
    }

    return $status_key
}
