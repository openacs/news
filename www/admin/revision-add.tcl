# /packages/news/www/admin/revision-add.tcl

ad_page_contract {
    
    This page serves as UI to add a new revision of a news item
    By default, the fields of the active_revision are filled in.
    Currently only News Admin can do this, not the original submitter though.

    @author stefan@arsdigita.com
    @creation-date 2000-12-20
    @cvs-id $Id$
    
} {

    item_id:integer,notnull
    
} -properties {

    title:onevalue
    context:onevalue
    publish_date:onevalue
    publish_date_desc:onevalue
    publish_title:onevalue
    publish_body:onevalue
    html_p:onevalue
    archive_date:onevalue
    never_checkbox:onevalue
    hidden_vars:onevalue
}

db_1row news_item_info {
    select
        item_name,
        creator_id,
        item_creator
    from
        news_item_full_active
    where item_id = :item_id
}

set title "[_ news.lt_One_Item_-_add_revisi]"
set context [list $title]

# get active revision of news item
db_1row item  "
select
    item_id, 
    package_id,   
    revision_id,
    publish_title,
    html_p,
    publish_date,
    NVL(archive_date, sysdate+[ad_parameter ActiveDays "news" 14]) as archive_date,
    status
from   
    news_item_full_active    
where  
    item_id = :item_id"

# workaround to get blobs with >4000 chars into a var, content.blob_to_string fails! 
# when this'll work, you get publish_body by selecting 'publish_body' directly from above view
#
set get_content [db_map get_content]

if {![string match $get_content ""]} {
    set publish_body [db_string get_content "select  content
    from    cr_revisions
    where   revision_id = :revision_id"]
}


set never_checkbox "<input type=checkbox name=permanent_p value=t"
if {[string equal $status "permanent"]} {
    append never_checkbox "checked"
}
append never_checkbox ">"


set publish_date_select [dt_widget_datetime -default $publish_date publish_date days]
set archive_date_select [dt_widget_datetime -default $archive_date archive_date days]


set action "[_ news.Revision]"
set hidden_vars [export_form_vars item_id action]


ad_return_template






