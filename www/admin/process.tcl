# /packages/news/www/admin/process.tcl

ad_page_contract {

    This is the target from the form on the bottom of admin/index.adp
    It processes the commands 'Delete','Archive','Make Permanent','Publish' or 'Re-Publish'.    
    In the case of (Re-)Publish, pageflow is handed on to a collective approve page
    Restricted to News Admin

    @author Stefan Deusch (stefan@arsdigita.com)
    @creation-date 12-14-00
    @cvs-id $Id$
    
} {
 
    n_items:multiple,notnull
    action:notnull

} -errors {

    n_items:notnull "Please check the items which you want to process."

} -properties {

    title:onevalue
    context_bar:onevalue
    action:onevalue
    hidden_vars:onevalue
    unapproved:multirow
    n_items:onevalue
    halt_p:onevalue
    news_items:multirow

}


# in the case of (Re-)Publish, redirect to approve
if {[string equal "publish" $action]} {
    
    ad_returnredirect "approve?[export_url_vars n_items]"
    return
}

set title "Confirm Action: $action"
set context_bar [list $title]


# produce bind_id_list     
for {set i 0} {$i < [llength $n_items]} {incr i} {
    set id_$i [lindex $n_items $i]
    lappend bind_id_list ":id_$i"
}


# 'archive' or 'making permanent' only after release possible 
if {[regexp -nocase {archive|permanent} $action ]} {             
 

    db_multirow unapproved unapproved_list "
    select    
        item_id,
        publish_title,
        creation_date,
        item_creator
    from 
        news_items_unapproved
    where 
        item_id in ([join $bind_id_list ","])"

    set halt_p [array size unapproved]

} 

# proceed if no errors
if { ![info exist halt_p] || $halt_p==0 } {

    db_multirow news_items item_list "
    select
        item_id,
        content_item.get_best_revision(item_id) as revision_id,
        package_id,
        publish_title,
        creation_date,
        item_creator
    from 
        news_items_live_or_submitted
    where
        item_id in ([join  $bind_id_list ","])" 
	
}

set hidden_vars [export_form_vars action n_items item_id]

ad_return_template








