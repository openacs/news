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
	        news.delete(:id);
	    end;
	
      </querytext>
</fullquery>

 
</queryset>
