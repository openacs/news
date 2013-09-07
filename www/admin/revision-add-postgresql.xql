<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

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
    to_char(coalesce(archive_date, current_timestamp + interval '[parameter::get -parameter ActiveDays -default 14] days'), 'YYYY-MM-DD') as archive_date,
    status
from   
    news_item_full_active    
where  
    item_id = :item_id
      </querytext>
</fullquery>

 
</queryset>
