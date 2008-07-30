<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <fullquery name="get_dates">      
    <querytext>
      select 
        to_char(current_timestamp + interval '[ad_parameter ActiveDays "news" 14] days', 'YYYY-MM-DD') as date_proj,
        to_char(current_timestamp, 'YYYY-MM-DD') as date_today
    </querytext>
  </fullquery>

</queryset>
