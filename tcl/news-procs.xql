<?xml version="1.0"?>

<queryset>

<fullquery name="news__url.get">
      <querytext>
	select distinct r.item_id, n.package_id
        from cr_revisions r, cr_news n
        where (r.revision_id=:object_id or r.item_id = :object_id)
          and r.revision_id = n.news_id
      </querytext>
</fullquery>

<fullquery name="news__last_updated.get_last_updated">
        <querytext>
        select max(o.last_modified)
        from acs_objects o, cr_news n
        where n.package_id=:package_id
        and o.object_id=n.news_id
        </querytext>
</fullquery>

<fullquery name="news_get_image_id.img"><querytext>
SELECT live_revision AS image_id
FROM cr_items
WHERE content_type = 'image' AND parent_id = :item_id
</querytext></fullquery>

  <fullquery name="callback::MergePackageUser::impl::news.update_from_news_approval">
    <querytext>	
      update cr_news
      set approval_user = :to_user_id
      where approval_user = :from_user_id
    </querytext>
  </fullquery>	
  
  <fullquery name="callback::MergeShowUserInfo::impl::news.getaprovednews">
    <querytext>	
      select news_id, lead
      from cr_news 
      where approval_user = :user_id
    </querytext>
  </fullquery>	

</queryset>
