ad_page_contract {
    This page previews the input from item-create or admin/revision-add

    @author stefan@arsdigita.com
    @creation-date 2000-12-18
    @cvs-id $Id$

} {
    {item_id:naturalnum ""}
    action:notnull,trim
    publish_title:notnull,trim
    {publish_lead {}}
    {publish_body:allhtml,trim ""}
    publish_body.format:path,notnull
    {revision_log ""}
    {publish_date:clock(%Y-%m-%d) ""}
    {archive_date:clock(%Y-%m-%d) ""}
    {permanent_p:boolean,notnull "f"}
    imgfile:optional

} -errors {

    publish_title:notnull "[_ news.lt_Please_supply_the_tit]"
    publish_body:notnull "[_ news.lt_Please_supply_the_bod]"
    img_file_valid "[_ news.image_file_is_invalid]"

} -validate {

    check_revision_log -requires {action revision_log} {
        if { $action eq "News Item" && $revision_log eq ""} {
            ad_complain "[_ news.lt_You_must_supply_a_rev]"
            return
        }
    }

}  -properties {

    title:onevalue
    context:onevalue
    publish_title:onevalue
    publish_lead:onevalue
    publish_body:onevalue
    publish_format:onevalue
    publish_location:onevalue
    hidden_vars:onevalue
    permanent_p:onevalue
    html_p:onevalue
    news_admin_p:onevalue
    form_action:onevalue
    image_url:onevalue
    edit_action:onevalue
}

set user_id [auth::require_login]
set package_id [ad_conn package_id]

#
# Only people with news_create permission beyond this point
#
permission::require_permission \
    -object_id $package_id \
    -privilege news_create

set news_admin_p [permission::permission_p \
                      -object_id $package_id \
                      -privilege news_admin]

# Template parser treats publish_body.format as an array reference
set publish_format ${publish_body.format}

if { $action eq "News Item" } {
    set title [_ news.Preview_news_item]
} else {
    set title "[_ news.Preview] $action"
}
set context [list $title]

# deal with Dates, granularity is 'day'

# with news_admin privilege fill in publish and archive dates
if { $news_admin_p || [parameter::get -parameter ApprovalPolicy] eq "open" } {

    set publish_date_pretty [lc_time_fmt $publish_date "%Q"]
    set archive_date_pretty [lc_time_fmt $archive_date "%Q"]

    if { [dt_interval_check $archive_date $publish_date] >= 0 } {
        ad_return_error \
            [_ news.Scheduling_Error] \
            [_ news.lt_The_archive_date_must]
        ad_script_abort
    }
}

if { ${publish_body.format} eq "text/html" || ${publish_body.format} eq "text/enhanced" } {

    # close any open HTML tags in any case
    set  publish_body [util_close_html_tags $publish_body]

    # Note: this is the *only* check against disallowed HTML tags in the
    # news posting system.  Currently, each path for creating or revising
    # a news items passes through this preview script, so it's safe.  But if
    # in the future someone modifies the package to, say, use self-submit forms
    # the check will need to be added as a validator for each ad_form call.

    set errors [ad_html_security_check $publish_body]
    if { $errors ne "" } {
        ad_return_complaint 1 $errors
        ad_script_abort
    }
}

if { $action eq "News Item" } {

    # form variables for confirmation step

    set hidden_vars [export_vars -form {
        publish_title publish_lead publish_body publish_body.format
        publish_date archive_date html_p permanent_p imgfile
    }]
    set image_vars [export_vars -form {
        publish_title publish_lead publish_body publish_body.format
        publish_date archive_date html_p permanent_p action
    }]
    set form_action "<form method='post' action='item-create-3' enctype='multipart/form-data' class='inline-form'>"
    set edit_action "<form method='post' action='item-create' class='inline-form'>"

} else {

    # Form vars to carry through Confirmation Page
    set hidden_vars [export_vars -form {
        item_id revision_log publish_title publish_lead publish_body publish_body.format
        publish_date archive_date permanent_p html_p imgfile
    }]
    set image_vars [export_vars -form {
        publish_title publish_lead publish_body publish_body.format
        publish_date archive_date html_p permanent_p action item_id revision_log
    }]
    set form_action "<form method='post' action='admin/revision-add-3' class='inline-form'>"
    set edit_action "<form method='post' action='admin/revision-add' class='inline-form'>"
}

# creator link
set creator_name [db_string creator {
    select first_names || ' ' || last_name
    from   cc_users
    where  user_id = :user_id
}]
set creator_link "<a href='/shared/community-member?user_id=$user_id'>[ns_quotehtml $creator_name]</a>"

template::head::add_style \
    -style ".news-item-preview { color: inherit; background-color: #eeeeee; margin: 1em 4em 1em 4em; padding: 1em; }" \
    -media screen

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
