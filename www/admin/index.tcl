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
    context_bar:onevalue
    view_link:onevalue
    hidden_vars:onevalue
    select_actions:onevalue
    item_list:multirow
}


# Authorization:restricted to admin as long as in /news/admin
set package_id [ad_conn package_id]


set view_slider {
    {view "News Items" published {
	{published "Published"   {where "status like 'published%'"}}
	{unapproved "Unapproved" {where "status = 'unapproved'"}}
	{approved "Approved"     {where "status like 'going live%'"}}
	{archived "Archived"     {where "status = 'archived'"}}
        {all "All"               {} }
    }}
}
set view_link [ad_dimensional $view_slider]
set view_option [ad_dimensional_sql $view_slider]

# define action on selected views, unapproved, archived, approved need restriction
switch $view {
    "unapproved" { set select_actions "<option value=\"publish\">Publish" }
    "archived"   { set select_actions "<option value=\"publish\">Re-Publish" }
    "approved"   { set select_actions "<option value=\"make permanent\">Make Permanent" }
    default      {
	set select_actions "
	<option value=\"archive now\" selected>Archive Now</option>
	<option value=\"archive next week\">Archive as of Next Week</option>
	<option value=\"archive next month\">Archive as of Next Month</option>
	<option value=\"make permanent\">Make Permanent"
    }
}



set title "Administration" 
set context_bar {}


# administrator sees all news items
db_multirow news_items itemlist "
select
    item_id,
    content_item.get_best_revision(item_id) as revision_id,
    content_revision.get_number(news_id) as revision_no,
    publish_title,
    html_p,
    publish_date,
    archive_date,
    creation_user,
    item_creator,
    package_id,
    status
from 
    news_items_live_or_submitted
where 
    package_id = :package_id    
    $view_option
order by item_id desc"


ad_return_template








