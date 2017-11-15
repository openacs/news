<?xml version="1.0"?>

<queryset>

<fullquery name="archived_p">      
      <querytext>
        select 1 where exists (
    select 1 from news_items_approved
     where publish_date < current_timestamp 
       and archive_date < current_timestamp
       and package_id = :package_id
       )
      </querytext>
</fullquery>
 
<fullquery name="live_p">      
      <querytext>
        select 1 where exists (      
    select 1
    from   news_items_approved
    where  publish_date < current_timestamp 
    and    (archive_date is null 
            or archive_date > current_timestamp)
    and    package_id = :package_id
    )           
      </querytext>
</fullquery>

<partialquery name="view_clause_live">      
      <querytext>

    publish_date < current_timestamp
    and (archive_date is null or archive_date > current_timestamp)      
      </querytext>
</partialquery>


<partialquery name="view_clause_archived">      
      <querytext>

    publish_date < current_timestamp
    and archive_date < current_timestamp
      </querytext>
</partialquery>  

<fullquery name="item_list">      
      <querytext>
      
select item_id,
       package_id,
       publish_title,
       publish_lead,
       to_char(news_items_approved.publish_date, 'YYYY-MM-DD HH24:MI:SS') as publish_date_ansi
from   news_items_approved
where  $view_clause   
and    package_id = :package_id
order  by publish_date desc, item_id desc
      </querytext>
</fullquery>

</queryset>
