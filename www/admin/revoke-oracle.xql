<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="news_item_revoke">      
      <querytext>
      
    begin
        news.set_approve(
            approve_p    => 'f',
            revision_id  => :revision_id
        );
    end;

      </querytext>
</fullquery>

 
</queryset>
