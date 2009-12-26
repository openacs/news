# /packages/news/www/item-create-3.tcl

ad_page_contract {

    Final insert into database to create a news item
    (no double-click protection, see bboard for discussion)

    @author stefan@arsdigita.com
    @creation-date 2000-12-14
    @cvs-id $Id$
} {
    publish_title:notnull
    publish_body:notnull,trim
    publish_body.format:notnull,trim
    {publish_lead {}}
    {publish_date_ansi:trim "[db_null]"}
    {archive_date_ansi:trim "[db_null]"}
    permanent_p:notnull
    imgfile:optional
} -validate {
     imgfile_valid {
         if { [exists_and_not_null imgfile]
              && ![ImageMagick::validate_tmp_file $imgfile] } {
             ad_complain
         }
     }
} -errors {
     imgfile_valid {Image file invalid}
}  -properties {
    title:onevalue
    context:onevalue
}


#  news_create permissions
set package_id [ad_conn package_id]
ad_require_permission $package_id news_create


set news_admin_p [ad_permission_p $package_id news_admin]
# get instance-wide approval policy : [closed|wait|open]
set approval_policy [ad_parameter ApprovalPolicy "news" "wait"]

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

# if an image is specified, we add it here.
if {[exists_and_not_null imgfile]} {
    # ImageMagick package will check its tmp directory for the file, so no
    # need to expand the path.
    db_1row item {
        select item_id from cr_revisions where revision_id = :news_id
    }
    ImageMagick::util::create_image_item -file $imgfile -parent_id $item_id
    ImageMagick::delete_tmp_file $imgfile
}

    #update RSS if it is enabled

if { !$news_admin_p } {
    
    if { ![string equal "open" [ad_parameter ApprovalPolicy "news" "wait"]] } {
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
