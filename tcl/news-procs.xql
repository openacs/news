<?xml version="1.0"?>

<queryset>

<fullquery name="news__url.get">
      <querytext>
	select r.item_id, n.package_id
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

</queryset>
