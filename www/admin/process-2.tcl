# /packages/news/www/admin/process-2.tcl

ad_page_contract {

    Confirmation page for News-admin to apply a drastical action to one or more
    news item(s), currently this is either 'delete','archive', or 'make permanent'
    The page is thereafter redirected to the administer page where the result is reflected.
    
    @author stefan@arsdigita.com
    @creation-date 2000-12-20
    @cvs-id $Id$

} {
 
  n_items:notnull
  action:notnull,trim

} -errors {

    n_items:notnull "[_ news.lt_Please_check_the_item]"

}


switch -- $action {
    
    delete {
	news_items_delete $n_items
    }
    
    "archive now" {
	set when [db_string archive_now {}]
	news_items_archive $n_items $when
    }
    
    "archive next week" {
	set when [db_string archive_next_week {}]
	news_items_archive $n_items $when
    }

    "archive next month" {
	set when [db_string archive_next_month {}]
	news_items_archive $n_items $when
    }

    "make permanent" {
	news_items_make_permanent $n_items
    }

}

ad_returnredirect ""

























































































# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
