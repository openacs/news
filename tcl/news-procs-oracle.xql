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


<fullquery name="news_util_get_url.get_url_stub">
      <querytext>

	    select site_node.url(node_id) as url_stub
            from site_nodes
            where object_id=:package_id      
            and rownum = 1
	
      </querytext>
</fullquery>

 
</queryset>
