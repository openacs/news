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
    html_p,
    publish_date,
    NVL(archive_date, sysdate+[ad_parameter ActiveDays "news" 14]) as archive_date,
    status
from   
    news_item_full_active    
where  
    item_id = :item_id
      </querytext>
</fullquery>


<fullquery name="get_content">      
      <querytext>
      select  content
from    cr_revisions
where   revision_id = :revision_id
      </querytext>
</fullquery>


</queryset>
