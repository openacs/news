<?xml version="1.0"?>
<queryset>

<fullquery name="item_list">      
      <querytext>
      
        select    
        item_id, 
        $revision_select
        publish_title,
        creation_date,
        item_creator
    from 
        news_items_live_or_submitted
    where 
        item_id in ([join $bind_id_list ","])
      </querytext>
</fullquery>

 
</queryset>
