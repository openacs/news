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
    {publish_body:allhtml,trim ""}
    {revision_log: ""}
    html_p:notnull,trim
    {text_file:trim ""}
    {text_file.tmpfile:tmpfile ""}
    {publish_date:array ""}
    {archive_date:array ""}
    {permanent_p: "f"}
   
} -errors {

    publish_title:notnull "Please supply the title of the news item."
    publish_body:notnull "Please supply the body of the news item."

} -validate {

    content_html -requires {publish_body html_p} {
        if { [string equal $html_p "t"] } {
            set complaint [ad_check_for_naughty_html $publish_body]
            if { ![empty_string_p $complaint] } {
                ad_complain $complaint
		return
            }
        }
    }
    
    check_revision_log -requires {action revision_log} {
	if { ![string match $action "News Item"] && [empty_string_p $revision_log]} {
	    ad_complain "You must supply a revision log information."
	    return
	}
    }

    check_upload_one -requires {publish_body text_file} {
	set file_size [file size ${text_file.tmpfile}]
	# !XOR condition (don't want to have both)
	if { [empty_string_p $publish_body] && $file_size==0 } {
	    ad_complain "Publish body is missing. Either upload file or enter something in the textarea."
	    return
	} elseif { ![empty_string_p $publish_body] && $file_size > 0 } {
	    ad_complain "Can't upload a publication in the text-field and a non-empty file."
	    return
	} 
    }

    max_size -requires {text_file} {
	set b [file size ${text_file.tmpfile}]
	
	set b_max [expr 1000*[ad_parameter MaxFileSizeKb "news" 1024]]
	if { $b > $b_max } {
	    ad_complain "Your Word document is larger than the maximum size allowed ([util_commify_number $b_max] bytes)"
	    return
	}
    }


}  -properties {
    
    title:onevalue
    context_bar:onevalue
    publish_title:onevalue
    publish_body:onevalue
    publish_location:onevalue
    hidden_vars:onevalue
    permanent_p:onevalue
    html_p:onevalue
    news_admin_p:onevalue 
    form_action:onevalue
}


set package_id [ad_conn package_id]


# only people with at least write-permission beyond this point
ad_require_permission $package_id news_create


set news_admin_p [ad_permission_p $package_id news_admin]

set title "Preview $action"
set context_bar [list $title]


# deal with Dates, granularity is 'day'

# with news_admin privilege fill in publish and archive dates
if { $news_admin_p == 1 } {
    
    set publish_date_ansi "$publish_date(year)-$publish_date(month)-$publish_date(day)"
    set archive_date_ansi "$archive_date(year)-$archive_date(month)-$archive_date(day)"    
    
    if { [dt_interval_check $archive_date_ansi $publish_date_ansi] >= 0 } {
	ad_return_error "Scheduling Error" \
		"The archive date must be AFTER the release date."
	return 
    }                     
}                                                


# if uploaded file, read it into publish_body and massage it
if { $file_size > 0 } {
    set publish_body [read [open ${text_file.tmpfile}]]
}

# close any open HTML tags in any case
set  publish_body [util_close_html_tags $publish_body]


if { [string match $action "News Item"] } {

    # form variables for confirmation step
    set hidden_vars [export_form_vars publish_title publish_body \
	    publish_date_ansi archive_date_ansi html_p permanent_p]
    set form_action "<form method=post action=item-create-3>"
    
} else {
    
    # Form vars to carry through Confirmation Page
    set hidden_vars [export_form_vars item_id revision_log publish_title publish_body \
	    publish_date_ansi archive_date_ansi permanent_p html_p]
    set form_action "<form method=post action=admin/revision-add-3>"

}

# creator link 
set user_id [ad_conn "user_id"]
set creator_name [db_string creator "
select first_names || ' ' || last_name 
from   cc_users 
where  user_id = :user_id"]
set creator_link "<a href=\"/shared/community-member?user_id=$user_id\">$creator_name</a>"

if { [info exists html_p] && [string match $html_p "f"] } {
    set publish_body "<pre>[ad_quotehtml $publish_body]</pre>"
}

ad_return_template

