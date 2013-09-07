<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

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
    publish_date,
    NVL(archive_date, sysdate+[parameter::get -parameter ActiveDays -default 14]) as archive_date,
    status
from   
    news_item_full_active    
where  
    item_id = :item_id
      </querytext>
</fullquery>


</queryset>
