<?xml version="1.0"?>
<queryset>

<fullquery name="unapproved_list">      
      <querytext>
      
    select    
        item_id,
        publish_title,
        creation_date,
        item_creator
    from 
        news_items_unapproved
    where 
        item_id in ([join $bind_id_list ","])
      </querytext>
</fullquery>

 
</queryset>
