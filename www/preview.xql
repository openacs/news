<?xml version="1.0"?>
<queryset>

<fullquery name="creator">      
      <querytext>
      
select first_names || ' ' || last_name 
from   cc_users 
where  user_id = :user_id
      </querytext>
</fullquery>

<fullquery name="img_item_id"><querytext>
SELECT item_id AS img_item_id FROM cr_items
WHERE content_type = 'image' AND parent_id = :item_id
</querytext></fullquery>
 
</queryset>
