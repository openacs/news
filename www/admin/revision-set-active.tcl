# /packages/news/www/admin/revision-set-active.tcl

ad_page_contract {
    
    This page changes the active revision of a news item and returns to item

    @author stefan@arsdigita.com
    @creation-date 2000-12-20
    @cvs-id $Id$
    
} {

    item_id:naturalnum,notnull
    new_rev_id:naturalnum,notnull
    
}


db_exec_plsql update_forum {
    begin
       news.revision_set_active (:new_rev_id);
    end;
}
    
ad_returnredirect "item?item_id=$item_id"






