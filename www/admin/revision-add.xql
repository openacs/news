<?xml version="1.0"?>
<queryset>

  <fullquery name="item">      
      <querytext>      
select
    item_id, 
    package_id,   
    revision_id,
    publish_title,
    publish_lead,
    publish_body,
    publish_format,
    to_char(publish_date, 'YYYY-MM-DD') as publish_date,
    publish_body,
    to_char(archive_date, 'YYYY-MM-DD') as archive_date
    status
from   
    news_item_full_active    
where  
    item_id = :item_id
      </querytext>
  </fullquery>
  
  <fullquery name="news_item_info">      
      <querytext>
      
    select
        item_name,
        creator_id,
        item_creator
    from
        news_item_full_active
    where item_id = :item_id

      </querytext>
  </fullquery>

</queryset>
