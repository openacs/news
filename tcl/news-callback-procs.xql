<?xml version="1.0"?>

<queryset>

  <fullquery name="callback::MergePackageUser::impl::news.update_from_news_approval">
    <querytext>	
      update cr_news
      set approval_user = :to_user_id
      where approval_user = :from_user_id
    </querytext>
  </fullquery>	
  
  <fullquery name="callback::MergeShowUserInfo::impl::news.getaprovednews">
    <querytext>	
      select news_id, lead
      from cr_news 
      where approval_user = :user_id
    </querytext>
  </fullquery>	

  <fullquery name="callback::datamanager::move_new::impl::datamanager.update_news">
<querytext>
    update cr_news
	set package_id = (select package_id	from dotlrn_community_applets where community_id = :selected_community and applet_id = (select applet_id from dotlrn_applets where applet_key = 'dotlrn_news'))
    where news_id in (select revision_id from cr_revisions where item_id = (select item_id from cr_items where live_revision=:object_id));
</querytext>
</fullquery>


<fullquery name="callback::datamanager::move_new::impl::datamanager.update_news_acs_objects_2">

<querytext>
    update acs_objects
    set package_id = (select package_id from dotlrn_community_applets where community_id = :selected_community and applet_id = (select applet_id from dotlrn_applets where applet_key = 'dotlrn_news')), 
        context_id =  (select package_id from dotlrn_community_applets where community_id = :selected_community and applet_id = (select applet_id from dotlrn_applets where applet_key = 'dotlrn_news')) 
    
    where object_id=(select item_id from cr_revisions  where revision_id=:object_id);
</querytext>
</fullquery>

<fullquery name="callback::datamanager::move_new::impl::datamanager.update_news_acs_objects_1">
<querytext>
    update acs_objects
    set package_id = (select package_id 
    	from dotlrn_community_applets
    	where community_id = :selected_community and applet_id = (
	        select applet_id from dotlrn_applets where applet_key = 'dotlrn_news'))
    where object_id in (select revision_id from cr_revisions where item_id = (select item_id from cr_revisions  where revision_id=:object_id));
</querytext>
</fullquery>

<fullquery name="callback::datamanager::copy_new::impl::datamanager.get_news_package_id">
<querytext>
    SELECT b.object_id as package_id 
    FROM acs_objects as a,acs_objects as b  
    WHERE a.context_id=:selected_community and a.object_type='apm_package' and a.object_id=b.context_id and b.title='News';
</querytext>
</fullquery>

<fullquery name="callback::datamanager::copy_new::impl::datamanager.get_news_data">
<querytext>
    SELECT  a.archive_date as archive_date_ansi,
            a.approval_user,
            a.approval_date,
            a.approval_ip,
            a.lead as publish_lead,
            b.creation_user as user_id,
            b.creation_ip,
            b.creation_date
    FROM cr_news as a, acs_objects as b
    WHERE a.news_id=:present_object_id and b.object_id=:present_object_id
</querytext>
</fullquery>

<fullquery name="callback::datamanager::copy_new::impl::datamanager.get_present_new_item">
<querytext>
SELECT context_id as new_item_id
FROM acs_objects
WHERE object_id=:news_id
</querytext>
</fullquery>

<fullquery name="callback::datamanager::copy_new::impl::datamanager.get_live_revision">
<querytext>
SELECT a.live_revision 
FROM cr_items as a,
     acs_objects as b 
WHERE b.object_id=:present_object_id and a.item_id=b.context_id
</querytext>
</fullquery>


<fullquery name="callback::datamanager::copy_new::impl::datamanager.get_news_revisions_data">
<querytext>
SELECT a.revision_id,
       a.publish_date,
       a.content as publish_body,
       a.mime_type,
       a.title as publish_title,
       a.description as revision_log
FROM cr_revisions as a,cr_revisions as b
WHERE b.revision_id=:object_id and b.item_id=a.item_id
ORDER BY a.revision_id

</querytext>
</fullquery>

<fullquery name="callback::datamanager::copy_new::impl::datamanager.create_news_item">      
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

<fullquery name="callback::datamanager::copy_new::impl::datamanager.create_news_item_revision">      
      <querytext>

        select news__revision_new(
            :new_item_id,             -- p_item_id
            :publish_date_ansi,   -- p_publish_date
	        :publish_body,        -- p_text
            :publish_title,       -- p_title
            :revision_log,        -- p_description
            :mime_type,           -- p_mime_type
            :package_id,          -- p_package_id
            :archive_date_ansi,   -- p_archive_date
            :approval_user,       -- p_approval_user
            :approval_date,       -- p_approval_date
            :approval_ip,         -- p_approval_ip
            current_timestamp,       -- p_creation_date
            :creation_ip,         -- p_creation_ip
            :user_id,             -- p_creation_user
            :active_revision_p,    -- p_make_active_revision_p
            :publish_lead        -- p_lead
	);
      </querytext>
</fullquery>



</queryset>
