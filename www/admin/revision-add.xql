<?xml version="1.0"?>
<queryset>

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


<fullquery name="get_content">      
      <querytext>
      select  content
from    cr_revisions
where   revision_id = :revision_id
      </querytext>
</fullquery>

 
</queryset>
