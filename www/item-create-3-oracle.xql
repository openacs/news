<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="create_news_item">      
      <querytext>
      
begin
:1 := news.new(
title           => :publish_title,
lead            => :publish_lead,
publish_date    => :publish_date_ansi, 
archive_date    => :archive_date_ansi,
mime_type       => :mime_type,        
package_id      => :package_id,       
approval_user   => :approval_user,     
approval_date   => :approval_date,      
approval_ip     => :approval_ip,   
creation_ip     => :creation_ip,    
creation_user   => :user_id,     
is_live_p       => :live_revision_p    
);
end;
      </querytext>
</fullquery>

 
<fullquery name="content_add">      
      <querytext>
      
update cr_revisions
set    content = empty_blob()
where  revision_id = :news_id
returning content into :1
      </querytext>
</fullquery>

 
</queryset>
