<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="news_items_archive.news_item_archive">      
      <querytext>

          select news__archive(
	      :id, -- item_id
	      :when -- archive_date
	  );
	
      </querytext>
</fullquery>

 
<fullquery name="news_items_make_permanent.news_item_make_permanent">      
      <querytext>

          select news__make_permanent(:id);
	
      </querytext>
</fullquery>

 
<fullquery name="news_items_delete.news_item_delete">      
      <querytext>

          select news__delete(:id);
	
      </querytext>
</fullquery>


<fullquery name="news_util_get_url.get_url_stub">
      <querytext>

	  select site_node__url(node_id) as url_stub
          from site_nodes
          where object_id=:package_id      
          limit 1
	
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
 
<fullquery name="news_revision_set_image_id.set_image_rel">
        <querytext>
select acs_rel__new(null, 'relationship', :revision_id, :image_id, null, :creation_user, :peeraddr)
        </querytext>
</fullquery>
</queryset>
