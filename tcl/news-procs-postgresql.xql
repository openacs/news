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
	
      </querytext>
</fullquery>

 
</queryset>
