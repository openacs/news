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




