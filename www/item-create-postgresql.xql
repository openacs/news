<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="week">      
      <querytext>
      select localtimestamp(0) + interval '[ad_parameter ActiveDays "news" 14] days'
      </querytext>
</fullquery>

 
</queryset>
