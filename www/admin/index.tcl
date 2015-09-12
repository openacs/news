# /packages/news/www/admin/index.tcl

ad_page_contract {

    Display a list of news items summary for administration

    @author Stefan Deusch (stefan@arsdigita.com)
    @creation-date 2000-12-20
    @cvs-id $Id$

} {
  {orderby: "item_id"}
  {view: "published"}
  {column_names:array ""}
} -properties {
    title:onevalue
    context:onevalue
    view_link:onevalue
    hidden_vars:onevalue
    select_actions:onevalue
    item_list:multirow
}


# Authorization:restricted to admin as long as in /news/admin
set package_id [ad_conn package_id]


set view_slider [list \
    [list view "[_ news.News_Items]" published [list \
	[list published "[_ news.Published]" {where "status like 'published%'"}] \
	[list unapproved "[_ news.Unapproved]" {where "status = 'unapproved'"}] \
	[list approved "[_ news.Approved]" {where "status like 'going_live%'"}] \
	[list archived "[_ news.Archived]"     {where "status = 'archived'"}] \
        [list all "[_ news.All]"               {} ] \
    ]]
]
set view_link [ad_dimensional $view_slider]
set view_option [ad_dimensional_sql $view_slider]

# define action on selected views, unapproved, archived, approved need restriction
switch $view {
    "unapproved" { 
        set select_actions "<option value=\"publish\">[_ news.Publish]" 
    }
    "archived"   { 
        set select_actions "<option value=\"publish\">[_ news.Publish]" 
    }
    "approved"   { 
        set select_actions "<option value=\"make permanent\">[_ news.Make_Permanent]" 
    }
    default      {
	set select_actions "
	<option value=\"archive now\" selected>[_ news.Archive_Now]</option>
	<option value=\"archive next week\">[_ news.lt_Archive_as_of_Next_We]</option>
	<option value=\"archive next month\">[_ news.lt_Archive_as_of_Next_Mo]</option>
	<option value=\"make permanent\">[_ news.Make_Permanent]"
    }
}

set title "[_ news.Administration]" 
set context {}


# administrator sees all news items
db_multirow -extend { publish_date_pretty archive_date_pretty pretty_status } news_items itemlist {} {
    set publish_date_pretty [lc_time_fmt $publish_date_ansi "%x"]
    set archive_date_pretty [lc_time_fmt $archive_date_ansi "%x"]
    set pretty_status [news_pretty_status \
                           -publish_date $publish_date_ansi \
                           -archive_date $archive_date_ansi \
                           -status $status]
}

set rss_exists [rss_support::subscription_exists \
                    -summary_context_id $package_id \
                    -impl_name news]
set rss_feed_url [news_util_get_url $package_id]rss/rss.xml


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
