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

<fullquery name="news__rss_datasource.get_news_items">
        <querytext>
        select cn.*,
        ci.item_id,
        cr.content,
        cr.title,
        cr.mime_type,
        cr.description,
        to_char(o.last_modified, 'YYYY-MM-DD HH24:MI:SS') as last_modified
        from cr_news cn,
        cr_revisions cr,
        cr_items ci,
        acs_objects o
        where cn.package_id=:summary_context_id
        and cr.revision_id=cn.news_id
        and cn.news_id=o.object_id
        and cr.item_id=ci.item_id
        and cr.revision_id=ci.live_revision
        order by o.last_modified desc
        limit $limit
        </querytext>
</fullquery>
</queryset>
