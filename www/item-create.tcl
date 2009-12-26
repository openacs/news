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
    {publish_body {}}
    {publish_body.format {}}
    {publish_date_ansi {now}}
    {archive_date_ansi {}}
    {permanent_p {}}
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

set title "[_ news.Create_News_Item]"
set context [list $title]

set lc_format [lc_get formbuilder_date_format]

db_1row get_dates {}

if { $publish_date_ansi eq "" || $publish_date_ansi eq "now"} {
    set publish_date_ansi $date_today
}
if { $archive_date_ansi eq "" } {
    set archive_date_ansi $date_proj
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
    {publish_body:text(richtext),optional
        {label "[_ news.Body]"}
        {html {cols 60 rows 20}}
        {value "[list $publish_body ${publish_body.format}]"}}
    {text_file:text(file),optional
        {label "[_ news.or_upload_text_file]"}}
}

if { $immediate_approve_p } {
    ad_form -extend -name "news" -form {
        {publish_date:date,optional
            {label "[_ news.Release_Date]"}
            {value "[split $publish_date_ansi -]"}
            {format {$lc_format}}
        }
        {archive_date:date,optional
            {label "[_ news.Archive_Date]"}
            {value "[split $archive_date_ansi -]"}
            {format {$lc_format}}
        }
        {permanent_p:text(checkbox),optional
            {label "[_ news.never]"}
            {options {{"#news.show_it_permanently#" t}}}}
    }
}

ad_return_template
