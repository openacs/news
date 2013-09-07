<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="week">      
      <querytext>
      select to_char(current_timestamp + interval '[parameter::get -parameter ActiveDays -default 14] days', 'YYYY-MM-DD')
      </querytext>
</fullquery>


<partialquery name="revision_select">      
      <querytext>

    content_item__get_best_revision(item_id) as revision_id,

      </querytext>
</partialquery>

</queryset>
