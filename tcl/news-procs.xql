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
	select package_i
	from cr_news
	where news_id=:object_id
	</querytext>
</fullquery>

</queryset>
