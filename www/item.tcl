# /packages/news/www/item.tcl

ad_page_contract {
    
    Page to view one item (live or archived) in its active revision
    @author stefan@arsdigita.com
    @creation-date 2000-12-20
    @cvs-id $Id$
    
} {

    item_id:integer,notnull

} -properties {
    title:onevalue
    context_bar:onevalue 
    item_exist_p:onevalue
    publish_title:onevalue
    publish_date:onevalue
    publish_body:onevalue
    html_p:onevalue
    creator_link:onevalue
    comments:onevalue
    comment_link:onevalue
}


ad_require_permission [ad_conn package_id] news_read


# live view of a news item in its active revision
set item_exist_p [db_0or1row one_item "
select item_id,
       live_revision,
       publish_title,
       html_p,
       publish_date,
       '<a href=/shared/community-member?user_id=' || creation_user || '>' || item_creator ||  '</a>' as creator_link
from   news_items_live_or_submitted
where  item_id = :item_id"]


if { $item_exist_p } {

    # workaround to get blobs with >4000 chars into a var, content.blob_to_string fails! 
    # when this'll work, you get publish_body by selecting 'publish_body' directly from above view
    #
    # RAL: publish_body is already snagged in the 1st query above for postgres.
    #
    if {![string match [db_type] "postgresql"]} {
	set publish_body [db_string get_content "select  content
	from    cr_revisions
	where   revision_id = :live_revision"]
    }

    # text-only body
    if {[info exists html_p] && [string equal $html_p "f"]} {
	set publish_body "<pre>[ad_quotehtml $publish_body]</pre>"
    }
    
    if { [ad_parameter SolicitCommentsP "news" 0] &&
         [ad_permission_p $item_id general_comments_create] } {
	set comment_link [general_comments_create_link $item_id "[ad_conn package_url]item?item_id=$item_id"]
	set comments [general_comments_get_comments -print_content_p 1 -print_attachments_p 1 \
		$item_id "[ad_conn package_url]item?item_id=$item_id"]
    } else {
	set comment_link ""
        set comments ""
    }
    
    set title $publish_title
    set context_bar [list $title]

} else {
    set context_bar {}
    set title "Error"
}


ad_return_template
















