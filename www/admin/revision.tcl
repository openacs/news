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
    context:onevalue
    news_admin_p:onevalue
    item_exist_p:onevalue
    publish_title:onevalue
    publish_lead:onevalue
    publish_body:onevalue
    html_p:onevalue
    creator_link:onevalue
}


# access restricted to admin as long as in news/admin/


# Access a news item in a particular revision
set item_exist_p [db_0or1row one_item {}]

if { $item_exist_p } {

    # workaround to get blobs with >4000 chars into a var, content.blob_to_string fails! 
    # when this'll work, you get publish_body by selecting 'publish_body' directly from above view
    #
    set get_content [db_map get_content]
    if { $get_content ne "" } {
        set publish_body [db_string get_content {}]
    }
    
    # text-only body
    #
    # replaced this with code from /packages/news/www/item.tcl
    #
    #if {[info exists html_p] && ![string equal $html_p "t"]} {
    #    set publish_body "[ad_quotehtml $publish_body]"
    #}
    if { !$html_p } {
    	set publish_body [ad_text_to_html -- $publish_body]
    }

    set title [_ news.Revision]
    set context [list [list "item?[export_vars -url item_id]" [_ news.One_Item]] $title]

    set creation_date_pretty [lc_time_fmt $creation_date %q]
    set publish_date_pretty [lc_time_fmt $publish_date %q]
    set archive_date_pretty [lc_time_fmt $archive_date %q]
    
} else {
    ad_return_complaint 1 [_ news.lt_Could_not_find_corres]
}

ad_return_template
