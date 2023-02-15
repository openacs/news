<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="create_news_item_revision">      
      <querytext>
      
    begin
        :1 := news.revision_new(
            item_id       => :item_id,
            publish_date  => :publish_date,
            title         => :publish_title,   
            lead          => :publish_lead,
            description   => :revision_log,
            mime_type     => :mime_type,
            package_id    => [ad_conn package_id],
            archive_date  => :archive_date,
            approval_user => :approval_user,
            approval_date => :approval_date,
            approval_ip   => :approval_ip,
            creation_ip   => :creation_ip,
            creation_user => :creation_user,
            make_active_revision_p => :active_revision_p);
    end;
      </querytext>
</fullquery>

 
<fullquery name="content_add">      
      <querytext>
      
    update cr_revisions
    set    content = empty_blob()
    where  revision_id = :revision_id
    returning content into :1
      </querytext>
</fullquery>

 
</queryset>
