# /packages/news/www/admin/revision.tcl

ad_page_contract {
    
    Page to view one news item in an arbitrary revision
    @author Stefan Deusch (stefan@arsdigita.com)
    @creation-date 2000-12-20
    @cvs-id $Id$
    
} {

    item_id:notnull
    revision_id:notnull

} -properties {

    title:onevalue
    context_bar:onevalue
    news_admin_p:onevalue
    item_exist_p:onevalue
    publish_title:onevalue
    publish_body:onevalue
    html_p:onevalue
    creator_link:onevalue
}


# access restricted to admin as long as in news/admin/


# Access a news item in a particular revision
set item_exist_p [db_0or1row one_item "
    select item_id,
           revision_id,
           content_revision.get_number(:revision_id) as revision_no,
           publish_title,
           html_p,
           publish_date,
           archive_date,
           creation_ip,
           creation_date,
           '<a href=/shared/community-member?user_id=' || creation_user || '>' || item_creator ||  '</a>' as creator_link
    from   news_item_revisions
    where  item_id = :item_id
    and    revision_id = :revision_id"]

if { $item_exist_p } {

    # workaround to get blobs with >4000 chars into a var, content.blob_to_string fails! 
    # when this'll work, you get publish_body by selecting 'publish_body' directly from above view
    #
    if {![string match [db_type] "postgresql"]} {
	set publish_body [db_string get_content "select  content
	from    cr_revisions
	where   revision_id = :revision_id"]
    }
    
    # text-only body
    if {[info exists html_p] && ![string equal $html_p "t"]} {
	set publish_body "<pre>[ad_quotehtml $publish_body]</pre>"
    }
    set title "One Item"
    set context_bar [list $title]
    
} else {
    set context_bar {}
    set title "Error"
}

ad_return_template