# /packages/news/www/item-create.tcl

ad_page_contract {

    This page enables registered users and the news-admin
    to enter news releases.

    @author stefan@arsdigita.com
    @creation-date 2000-11-14
    @cvs-id $Id$

} {
    {publish_title {}}
    {publish_lead {}}
    {publish_body:allhtml {}}
    {publish_body.format {}}
    {publish_date:clock(%Y-%m-%d) {now}}
    {archive_date:clock(%Y-%m-%d) {}}
    {permanent_p:boolean {}}
}

# Authorization by news_create
set package_id [ad_conn package_id]
permission::require_permission -object_id $package_id -privilege news_create


# Furthermore, with news_admin privilege, items are approved immediately
# or if open approval policy
if { [permission::permission_p -object_id $package_id -privilege news_admin]
     || [parameter::get -parameter ApprovalPolicy -default "open"] eq "open"
 } {
    set immediate_approve_p 1
} else {
    set immediate_approve_p 0
}

set title "[_ news.Create_News_Item]"
set context [list $title]

set date_today [clock format [clock seconds] -format %Y-%m-%d]
set active_days [parameter::get -parameter ActiveDays -default 14]
set date_proj [clock format [clock scan "$active_days days"] -format %Y-%m-%d]

if { $publish_date eq "" || $publish_date eq "now"} {
    set publish_date $date_today
}
if { $archive_date eq "" } {
    set archive_date $date_proj
}

ad_form -name "news" -action "preview" -html {enctype "multipart/form-data"} -form {
    {action:text(hidden)
        {value "News Item"}}
    {publish_title:text(text)
        {label "[_ news.Title]"}
        {html {maxlength 400 size 61}}
        {value $publish_title}}
    {publish_lead:text(textarea),optional
        {label "[_ news.Lead]"}
        {html {cols 60 rows 3}}
        {value $publish_lead}}
    {publish_body:text(richtext)
        {label "[_ news.Body]"}
        {html {cols 60 rows 20}}
        {value "[list $publish_body ${publish_body.format}]"}}
}

if { $immediate_approve_p } {
    ad_form -extend -name "news" -form {
        {publish_date:h5date,optional
            {label "[_ news.Release_Date]"}
            {value $publish_date}
        }
        {archive_date:h5date,optional
            {label "[_ news.Archive_Date]"}
            {value $archive_date}
        }
        {permanent_p:text(checkbox),optional
            {label "[_ news.never]"}
            {options {{"#news.show_it_permanently#" t}}}}
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
