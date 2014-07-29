# /packages/news/www/admin/item.tcl

ad_page_contract {

    This one-item page is the UI for the News Administrator
    You can view one news item with all its revisions. 
    A new revision can be added which is the way to edit a news item.
   
    @author stefan@arsdigita.com
    @creation-date 2000-12-20
    @cvs-id $Id$

} {

    item_id:naturalnum,notnull

} -properties {

    title:onevalue
    context:onevalue
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
set return_url [export_vars -base "item" {item_id}]


# get revisions of the item
set counter 1
db_multirow -extend {revision revision_url set_active_url active_revision author_url action action_url} item item_revs_list {} {

    set revision $counter
    set revision_url [export_vars -base "revision" {item_id revision_id}]

    if { $item_live_revision_id eq $revision_id } {
        set active_revision [_ news.active]
        set set_active_url ""
    } else {
        set active_revision [_ news.make_active]
        set set_active_url [export_vars -base "revision-set-active" {item_id {new_rev_id $revision_id}}]
    }

    set author_url [export_vars -base "/shared/community-member" {{user_id $creation_user}}]

    if { $approval_needed_p } {
        set action_url [export_vars -base "approve" {return_url revision_id {n_items $item_id}}]
        set action [_ news.approve]
    } else {
        set action_url [export_vars -base "revoke" {revision_id item_id}]
        set action [_ news.revoke]
    }

    incr counter
}

template::multirow foreach item {
    set revision [expr { $counter - $revision }]
} 

template::list::create -name news_items -multirow item -actions [list [_ news.Add_a_new_revision] [export_vars -base "revision-add" {item_id}] [_ news.Add_a_new_revision]] -elements {

    revision {
        label "[_ news.Revision]"
        link_url_col revision_url
    }
    active_revision {
        label "[_ news.Active_Revision]"
        link_url_col set_active_url
    }
    publish_title {
        label "[_ news.Title]"
        link_url_col revision_url
    }
    item_creator {
        label "[_ news.Author]"
        link_url_col author_url
    }
    log_entry {
        label "[_ news.Log_Entry]"
    }
    status {
        label "[_ news.Status]"
    }
    action {
        label "[_ acs-kernel.common_Actions]"
        link_url_col action_url
    }
}

ad_return_template
