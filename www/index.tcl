# /packages/news/www/index.tcl

ad_page_contract {

    Displays a hyperlinked list of published news titles either 'live' or 'archived'
    
    @author Stefan Deusch (stefan@arsdigita.com)
    @creation-date 2000-12-20
    @cvs-id $Id$

} {

   {start:integer "1"}
   {view:trim "live"}

} -properties {

   
    title:onevalue
    context:onevalue
    news_admin_p:onevalue
    news_create_p:onevalue 
    news_items:multirow
    allow_search_p:onevalue
    pagination_link:onevalue
    item_create_link:onevalue
    view_switch_link:onevalue
}


set package_id [ad_conn package_id]
ad_require_permission $package_id news_read


set context {} 


# switches for privilege-enabled links: admin for news_admin, submit for registered users
set news_admin_p [ad_permission_p $package_id news_admin]
set news_create_p [ad_permission_p $package_id news_create]


# switch for showing interface to site-wide-search for news
set allow_search_p [parameter::get -package_id $package_id -parameter ShowSearchInterfaceP  -default 1]
set search_url [site_node_closest_ancestor_package_url -package_key search -default ""]

# view switch in live | archived news
if { [string equal "live" $view] } {

    set title "News"
    set view_clause [db_map view_clause_live]

    if { [db_string archived_p "
    select decode(count(*),0,0,1) 
    from   news_items_approved
    where  publish_date < sysdate 
    and    archive_date < sysdate
    and    package_id = :package_id"]} {
	set view_switch_link "<a href=?view=archive>Show archived news</a>"
    } else { 
	set view_switch_link ""
    }
    
} else {
    
    set title "News Archive"
    set view_clause [db_map view_clause_archived]

    if { [db_string live_p "
    select decode(count(*),0,0,1) 
    from   news_items_approved
    where  publish_date < sysdate 
    and    (archive_date is null 
            or archive_date > sysdate) 
    and    package_id = :package_id"] } {
	set view_switch_link "<a href=?view=live>Show live news</a>"
    } else {
	set view_switch_link ""
    }    
}


set max_dspl [ad_parameter DisplayMax "news" 10]

# make list of approved news items, paging included
set count 0

# use template::query to limit result to allowed number of rows.

db_multirow news_items item_list "
select item_id,
       package_id,
       publish_title,
       publish_date
from   news_items_approved
where  $view_clause   
and    package_id = :package_id
order  by publish_date desc, item_id desc" {

    # this code block enables paging counter, no direct data manipulation 
    # alternatives are: <multiple ... -startrow=.. and -max_rows=.. if it worked
    # in Oracle (best for large number of rows): select no .. (select rownum as no.. (select...)))
    #                             
    incr count
    if { $count < $start } continue
    if { $count >= [expr $start + $max_dspl] } break
}


# make paging links
if { $count < [expr $start + $max_dspl] } {
    set next_start ""
} else {
    set next_start "<a href=index?start=[expr $start + $max_dspl]&view=$view>next<a/>"
}

if { $start == 1 } {
    set prev_start ""
} else {
    set prev_start "<a href=index?start=[expr $start - $max_dspl]&view=$view>prev</a>"
}

if { ![empty_string_p $next_start] && ![empty_string_p $prev_start] } {
    set divider " | "
} else {
    set divider ""
}

set pagination_link "$prev_start$divider$next_start"

ad_return_template
