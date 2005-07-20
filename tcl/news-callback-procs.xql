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

</queryset>
