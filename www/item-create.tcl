# /packages/news/www/item-create.tcl

ad_page_contract {

    This page enables registered users and the news-admin 
    to enter news releases.

    @author stefan@arsdigita.com
    @creation-date 2000-11-14
    @cvs-id $Id$

} {
} -properties {

    title:onevalue
    context:onevalue
    publish_date_select:onevalue
    archive_date_select:onevalue
    immediate_approve_p:onevalue
    
}

# Authorization by news_create
set package_id [ad_conn package_id]
ad_require_permission $package_id news_create


# Furthermore, with news_admin privilege, items are approved immediately
# or if open approval policy 
if { [ad_permission_p $package_id news_admin] || [string equal "open" [ad_parameter ApprovalPolicy "news" "open"]] } {
    set immediate_approve_p 1
} else {
    set immediate_approve_p 0
}

set title "Create News Item"
set context [list $title]

set proj_archival_date [db_string week "select sysdate + [ad_parameter ActiveDays "news" 14] from dual"]

set publish_date_select [dt_widget_datetime -default now publish_date days]
set archive_date_select [dt_widget_datetime -default $proj_archival_date archive_date days]

ad_return_template
