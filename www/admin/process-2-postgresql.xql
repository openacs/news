<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="archive_now">      
      <querytext>
      select current_timestamp 
      </querytext>
</fullquery>

 
<fullquery name="archive_next_week">      
      <querytext>
      select next_day(current_timestamp,'Monday')::date
      </querytext>
</fullquery>

 
<fullquery name="archive_next_month">      
      <querytext>
      select (last_day(current_timestamp)+'1 day')::date
      </querytext>
</fullquery>

 
</queryset>
