<?xml version="1.0"?>

<queryset>

<fullquery name="news__url.get_item_id">
      <querytext>

	select item_id
        from cr_revisions
        where revision_id=:object_id

      </querytext>
</fullquery>

<fullquery name="news__url.get_package_id">
	<querytext>
	select package_id
	from cr_news
	where news_id=:object_id
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

</queryset>
