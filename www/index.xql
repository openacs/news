<?xml version="1.0"?>

<queryset>

<fullquery name="item_list">      
      <querytext>
      
select item_id,
       package_id,
       publish_title,
       publish_date
from   news_items_approved
where  $view_clause   
and    package_id = :package_id
order  by publish_date desc, item_id desc
      </querytext>
</fullquery>


</queryset>
