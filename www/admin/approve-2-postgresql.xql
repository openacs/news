<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="news_item_approve_publish">      
      <querytext>

        select news__set_approve(
            :id,                -- p_revision_id
            't',                -- p_approve_p
	    :publish_date,      -- p_publish_date
	    :archive_date,      -- p_archive_date
	    :approval_user,     -- p_approval_user
	    :approval_date,     -- p_approval_date
	    :approval_ip,       -- p_approval_ip
	    :live_revision_p    -- p_live_revision_p
        );
    
      </querytext>
</fullquery>

 
</queryset>
