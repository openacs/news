# include fragment to show latest news stories
#
# parameters:
#   package_id - ID of the news instance to use as a source
#   base_url - base URL of the news instance to use as a source
#   n - The number of stories to show, default 2
#   max_age - The limit on the recency of news items, in days, default no limit
#   id - CSS id
#   class - CSS class
#   show_empty_p - show element even if empty, default 1
#   cache - cache period, default 0 for no caching
#
# @author Tom Ayles (tom@beatniq.net)
# @creation-date 2003-12-17
# @cvs-id $Id$
#

# parameter processing... n is interpolated into the query (as bind variables
# are not supported in PGSQL LIMIT construct), so we have to check its validity
if { [info exists n] } {
    if { ![string is integer $n] } { error {n must be an integer} }
} else {
    set n 2
}
if { ![info exists cache] } { set cache 0 }
if { [info exists max_age] } {
    set max_age_filter [db_map max_age_filter]
} else {
    set max_age {}
    set max_age_filter {}
}
foreach param {id class} { if { ![info exists $param] } { set $param {} } }
if { ![info exists show_empty_p] } { set show_empty_p 1 }

if { (![info exists package_id] || $package_id eq "")
     && (![info exists base_url] || $base_url eq "") } {
    error "must supply package_id and/or base_url"
}

if { ![info exists package_id] || $package_id eq "" } {
    set package_id [site_node::get_element \
                        -url $base_url -element object_id]
}
if { ![info exists base_url] || $base_url eq "" } {
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
