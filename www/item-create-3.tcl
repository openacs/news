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
    publish_body.format:notnull,trim
    {publish_lead {}}
    {publish_date_ansi:trim "[db_null]"}
    {archive_date_ansi:trim "[db_null]"}
    permanent_p:notnull
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

# the news_admin or an open approval policy allow immediate publishing
if { $news_admin_p == 1 || [string equal $approval_policy "open"] } { 

    set approval_user [ad_conn "user_id"]
    set approval_ip [ad_conn "peeraddr"]
    set approval_date [dt_sysdate]
    set live_revision_p "t"

} else {
    
    set approval_user [db_null]
    set approval_ip [db_null]
    set approval_date [db_null]
    set live_revision_p "f"

}

# RAL: This was missing and allows the user to "never expire" a news
# item.
if {[string equal $permanent_p "t"] } {
    set archive_date_ansi [db_null]
} 

# get creation_foo
set creation_date [dt_sysdate]
set creation_ip [ad_conn "peeraddr"]
set user_id [ad_conn "user_id"]

# avoid any db weirdness with the "." in the variable name.
set mime_type ${publish_body.format}

# do insert: unfortunately the publish_body cannot be supplied through the PL/SQL function
# we therefore have to do this in a second step 
set news_id [db_exec_plsql create_news_item {}]

#
# RAL: For postgres, we need NOT store the data in a blob.  The
# news item body is stored in the prior news__new call.
#
set content_add [db_map content_add]
if {![string match $content_add ""]} {
    db_dml content_add {} -blobs  [list $publish_body]
}

#update RSS if it is enabled

if { !$news_admin_p } {
    
    if { ![string equal "open" [parameter::get -parameter ApprovalPolicy -default "wait"]] } {
	# case: user submitted news item, is returned to a Thank-you page
	set title "[_ news.News_item_submitted]"
	set context [list $title]
	ad_return_template item-create-thankyou 
    }

} else {    
    # case: administrator returned to index page
    ad_returnredirect ""
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

ad_returnredirect ""
