<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="week">      
      <querytext>
      select current_timestamp + [ad_parameter ActiveDays "news" 14] 
      </querytext>
</fullquery>


<partialquery name="revision_select">      
      <querytext>

    content_item__get_best_revision(item_id) as revision_id,

      </querytext>
</partialquery>

</queryset>
