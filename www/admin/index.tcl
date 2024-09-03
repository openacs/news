ad_page_contract {

    Display a list of news items summary for administration

    @author Stefan Deusch (stefan@arsdigita.com)
    @creation-date 2000-12-20
    @cvs-id $Id$

} {
  {orderby:token "item_id"}
  {view:word "published"}
  {column_names:array ""}
} -properties {
    title:onevalue
    context:onevalue
    view_link:onevalue
    hidden_vars:onevalue
    item_list:multirow
}


# Authorization:restricted to admin as long as in /news/admin
set package_id [ad_conn package_id]


set view_slider [list \
    [list view "[_ news.News_Items]" published [list \
        [list published "[_ news.Published]" {where "status like 'published%'"}] \
        [list unapproved "[_ news.Unapproved]" {where "status = 'unapproved'"}] \
        [list approved "[_ news.Approved]" {where "status like 'going_live%'"}] \
        [list archived "[_ news.Archived]"     {where "status = 'archived'"}] \
        [list all "[_ news.All]"               {} ] \
    ]]
]
set view_link [ad_dimensional $view_slider]
set view_option [ad_dimensional_sql $view_slider]

set bulk_actions [list]

# define action on selected views, unapproved, archived, approved need restriction
switch -- $view {
    "all" {
    }
    "unapproved" {
        lappend bulk_actions \
            [_ news.Publish] \
            [export_vars -base process {{action publish}}] \
            ""
    }
    "archived"   {
        lappend bulk_actions \
            [_ news.Publish] \
            [export_vars -base process {{action publish}}] \
            ""
    }
    "approved"   {
        lappend bulk_actions \
            [_ news.Make_Permanent] \
            [export_vars -base process {{action "make permanent"}}] \
            ""
    }
    default {
        lappend bulk_actions \
            [_ news.Archive_Now] \
            [export_vars -base process {{action "archive now"}}] \
            "" \
            \
            [_ news.lt_Archive_as_of_Next_We] \
            [export_vars -base process {{action "archive next week"}}] \
            "" \
            \
            [_ news.lt_Archive_as_of_Next_Mo] \
            [export_vars -base process {{action "archive next month"}}] \
            "" \
            \
            [_ news.Make_Permanent] \
            [export_vars -base process {{action "make permanent"}}] \
            ""
    }
}

set title "[_ news.Administration]"
set context {}

# Check if RSS generation is active and a subscription exists
set rss_gen_active_p [parameter::get_global_value -package_key rss-support -parameter RssGenActiveP -default 1]
if {$rss_gen_active_p} {
    set rss_exists_p [rss_support::subscription_exists \
                        -summary_context_id $package_id \
                        -impl_name news]
    set rss_feed_url [news_util_get_url $package_id]rss/rss.xml
}

set actions [list \
                 "#news.Create_a_news_item#" ../item-create "" \
                ]
if { $rss_gen_active_p } {
    if { $rss_exists_p} {
        lappend actions \
            "#rss-support.Rss_feed_active# \[ #rss-support.Remove_feed# \]" rss ""
    } else {
        lappend actions \
            "#rss-support.Rss_feed_inactive# \[ #rss-support.Create_feed# \]" rss ""
    }
}

template::list::create \
    -name news_items \
    -multirow news_items \
    -key n_items \
    -actions $actions \
    -bulk_actions $bulk_actions \
    -elements {
        item_id {
            label "ID#"
            link_url_col item_url
        }
        publish_title {
            label "[_ news.Title]"
            display_template {
                @news_items.publish_title@ (#news.rev# @news_items.revision_no@) <a href="@news_items.revise_url@">#news.revise#
            }
        }
        item_creator {
            label "[_ news.Author]"
            link_url_col creator_url
        }
        publish_date {
            label "[_ news.Release_Date]"
            display_col publish_date_pretty
        }
        archive_date {
            label "[_ news.Archive_Date]"
            display_col archive_date_pretty
        }
        status {
            label "[_ news.Status]"
            display_col pretty_status
        }
    }

# administrator sees all news items
db_multirow -extend {
    publish_date_pretty
    archive_date_pretty
    pretty_status
    n_items
    item_url
    revise_url
    creator_url
} news_items itemlist {} {
    set n_items $item_id
    set item_url [export_vars -base item {item_id}]
    set revise_url [export_vars -base revision_add {item_id}]
    set creator_url [acs_community_member_url -user_id $creation_user]
    set publish_date_pretty [lc_time_fmt $publish_date_ansi "%x"]
    set archive_date_pretty [lc_time_fmt $archive_date_ansi "%x"]
    set pretty_status [news_pretty_status \
                           -publish_date $publish_date_ansi \
                           -archive_date $archive_date_ansi \
                           -status $status]
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
