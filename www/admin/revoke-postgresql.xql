<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="news_item_revoke">      
      <querytext>

        select news__set_approve(
            :revision_id,      -- p_revision_id
            'f',               -- p_approve_p
	    null,              -- p_publish_date
	    null,              -- p_archive_date
	    null,              -- p_approval_user
	    current_timestamp, -- p_approval_date
	    null,              -- p_approval_ip
	    't'                -- p_live_revision_p
        );

      </querytext>
</fullquery>

 
</queryset>
