# /packages/news/www/admin/process-2.tcl

ad_page_contract {

    Confirmation page for News-admin to apply a drastical action to one or more
    news item(s), currently this is either 'delete','archive', or 'make permanent'
    The page is thereafter redirected to the administer page where the result is reflected.
    
    @author stefan@arsdigita.com
    @creation-date 2000-12-20
    @$Id$

} {
 
  n_items:notnull
  action:notnull,trim

} -errors {

    n_items:notnull "Please check the items you want to process."

}


switch $action {
    
    delete {
	news_items_delete $n_items
    }
    
    "archive now" {
	set when [db_string archive_now "select sysdate from dual"]
	news_items_archive $n_items $when
    }
    
    "archive next week" {
	set when [db_string archive_next_week "select next_day(sysdate,'Monday') from dual"]
	news_items_archive $n_items $when
    }

    "archive next month" {
	set when [db_string archive_next_month "select last_day(sysdate)+1 from dual"]
	news_items_archive $n_items $when
    }

    "make permanent" {
	news_items_make_permanent $n_items
    }

}

ad_returnredirect ""


















































































