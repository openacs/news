# /packages/news/www/item-create-3.tcl

ad_page_contract {

    Final insert into database to create a news item
    (no double-click protection, see bboard for discussion)
    @author stefan@arsdigita.com
    @creation-date 2000-12-14
    @cvs-id $Id$
    
} {

    publish_title:notnull
    publish_body:notnull,allhtml,trim
    {publish_date_ansi:trim "[db_null]"}
    {archive_date_ansi:trim "[db_null]"}
    html_p:notnull
    permanent_p:notnull
    
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


# set mime_type
if {[string match $html_p t]} {
    set mime_type "text/html"
} else {
    set mime_type "text/plain"
}


# do insert: unfortunately the publish_body cannot be supplied through the PL/SQL function
# we therefore have to do this in a second step 
set news_id [db_exec_plsql create_news_item "
begin
:1 := news.new(
title           => :publish_title,
publish_date    => :publish_date_ansi, 
archive_date    => :archive_date_ansi,
mime_type       => :mime_type,        
package_id      => :package_id,       
approval_user   => :approval_user,     
approval_date   => :approval_date,      
approval_ip     => :approval_ip,   
creation_ip     => :creation_ip,    
creation_user   => :user_id,     
is_live_p       => :live_revision_p    
);
end;"]

#
# RAL: For postgres, we need NOT store the data in a blob.  The
# news item body is stored in the prior news__new call.
#
set content_add [db_map content_add]
if {![string match $content_add ""]} {
    db_dml content_add "
    update cr_revisions
    set    content = empty_blob()
    where  revision_id = :news_id
    returning content into :1" -blobs  [list $publish_body]
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

if {$live_revision_p \
    && [rss_support::subscription_exists \
            -summary_context_id $package_id \
            -impl_name news]} {
    news_update_rss -summary_context_id $package_id
}

