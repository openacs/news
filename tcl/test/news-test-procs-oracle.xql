<?xml version="1.0"?>

<queryset>
    <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

    <fullquery name="news::test::get_news_status.select_status">      
          <querytext>
              select news.status(:publish_date, :archive_date) from dual
          </querytext>
    </fullquery>

</queryset>
