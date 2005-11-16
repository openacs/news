<?xml version="1.0"?>

<queryset>

<fullquery name="news__url.get">
      <querytext>
	select distinct r.item_id, n.package_id
        from cr_revisions r, cr_news n
        where (r.revision_id=:object_id or r.item_id = :object_id)
          and r.revision_id = n.news_id
      </querytext>
</fullquery>

<fullquery name="news__last_updated.get_last_updated">
        <querytext>
        select max(o.last_modified)
        from acs_objects o, cr_news n
        where n.package_id=:package_id
        and o.object_id=n.news_id
        </querytext>
</fullquery>

<fullquery name="news_get_image_id.img">
      <querytext>
        SELECT live_revision AS image_id
        FROM cr_items
        WHERE content_type = 'image' AND parent_id = :item_id
      </querytext>
</fullquery>

<fullquery name="news_get_package_id.get_news_package_id">
<querytext>
    SELECT b.object_id as package_id 
    FROM acs_objects as a,acs_objects as b  
    WHERE a.context_id=:community_id and a.object_type='apm_package' and a.object_id=b.context_id and b.title='News';
</querytext>
</fullquery>


<fullquery name="news_create_new.create_news_item">      
      <querytext>
    select news__new(
        null,               -- p_item_id
        null,               -- p_locale
        :publish_date_ansi, -- p_publish_date
        :publish_body,      -- p_text
        null,               -- p_nls_language
        :publish_title,     -- p_title
        :mime_type,         -- p_mime_type
        :package_id,        -- p_package_id
        :archive_date_ansi, -- p_archive_date
        :approval_user,     -- p_approval_user
        :approval_date,     -- p_approval_date
        :approval_ip,       -- p_approval_ip
        null,               -- p_relation_tag
        :creation_ip,       -- p_creation_ip
        :user_id,           -- p_creation_user
        :live_revision_p,   -- p_is_live_p
        :publish_lead       -- p_lead
    );
      </querytext>
</fullquery>


</queryset>
