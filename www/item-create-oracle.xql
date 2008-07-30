<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="get_dates">      
    <querytext>
      select to_char(sysdate + [ad_parameter ActiveDays "news" 14], 'YYYY-MM-DD') as date_proj,
             to_char(sysdate, 'YYYY-MM-DD') as date_today 
      from dual
    </querytext>
  </fullquery>

</queryset>
