# /packages/news/www/admin/revoke.tcl

ad_page_contract {

    This page allows the News Admin to revoke one or many news item.
    No intermediate page is shown.

    @author Stefan Deusch (stefan@arsdigita.com)
    @creation-date  2000-12-20
    @cvs-id $Id$

} {
    item_id:notnull
    {revision_id: ""}
} 


db_exec_plsql news_item_revoke {
    begin
        news.set_approve(
            approve_p    => 'f',
            revision_id  => :revision_id
        );
    end;
}

ad_returnredirect "item?item_id=$item_id"


