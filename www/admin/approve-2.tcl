# /packages/news/www/admin/approve-2.tcl

ad_page_contract {

    This page makes the insert of publish_date and archive_date (optionally)
    into cr_revisions and cr_news(news_id) resp. without intermediate confirmation.
    The administrator is redirected to return_url:localurl

    @author stefan@arsdigita.com
    @creation-date 2000-12-20
    @cvs-id $Id$

} {
    revision_id:naturalnum,notnull,multiple
    {return_url:localurl ""}
    {permanent_p:boolean,notnull "f"}
    {publish_date:clock(%Y-%m-%d) ""}
    {archive_date:clock(%Y-%m-%d) ""}
}


# read dates and prepare in ANSI form

if {$permanent_p} {

    set archive_date ""

} else {

    if { [dt_interval_check $archive_date $publish_date] >= 0 } {
        ad_return_error "[_ news.Scheduling_Error]" \
            "[_ news.lt_The_archive_date_must]"
        ad_script_abort
    }

}

set approval_user [ad_conn "user_id"]
set approval_ip [ad_conn "peeraddr"]
set approval_date [dt_sysdate]
set live_revision_p "t"


foreach id $revision_id {

    db_exec_plsql news_item_approve_publish {}

}
set package_id [ad_conn package_id]
if {[rss_support::subscription_exists \
            -summary_context_id $package_id \
            -impl_name news]} {
    news_update_rss -summary_context_id $package_id
}

ad_returnredirect "$return_url"
ad_script_abort

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
