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
    Test the news_pretty_status_key proc.

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
        -expect_key news.going_live_no_archive

    # Scheduled for publish and archive
    news::test::assert_status_pretty \
        -publish_date $future_date \
        -archive_date $future_date \
        -expect_key news.going_live_with_archive

    # Published, no archive
    news::test::assert_status_pretty \
        -publish_date $past_date \
        -archive_date "" \
        -expect_key news.published_no_archive

    # Published scheduled archived
    news::test::assert_status_pretty \
        -publish_date $past_date \
        -archive_date $future_date \
        -expect_key news.published_scheduled_for_archive

    # Published and archived
    news::test::assert_status_pretty \
        -publish_date $past_date \
        -archive_date $past_date \
        -expect_key news.Archived

    # Not scheduled for publish
    news::test::assert_status_pretty \
        -publish_date "" \
        -archive_date "" \
        -expect_key news.Unapproved
}

ad_proc -private news::test::assert_status_pretty {
    {-publish_date:required}
    {-archive_date:required}
    {-expect_key:required}
} {
    aa_equals "publish_date \"$publish_date\" archive_date \"$archive_date\"" \
        [news_pretty_status_key -publish_date $publish_date -archive_date $archive_date] $expect_key
}
