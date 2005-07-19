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

</queryset>
