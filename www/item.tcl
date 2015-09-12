# /packages/news/www/item.tcl

ad_page_contract {
    
    Page to view one item (live or archived) in its active revision
    @author stefan@arsdigita.com
    @creation-date 2000-12-20
    @cvs-id $Id$
    
} {

    item_id:naturalnum,notnull

} -properties {
    title:onevalue
    context:onevalue 
    item_exist_p:onevalue
    publish_title:onevalue
    publish_date:onevalue
    publish_body:onevalue
    publish_format:onevalue
    creator_link:onevalue
    comments:onevalue
    comment_link:onevalue
}


set user_id [ad_conn untrusted_user_id]

permission::require_permission \
    -object_id $item_id \
    -party_id  $user_id \
    -privilege read


# live view of a news item in its active revision
set item_exist_p [db_0or1row one_item {}]

if { $item_exist_p } {

    # Footer actions
    set footer_links [list]

    if { [parameter::get -parameter SolicitCommentsP -default 0] &&
         [permission::permission_p -object_id $item_id -privilege general_comments_create] } {

        lappend footer_links [general_comments_create_link \
                                  -link_attributes { class="button" } \
                                  $item_id \
                                  "[ad_conn package_url]item?item_id=$item_id"]

        set comments [general_comments_get_comments \
                          -print_content_p 1 \
                          -print_attachments_p 1 \
                          $item_id "[ad_conn package_url]item?item_id=$item_id"]
    } else {
        set comments ""
    }

    if {[permission::permission_p -object_id $item_id -privilege write] } {
        lappend footer_links "<a href=\"admin/revision-add?item_id=$item_id\" class=\"button\">[_ news.Revise]</a>"
    }

    set footer_links [join $footer_links "</li>\n<li>"]

    set title $publish_title
    set context [list $title]
    set publish_title {}

} else {
    set title [_ news.Error]
    set contect [list $title]
    ad_return_complaint 1 [_ news.lt_Could_not_find_the_re]
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
