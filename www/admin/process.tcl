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
} -errors [list n_items:notnull [_ news.lt_Please_check_the_item]] \
  -properties {
    title:onevalue
    context:onevalue
    action:onevalue
    hidden_vars:onevalue
    unapproved:multirow
    n_items:onevalue
    halt_p:onevalue
    news_items:multirow
}


# in the case of (Re-)Publish, redirect to approve
if {"publish" eq $action} {
    
    ad_returnredirect [export_vars -base approve {n_items}]
    ad_script_abort
}

set title "[_ news.Confirm_Action] $action"
set context [list $title]

array set action_msg_key {
    publish news.Publish
    "make permanent" news.Make_Permanent
    "archive now" news.Archive_Now
    "archive next week" news.lt_Archive_as_of_Next_We
    "archive next month" news.lt_Archive_as_of_Next_Mo
    "make permanent" news.Make_Permanent
    "delete" news.Delete
}

set action_pretty [_ $action_msg_key($action)]

# produce bind_id_list     
for {set i 0} {$i < [llength $n_items]} {incr i} {
    set id_$i [lindex $n_items $i]
    lappend bind_id_list ":id_$i"
}


# 'archive' or 'making permanent' only after release possible 
if {[regexp -nocase {archive|permanent} $action ]} {             
 
    db_multirow -extend { creation_date_pretty }  unapproved unapproved_list {} {
        set creation_date_pretty [lc_time_fmt $creation_date "%x"]
    }
    
    set halt_p [array size unapproved]

} 

# proceed if no errors
if { ![info exists halt_p] || $halt_p==0 } {

    template::list::create \
        -name news_items \
        -multirow news_items \
        -elements {
            publish_title {
                label \#news.Title\#
            }
            creation_date {
                label \#news.Creation_Date\#
                display_col creation_date_pretty
            }
            item_creator {
                label \#news.Author\#
            }
        }

    db_multirow -extend { creation_date_pretty } news_items item_list {} {
        set creation_date_pretty [lc_time_fmt $creation_date "%x"]
    }
	
}

set hidden_vars [export_vars -form {action n_items item_id}]

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
