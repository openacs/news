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
    html_p,
    publish_date,
    publish_body,
    coalesce(archive_date, current_timestamp+[ad_parameter ActiveDays "news" 14]) as archive_date,
    status
from   
    news_item_full_active    
where  
    item_id = :item_id
      </querytext>
</fullquery>

 
</queryset>
