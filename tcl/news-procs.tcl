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
	        news.delete(:id);
	    end;
	}
    }

}


ad_proc news_util_get_url {
    package_key
} {
    @author Robert Locke
} {

    set package_id [apm_package_id_from_key $package_key]

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

    set url_stub [news_util_get_url news]

    db_1row get_item_id "
        select item_id
        from cr_revisions
        where revision_id=:object_id
    "

    set url "${url_stub}item?item_id=$item_id"

    return $url
}
