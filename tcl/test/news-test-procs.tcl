ad_library {
  Test cases for the Tcl API of the news package. The test cases are based 
  on the acs-automated-testing package

  @author Peter Marklund
  @creation-date 2nd October 2003
  @cvs-id $Id$
}

namespace eval news {}
namespace eval news::test {}

aa_register_case news_pretty_status_key {
    Test the news_pretty_status_key Tcl proc and
    the news__status PLSQL function.

    @author Peter Marklund
} {
    set now_seconds [clock scan now]
    set offset [expr 60*60*24*10]
    set date_format "%Y-%m-%d"
    set future_seconds [expr $now_seconds + $offset]
    set future_date [clock format $future_seconds -format $date_format]
    set past_seconds [expr $now_seconds - $offset]
    set past_date [clock format $past_seconds -format $date_format]

    # Scheduled for publish, no archive
    news::test::assert_status_pretty \
        -publish_date $future_date \
        -archive_date "" \
        -status going_live_no_archive

    # Scheduled for publish and archive
    news::test::assert_status_pretty \
        -publish_date $future_date \
        -archive_date $future_date \
        -status going_live_with_archive

    # Published, no archive
    news::test::assert_status_pretty \
        -publish_date $past_date \
        -archive_date "" \
        -status published_no_archive

    # Published scheduled archived
    news::test::assert_status_pretty \
        -publish_date $past_date \
        -archive_date $future_date \
        -status published_with_archive

    # Published and archived
    news::test::assert_status_pretty \
        -publish_date $past_date \
        -archive_date $past_date \
        -status archived

    # Not scheduled for publish
    news::test::assert_status_pretty \
        -publish_date "" \
        -archive_date "" \
        -status unapproved
}

ad_proc -private news::test::assert_status_pretty {
    {-publish_date:required}
    {-archive_date:required}
    {-status:required}
} {
    set pretty_status [news_pretty_status -publish_date $publish_date -archive_date $archive_date -status $status]
    aa_true "publish_date=\"$publish_date\" archive_date=\"$archive_date\" status=\"$status\" pretty_status=\"$pretty_status\"" \
        [expr ![empty_string_p $pretty_status]]

    set db_news_status [news::test::get_news_status \
                           -publish_date $publish_date \
                           -archive_date $archive_date]
    aa_equals "publish_date=\"$publish_date\" archive_date=\"$archive_date\"" $db_news_status $status
}

ad_proc -private news::test::get_news_status {
    {-publish_date:required}
    {-archive_date:required}
} {
    return [db_string select_status {}]
}
