<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="week">      
      <querytext>
      select sysdate + [ad_parameter ActiveDays "news" 14] from dual
      </querytext>
</fullquery>

 
</queryset>
