<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="archive_now">      
      <querytext>
      select sysdate from dual
      </querytext>
</fullquery>

 
<fullquery name="archive_next_week">      
      <querytext>
      select next_day(sysdate,'Monday') from dual
      </querytext>
</fullquery>

 
<fullquery name="archive_next_month">      
      <querytext>
      select last_day(sysdate)+1 from dual
      </querytext>
</fullquery>

 
</queryset>
