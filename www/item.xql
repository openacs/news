<?xml version="1.0"?>
<queryset>

  <fullquery name="one_item">      
    <querytext>
      select item_id, live_revision, publish_title, publish_body, publish_format, publish_date,
        '<a href="/shared/community-member?user_id=' || creation_user || '">' || item_creator ||  '</a>' as creator_link
      from news_items_live_or_submitted
      where item_id = :item_id
    </querytext>
  </fullquery>
 
</queryset>
