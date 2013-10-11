# /packages/news/www/admin/revision-add-3.tcl

ad_page_contract {

    This page adds a new revision to a news item 
    and redirects to the item page of that item

    @author stefan@arsdigita.com
    @creation-date 2000-12-20
    @cvs-id $Id$

} { 
    item_id:integer
    publish_title:notnull
    publish_lead
    publish_body:allhtml,notnull,trim
    publish_body.format:notnull
    revision_log:notnull
    publish_date_ansi:notnull
    archive_date_ansi:notnull
    permanent_p:notnull
}

# Avoid any driver/bindvar nonsense regarding "." in a variable name
set mime_type ${publish_body.format}

if {$permanent_p == "t"} {
    set archive_date_ansi [db_null]
} 

# approval foo
set approval_user [ad_conn "user_id"]
set approval_ip [ad_conn "peeraddr"]
set approval_date [dt_sysdate]
set live_revision_p "t"

# creation foo 
set creation_ip [ad_conn "peeraddr"]
set creation_user [ad_conn "user_id"]

# make new revision the active revision
set active_revision_p "t"

# Insert is 2-step process, same as in item-create-3.tcl
if [catch { 
    set revision_id [db_exec_plsql create_news_item_revision "
    begin
        :1 := news.revision_new(
            item_id       => :item_id,
            publish_date  => :publish_date_ansi,
            title         => :publish_title,   
            description   => :revision_log,
            mime_type     => :mime_type,
            package_id    => [ad_conn package_id],
            archive_date  => :archive_date_ansi,
            approval_user => :approval_user,
            approval_date => :approval_date,
            approval_ip   => :approval_ip,
            creation_ip   => :creation_ip,
            creation_user => :creation_user,
            make_active_revision_p => :active_revision_p);
    end;"]

    set content_add [db_map content_add]
    if {![string match $content_add ""]} {    
	db_dml content_add "
	update cr_revisions
	set    content = empty_blob()
	where  revision_id = :revision_id
	returning content into :1" -blobs  [list $publish_body]
    }
   
} errmsg ] {
	
    set complaint " [_ news.lt_The_database_did_not_]
    [_ news.lt_See_details_for_the_e]\n\n\t<p><b>$errmsg</b>"
    ad_return_error "[_ news.Database_Error]" "$complaint" 
    ad_script_abort
	
} else {
	
    ad_returnredirect "item?item_id=$item_id"
	
}    
