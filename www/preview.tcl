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
    text_file:optional
    text_file.tmpfile:optional,tmpfile
    {publish_date:array ""}
    {archive_date:array ""}
    {permanent_p: "f"}
   
} -errors {

    publish_title:notnull "[_ news.lt_Please_supply_the_tit]"
    publish_body:notnull "[_ news.lt_Please_supply_the_bod]"

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
	    ad_complain "[_ news.lt_Cant_upload_a_publica]"
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

if { [string match $action "News Item"] } {
    set title "[_ news.Preview_news_item]"
} else {
    set title "[_ news.Preview] $action"
}
set context [list $title]


# deal with Dates, granularity is 'day'

# with news_admin privilege fill in publish and archive dates
if { $news_admin_p == 1 } {
    
    set publish_date_ansi "$publish_date(year)-$publish_date(month)-$publish_date(day)"
    set archive_date_ansi "$archive_date(year)-$archive_date(month)-$archive_date(day)"

    set publish_date_pretty [lc_time_fmt $publish_date_ansi "%x"]
    set archive_date_pretty [lc_time_fmt $archive_date_ansi "%x"]
    
    if { [dt_interval_check $archive_date_ansi $publish_date_ansi] >= 0 } {
	ad_return_error "[_ news.Scheduling_Error]" \
		"[_ news.lt_The_archive_date_must]"
	return 
    }                     
}                                                


# if uploaded file, read it into publish_body and massage it

if {[info exists file_size]} {
    if { $file_size > 0 } {
        set publish_body [read [open ${text_file.tmpfile}]]
    }

    # close any open HTML tags in any case
    set  publish_body [util_close_html_tags $publish_body]
}


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
    set publish_body [ad_text_to_html -- $publish_body]
}

ad_return_template






