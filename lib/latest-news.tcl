ad_include_contract {
    Show latest news stories

    @author Tom Ayles (tom@beatniq.net)
    @creation-date 2003-12-17
    @cvs-id $Id$

    @param package_id    ID of the news instance to use as a source
    @param base_url      base URL of the news instance to use as a source
    @param n             The number of stories to show, default 2
    @param max_age       The limit on the recency of news items, in days, default no limit
    @param id            CSS id
    @param class         CSS class
    @param show_empty_p  show element even if empty, default 1
    @param cache         cache period, default 0 for no caching
} {
    {package_id:integer ""}
    {base_url:localurl ""}
    {n:integer,notnull 2}
    {max_age ""}
    {id:word ""}
    {class:word ""}
    {show_empty_p:boolean,notnull 1}
    {cache:integer,notnull 0}
} -validate {
    package_id_or_base_url {
        if { $package_id eq "" && $base_url eq "" } {
            ad_complain
        }
    }
} -errors {
    package_id_or_base_url {must supply package_id and/or base_url}
}

if { $max_age ne "" } {
    set max_age_filter [db_map max_age_filter]
} else {
    set max_age_filter ""
}

if { $package_id eq "" } {
    set package_id [site_node::get_element \
                        -url $base_url -element object_id]
}
if { $base_url eq "" } {
    set base_url [lindex [site_node::get_url_from_object_id \
                              -object_id $package_id] 0]
}


set script "# /packages/news/lib/latest-news.tcl
set max_age_filter {$max_age_filter}
set n $n
set package_id $package_id
db_list_of_lists ls {} -bind { package_id $package_id max_age $max_age }"

multirow create news item_id title lead publish_date url date
util_memoize_flush $script
foreach row [util_memoize $script $cache] {
    lassign $row item_id title lead publish_date
    set url "${base_url}item?item_id=$item_id"
    set date [lc_time_fmt $publish_date {%x}]

    multirow append news $item_id $title $lead $publish_date $url $date
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
