<?xml version="1.0"?>

<queryset>
    <rdbms><type>postgresql</type><version>7.1</version></rdbms>

    <fullquery name="news::test::get_news_status.select_status">      
          <querytext>
              select news__status(:publish_date, :archive_date);
          </querytext>
    </fullquery>

</queryset>
