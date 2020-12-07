ad_page_contract {

    Displays a hyperlinked list of published news titles either 'live' or 'archived'

    @author Stefan Deusch (stefan@arsdigita.com)
    @creation-date 2000-12-20
    @cvs-id $Id$

} {

   {view:trim "live"}
   page:naturalnum,optional

} -properties {


    title:onevalue
    context:onevalue
    news_admin_p:onevalue
    news_create_p:onevalue
    news_items:multirow
}


set package_id [ad_conn package_id]
permission::require_permission -object_id $package_id -privilege news_read


set context {}

set actions_list [list]

# view switch in live | archived news
if {"live" eq $view} {

    set title [apm_instance_name_from_id $package_id]
    set view_clause [db_map view_clause_live]

    if { [db_0or1row archived_p {}]} {
        lappend actions_list [_ news.Show_archived_news] \
            [export_vars -base [ad_conn url] {{view archive}}] \
            [_ news.Show_archived_news]
    }

} else {

    set title [apm_instance_name_from_id $package_id]
    set view_clause [db_map view_clause_archived]

    if { [db_0or1row live_p {}] } {
        lappend actions_list [_ news.Show_live_news] \
            [export_vars -base [ad_conn url] {{view live}}] \
            [_ news.Show_live_news]
    }
}

# switches for privilege-enabled links: admin for news_admin, submit for registered users
set news_admin_p [permission::permission_p -object_id $package_id -privilege news_admin]
set news_create_p [permission::permission_p -object_id $package_id -privilege news_create]

if { $news_admin_p } {
    lappend actions_list [_ news.Create_a_news_item] \
        "item-create" \
        [_ news.Create_a_news_item]
    lappend actions_list [_ news.Administer] \
        "admin/" \
        [_ news.Administer]
} else {
    if { $news_create_p } {
        lappend actions_list [_ news.Submit_a_news_item] \
            "item-create" \
            [_ news.Submit_a_news_item]
    }
}


# build the multirow for the list

db_multirow -extend { publish_date news_item_url } news_items item_list {} {
    set publish_date [lc_time_fmt $publish_date_ansi "%q"]
    set news_item_url [export_vars -base "item" {item_id}]
}

# TODO: pagination
set max_dspl [parameter::get -parameter DisplayMax -default 10]
template::list::create -name news -multirow news_items -actions $actions_list -no_data [_ news.lt_There_are_no_news_ite] -elements {
    publish_date {
        label "[_ news.Release_Date]"
    }
    publish_title {
        label "[_ news.Title]"
        display_col publish_title
        link_url_col news_item_url
        link_html {title "#news.show_content_news_items_publish_title#"}
    }
    publish_lead {
        label "[_ news.Lead]"
    }
}

# Check if RSS generation is active and a subscription exists
if {[parameter::get_global_value -package_key rss-support -parameter RssGenActiveP -default 1]} {
    set rss_exists_p [rss_support::subscription_exists \
                        -summary_context_id $package_id \
                        -impl_name news]
    set rss_url "[news_util_get_url $package_id]rss/rss.xml"
} else {
    set rss_exists_p 0
}

set news_url [ad_return_url]

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
