<?xml version="1.0"?>
<queryset>

<fullquery name="item_revs_list">      
      <querytext>
      
select 
    item_id,
    revision_id,
    live_revision as item_live_revision_id,
    publish_title,
    log_entry,
    package_id,
    approval_needed_p,
    creation_user,
    item_creator,
    status
from 
    news_item_revisions
where 
    item_id = :item_id
order by revision_id desc

      </querytext>
</fullquery>

 
</queryset>
