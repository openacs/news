# /packages/news/www/admin/item.tcl

ad_page_contract {

    This one-item page is the UI for the News Administrator
    You can view one news item with all its revisions. 
    A new revision can be added which is the way to edit a news item.
   
    @author stefan@arsdigita.com
    @creation-date 2000-12-20
    @cvs-id $Id$

} {

    item_id:integer,notnull

} -properties {

    title:onevalue
    context:onevalue
    hidden_vars:onevalue
    item_name:onevalue
    item_creator:onevalue
    item_creation_ip:onevalue
    item_creation_date:onevalue
    item_live_revision_id:onevalue
    status:onevalue
    approval_needed_p:onevalue
    item:multirow
}


set package_id [ad_conn package_id]


set title "[_ news.One_Item]"
set context [list $title]


set hidden_vars [export_form_vars item_id return_url]


# get revisions of the item
db_multirow item item_revs_list {
select 
    item_id,
    revision_id,
    live_revision as item_live_revision_id,
    publish_title,
    log_entry,
    package_id,
    approval_needed_p,
    creation_user,
    item_creator,
    status
from 
    news_item_revisions
where 
    item_id = :item_id
order by revision_id desc
} 

ad_return_template







