<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="news_item_approve_publish">      
      <querytext>
      
	begin
        news.set_approve(
	    approve_p       => 't',
	    revision_id     => :id,
	    publish_date    => :publish_date_ansi,
            archive_date    => :archive_date_ansi,
            approval_user   => :approval_user,
            approval_date   => :approval_date,
            approval_ip     => :approval_ip,
            live_revision_p => :live_revision_p
         );
    end;
    
      </querytext>
</fullquery>

 
</queryset>
