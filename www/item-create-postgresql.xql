<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="week">      
      <querytext>
      select to_char(current_timestamp + interval '[ad_parameter ActiveDays "news" 14] days', 'YYYY-MM-DD')
      </querytext>
</fullquery>

 
</queryset>
