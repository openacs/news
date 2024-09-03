# /packages/news/www/admin/revision-add.tcl

ad_page_contract {

    This page serves as UI to add a new revision of a news item
    By default, the fields of the active_revision are filled in.
    Currently only News Admin can do this, not the original submitter though.

    @author stefan@arsdigita.com
    @creation-date 2000-12-20
    @cvs-id $Id$

} {

    item_id:object_id,notnull

} -properties {

    title:onevalue
    context:onevalue
    publish_date:onevalue
    publish_date_desc:onevalue
    publish_title:onevalue
    publish_lead:onevalue
    publish_body:onevalue
    publish_format:onevalue
    archive_date:onevalue
    never_checkbox:onevalue
    hidden_vars:onevalue
}

db_1row news_item_info {}

set title [_ news.Add_a_new_revision]
set context [list $title]

# get active revision of news item
db_1row item {}

if {$archive_date eq ""} {
    set active_days [parameter::get -parameter ActiveDays -default 14]
    set archive_date [clock format [clock scan "$active_days days"] -format %Y-%m-%d]
}

set action "[_ news.Revision]"
ns_log notice "NEWS REVISION"
ad_form -name "news_revision" -export {item_id action} -html {enctype "multipart/form-data"} -action "../preview" -form {
    {publish_title:text(text)
        {label "[_ news.Title]"}
        {html {size 61 maxlength 400}}
        {value $publish_title}
    }
    {publish_lead:text(textarea),optional
        {label "[_ news.Lead]"}
        {html {cols 60 rows 3}}
        {value $publish_lead}
    }
    {publish_body:text(richtext),optional
        {label "[_ news.Body]"}
        {html {cols 60 rows 20}}
        {value "[list $publish_body $publish_format]"}
    }
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
        {options {{"#news.show_it_permanently#" t}}}
    }
    {revision_log:text(text)
        {label "[_ news.Revision_log]"}
        {html {size 61 maxlength 400}}
    }
}

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
