<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="create_news_item_revision">      
      <querytext>

        select news__revision_new(
            :item_id,             -- p_item_id
            :publish_date_ansi,   -- p_publish_date
	    :publish_body,        -- p_text
            :publish_title,       -- p_title
            :revision_log,        -- p_description
            :mime_type,           -- p_mime_type
            [ad_conn package_id], -- p_package_id
            :archive_date_ansi,   -- p_archive_date
            :approval_user,       -- p_approval_user
            :approval_date,       -- p_approval_date
            :approval_ip,         -- p_approval_ip
	    current_timestamp,    -- p_creation_date
            :creation_ip,         -- p_creation_ip
            :creation_user,       -- p_creation_user
            :active_revision_p,    -- p_make_active_revision_p
            :publish_lead        -- p_lead
	);
      </querytext>
</fullquery>


</queryset>
