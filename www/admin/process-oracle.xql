<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="item_list">      
      <querytext>
      
    select
        item_id,
        content_item.get_best_revision(item_id) as revision_id,
        package_id,
        publish_title,
        creation_date,
        item_creator
    from 
        news_items_live_or_submitted
    where
        item_id in ([join  $bind_id_list ","])
      </querytext>
</fullquery>

 
</queryset>
