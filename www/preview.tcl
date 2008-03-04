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
    {revision_log: ""}
    html_p:notnull,trim
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

    content_html -requires {publish_body html_p} {
        if { [string equal $html_p "t"] } {
            set complaint [ad_html_security_check $publish_body]
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

if { [string match $action "News Item"] } {
    set title "[_ news.Preview_news_item]"
} else {
    set title "[_ news.Preview] $action"
}
set context [list $title]

if {[info exists imgfile]} {
    unset imgfile
}

# create a new revision of the image if we've come back from the image-choose
# page and we are revising
if {[exists_and_not_null item_id] && [info exists imgfile]} {

    # check user has admin privileges (we can only get here from
    # admin/revision-add, so all legit users will have admin on package)
    permission::require_permission \
        -object_id [ad_conn package_id] -privilege news_admin

    if {[db_0or1row img_item_id {}]} {
        # add a revision to the existing image item
        ImageMagick::util::revise_image -file $imgfile -item_id $img_item_id
    } else {
        # create a new image item
        ImageMagick::util::create_image_item -file $imgfile -parent_id $item_id
    }
    # delete the tmpfile
    ImageMagick::delete_tmp_file $imgfile
}


# set up image path
if {[exists_and_not_null item_id]} {
    set image_id [news_get_image_id $item_id]
    if { ![empty_string_p $image_id] } {
        set publish_image "image/$image_id"
    } else {
        set publish_image {}
    }
    set img_file {}
} elseif {[info exists imgfile]} { 
    set publish_image "image-view-tmpfile/$imgfile"
} else {
    set publish_image {}
    set imgfile {}
}

# if we've come back from the image page, set up dates again
if {[info exists publish_date_ansi] && [info exists archive_date_ansi]} {
    set exp {([0-9]{4})-([0-9]{1,2})-([0-9]{1,2})}
    if { ![regexp $exp $publish_date_ansi match \
               publish_date(year) publish_date(month) publish_date(day)]
         || ![regexp $exp $archive_date_ansi match \
                  archive_date(year) archive_date(month) archive_date(day)] } {
        ad_return_complaint 1 "[_ news.Publish_archive_dates_incorrect]"
    }
}

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
	set publish_date_pretty [lc_time_fmt $publish_date_ansi "%x"]
    }
    if { ![template::util::date::validate $archive_date_ansi ""] } {
	set archive_date_pretty [lc_time_fmt $archive_date_ansi "%x"]
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

    # close any open HTML tags in any case
    set  publish_body [util_close_html_tags $publish_body]
    
    set errors [ad_html_security_check $publish_body]
    ns_log Notice "errors: $errors"
    if { ![empty_string_p $errors] } {
        ad_return_complaint 1 $errors
    }
}

if { [string match $action "News Item"] } {

    # form variables for confirmation step

    set hidden_vars [export_form_vars publish_title publish_lead publish_body \
                         publish_date_ansi archive_date_ansi html_p permanent_p imgfile]
    set image_vars [export_form_vars publish_title publish_lead publish_body \
                        publish_date_ansi archive_date_ansi html_p \
                        permanent_p action]
    set form_action "<form method=post action=item-create-3 enctype=multipart/form-data>"
    set edit_action "<form method=post action=item-create>"

} else {

    # Form vars to carry through Confirmation Page
    set hidden_vars [export_form_vars item_id revision_log publish_title publish_lead publish_body \
                         publish_date_ansi archive_date_ansi permanent_p html_p imgfile]
    set image_vars [export_form_vars publish_title publish_lead publish_body \
                        publish_date_ansi archive_date_ansi html_p \
                        permanent_p action item_id revision_log]
    set form_action "<form method=post action=admin/revision-add-3>"
    set edit_action "<form method=post action=admin/revision-add>"
}

# creator link 
set creator_name [db_string creator "
select first_names || ' ' || last_name 
from   cc_users 
where  user_id = :user_id"]
set creator_link "<a href=\"/shared/community-member?user_id=$user_id\">$creator_name</a>"

if { [info exists html_p] && [string match $html_p "f"] } {
    set publish_body [ad_text_to_html -- $publish_body]
}

ad_return_template
