<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="archived_p">      
      <querytext>
      
    select case when count(*) = 0 then 0 else 1 end 
    from   news_items_approved
    where  publish_date < sysdate 
    and    archive_date < sysdate
    and    package_id = :package_id
      </querytext>
</fullquery>

 
<fullquery name="live_p">      
      <querytext>
      
    select case when count(*) = 0 then 0 else 1 end 
    from   news_items_approved
    where  publish_date < sysdate 
    and    (archive_date is null 
            or archive_date > sysdate) 
    and    package_id = :package_id
      </querytext>
</fullquery>


<partialquery name="view_clause_live">      
      <querytext>

    publish_date < sysdate 
    and (archive_date is null or archive_date > sysdate)      
      </querytext>
</partialquery>


<partialquery name="view_clause_archived">      
      <querytext>

    publish_date < sysdate
    and archive_date < sysdate
      </querytext>
</partialquery>

</queryset>
