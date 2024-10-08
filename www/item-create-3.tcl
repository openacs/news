# /packages/news/www/item-create-3.tcl

ad_page_contract {

    Final insert into database to create a news item
    (no double-click protection, see bboard for discussion)

    @author stefan@arsdigita.com
    @creation-date 2000-12-14
    @cvs-id $Id$
} {
    publish_title:notnull
    publish_body:allhtml,notnull,trim
    publish_body.format:path,notnull,trim
    {publish_lead {}}
    {publish_date:clock(%Y-%m-%d) {}}
    {archive_date:clock(%Y-%m-%d) {}}
    permanent_p:boolean,notnull
} -errors {
     imgfile_valid {Image file invalid}
}  -properties {
    title:onevalue
    context:onevalue
}


#  news_create permissions
set package_id [ad_conn package_id]
permission::require_permission -object_id $package_id -privilege news_create

set news_admin_p [permission::permission_p -object_id $package_id -privilege news_admin]

# get instance-wide approval policy : [closed|wait|open]
set approval_policy [parameter::get -parameter ApprovalPolicy -default "wait"]

#
# the news_admin or an open approval policy allow immediate publishing
#
if { $news_admin_p || $approval_policy eq "open" } {
    set approval_user [ad_conn user_id]
    set approval_ip [ad_conn peeraddr]
    set approval_date [dt_sysdate]
    set live_revision_p "t"
} else {
    set approval_user ""
    set approval_ip ""
    set approval_date ""
    set live_revision_p "f"
}

# Allow the user to "never expire" a news item.
if {$permanent_p} {
    set archive_date ""
}

# get creation_foo
set creation_date [dt_sysdate]
set creation_ip [ad_conn peeraddr]
set user_id [ad_conn user_id]

# avoid any db weirdness with the "." in the variable name.
set mime_type ${publish_body.format}

set news_id [db_exec_plsql create_news_item {}]

#
# For postgres, the news # item body is stored in the prior news__new
# call. The blob stuff is just needed for Oracle.
#
set content_add [db_map content_add]
if {$content_add ne ""} {
    db_dml content_add {} -blobs  [list $publish_body]
}

#
# update RSS if it is enabled
#
if { !$news_admin_p &&
     "open" ne [parameter::get -parameter ApprovalPolicy -default "wait"] } {
    # A regular user submitted a news item needing approval: return to
    # a Thank-you page.
    set title [_ news.News_item_submitted]
    set context [list $title]
    set return_url item-create-thankyou
} else {
    # News does not need approval or user is an administrator: return
    # to index page.
    set return_url ""
}

# news item is live

# send out rss

if {$live_revision_p \
    && [rss_support::subscription_exists \
            -summary_context_id $package_id \
            -impl_name news]} {
    news_update_rss -summary_context_id $package_id
}

# send out notifications
if { $live_revision_p } {
    news_do_notification $package_id $news_id
}

ad_returnredirect $return_url
ad_script_abort

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
