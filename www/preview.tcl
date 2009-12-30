# /packages/news/www/preview.tcl
ad_page_contract {
    This page previews the input from item-create or admin/revision-add
    
    @author stefan@arsdigita.com
    @creation-date 2000-12-18
    @cvs-id $Id$
    
} {
    {item_id:integer ""}
    action:notnull,trim
    publish_title:notnull,trim
    {publish_lead {}}
    {publish_body:allhtml,trim ""}
    publish_body.format:notnull
    {revision_log: ""}
    text_file:optional
    text_file.tmpfile:optional,tmpfile
    {publish_date:array ""}
    {archive_date:array ""}
    {permanent_p: "f"}
    publish_date_ansi:optional
    archive_date_ansi:optional
    imgfile:optional
    
} -errors {

    publish_title:notnull "[_ news.lt_Please_supply_the_tit]"
    publish_body:notnull "[_ news.lt_Please_supply_the_bod]"
    img_file_valid "[_ news.image_file_is_invalid]"

} -validate {

    check_revision_log -requires {action revision_log} {
	if { ![string match $action "News Item"] && [empty_string_p $revision_log]} {
	    ad_complain "[_ news.lt_You_must_supply_a_rev]"
	    return
	}
    }

    check_upload_one -requires {publish_body text_file.tmpfile text_file} {
	set file_size [file size ${text_file.tmpfile}]
	# !XOR condition (don't want to have both)
	if { [empty_string_p $publish_body] && $file_size==0 } {
	    ad_complain "[_ news.lt_Publish_body_is_missi]"
	    return
	} elseif { ![empty_string_p $publish_body] && $file_size > 0 } {
	    ad_complain "[_ news.You_can_either_upload_a_news_item_or_enter_text_in_the_box_provided_but_not_both]"
	    return
	}
    }

    max_size -requires {text_file.tmpfile text_file} {
	set b [file size ${text_file.tmpfile}]

	set b_max [expr 1000*[ad_parameter MaxFileSizeKb "news" 1024]]
	if { $b > $b_max } {
	    ad_complain "[_ news.lt_Your_document_is_larg] ([util_commify_number $b_max] [_ news.bytes])"
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

# only people with at least write-permission beyond this point
ad_require_permission $package_id news_create

set news_admin_p [ad_permission_p $package_id news_admin]

# Template parser treats publish_body.format as an array reference
set publish_format ${publish_body.format}

if { [string match $action "News Item"] } {
    set title "[_ news.Preview_news_item]"
} else {
    set title "[_ news.Preview] $action"
}
set context [list $title]

# deal with Dates, granularity is 'day'

# with news_admin privilege fill in publish and archive dates
if { $news_admin_p == 1 || [string equal [parameter::get -parameter ApprovalPolicy] "open"] } {

    if { [info exists publish_date(year)] && [info exists publish_date(month)] && [info exists publish_date(day)] } { 
	set publish_date_ansi "$publish_date(year)-$publish_date(month)-$publish_date(day)"
    } else {
	set publish_date_ansi ""
    }
    if { [info exists archive_date(year)] && [info exists archive_date(month)] && [info exists archive_date(day)] } { 
	set archive_date_ansi "$archive_date(year)-$archive_date(month)-$archive_date(day)"
    } else {
	set archive_date_ansi ""
    }

    if { ![template::util::date::validate $publish_date_ansi ""] } {
        set publish_date_pretty [lc_time_fmt $publish_date_ansi "%Q"]
    }
    if { ![template::util::date::validate $archive_date_ansi ""] } {
        set archive_date_pretty [lc_time_fmt $archive_date_ansi "%Q"]
    }

    if { [dt_interval_check $archive_date_ansi $publish_date_ansi] >= 0 } {
	ad_return_error "[_ news.Scheduling_Error]" \
            "[_ news.lt_The_archive_date_must]"
	return
    }

}

# if uploaded file, read it into publish_body and massage it
if {[info exists file_size]} {
    if { $file_size > 0 } {
        set fd [open ${text_file.tmpfile}]
        set publish_body [read $fd]
        close $fd
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
    if { ![empty_string_p $errors] } {
        ad_return_complaint 1 $errors
        ad_script_abort
    }
}

if { [string match $action "News Item"] } {

    # form variables for confirmation step

    set hidden_vars [export_form_vars publish_title publish_lead publish_body publish_body.format \
                         publish_date_ansi archive_date_ansi html_p permanent_p imgfile]
    set image_vars [export_form_vars publish_title publish_lead publish_body publish_body.format \
                        publish_date_ansi archive_date_ansi html_p \
                        permanent_p action]
    set form_action "<form method=post action=item-create-3 enctype=multipart/form-data class=\"inline-form\">"
    set edit_action "<form method=post action=item-create class=\"inline-form\">"

} else {

    # Form vars to carry through Confirmation Page
    set hidden_vars [export_form_vars item_id revision_log publish_title publish_lead \
                         publish_body publish_body.format publish_date_ansi archive_date_ansi \
                         permanent_p html_p imgfile]
    set image_vars [export_form_vars publish_title publish_lead publish_body publish_body.format \
                        publish_date_ansi archive_date_ansi html_p \
                        permanent_p action item_id revision_log]
    set form_action "<form method=post action=admin/revision-add-3 class=\"inline-form\">"
    set edit_action "<form method=post action=admin/revision-add class=\"inline-form\">"
}

# creator link 
set creator_name [db_string creator "
select first_names || ' ' || last_name 
from   cc_users 
where  user_id = :user_id"]
set creator_link "<a href=\"/shared/community-member?user_id=$user_id\">$creator_name</a>"

template::head::add_style -style ".news-item-preview { color: inherit; background-color: #eeeeee; margin: 1em 4em 1em 4em; padding: 1em; }" -media screen

ad_return_template
