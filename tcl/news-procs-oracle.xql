<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="news_items_archive.news_item_archive">
      <querytext>

	    begin
	    news.archive(
	        item_id => :id,
	        archive_date => :when);
	    end;

      </querytext>
</fullquery>


<fullquery name="news_items_make_permanent.news_item_make_permanent">
      <querytext>

	    begin
	        news.make_permanent(:id);
	    end;

      </querytext>
</fullquery>


<fullquery name="news_items_delete.news_item_delete">
      <querytext>

	    begin
	        news.del(:id);
	    end;

      </querytext>
</fullquery>


<fullquery name="news__rss_datasource.get_news_items">
        <querytext>
    select * from (
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
     ) where rownum <= $limit
        </querytext>
</fullquery>

</queryset>
