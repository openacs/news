# 

ad_page_contract {
    
    Setup or remove rss feed
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-01-23
    @arch-tag: 4ff5628c-77f1-40ef-86c7-ef247a1ffe4f
    @cvs-id $Id$
} {
} -properties {
} -validate {
} -errors {
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
permission::require_permission \
    -object_id $package_id \
    -party_id $user_id \
    -privilege "admin"

if {[rss_support::subscription_exists \
                    -summary_context_id $package_id \
         -impl_name news]} {
    #deactivate rss
    rss_support::del_subscription \
        -summary_context_id $package_id \
        -impl_name "news" \
        -owner "news"
    set message "RSS feed deactivated"
} else {
    #activate rss
    set subscr_id [rss_support::add_subscription \
                       -summary_context_id $package_id \
                       -impl_name "news" \
                       -lastbuild "now" \
                       -owner "news"]
    rss_gen_report $subscr_id
    set message "RSS feed activated"
}

ad_returnredirect -message $message "./"