<?xml version="1.0"?>
<queryset>
  
<rdbms><type>oracle</type><version>8.1.6</version></rdbms>
 
<fullquery name="_news__i_mount-news-package.get-site-nodes">
  <querytext>
    select node_id, object_id, site_node.url(node_id) as url from site_nodes
  </querytext>
</fullquery>

<fullquery name="_news__i_mount-news-package.package-delete">
  <querytext>
    begin
      apm_package.del(:p_package_id);
    end;
  </querytext>
</fullquery>

<fullquery name="_news__d_mount-news-package.package-delete">
  <querytext>
    begin
      apm_package.del(:p_package_id);
    end;
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-globals.get_cr-root-folder">
  <querytext>
    select content_item.get_root_folder from dual
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-item-create.item-create">
  <querytext>
    begin
      :1 := news.new(
        text => :p_text,
        title => :p_title,
        package_id => :p_package_id,
        archive_date => :p_archive_date,
        approval_user => :p_approval_user,
        approval_date => :p_approval_date,
        approval_ip   => :p_approval_ip,
        is_live_p     => :p_is_live
      );
    end;
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-revision-delete.revision-delete">
  <querytext>
    begin
      news.revision_delete(:p_revision_id);
    end;
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-revision-create.revision-create">
  <querytext>
    begin
      :1 := news.revision_new(
        item_id => :p_item_id,
        text => :p_text,
        title => :p_title,
        description => :p_description,
        package_id => :p_package_id,
        archive_date =>  :p_archive_date,
        approval_user => :p_approval_user,
        approval_date => :p_approval_date,
        approval_ip   => :p_approval_ip,
        make_active_revision_p => :p_make_active_revision_p
      );
    end;
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-get-live-revision.get-live-revision">
  <querytext>
    begin
      :1 := content_item.get_live_revision(:p_item_id);
    end;
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-get-latest-revision.get-latest-revision">
  <querytext>
    begin
      :1 := content_item.get_latest_revision(:p_item_id);
    end;
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-set-approve.set-approve-default">
  <querytext>
      begin
        news.set_approve(revision_id =>     :p_revision_id,
                         approve_p =>       :p_approve_p);
      end;
  </querytext>
</fullquery>
 
<fullquery name="_news__c_db-news-set-approve.set-approve">
  <querytext>
      begin
        news.set_approve(revision_id =>     :p_revision_id,
                         approve_p =>       :p_approve_p,
                         publish_date =>    :p_publish_date,
                         archive_date =>    :p_archive_date,
                         approval_user =>   :p_approval_user,
                         approval_date =>   :p_approval_date,
                         approval_ip   =>   :p_approval_ip,
                         live_revision_p => :p_live_revision_p);
      end;
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-revision-set-active.revision-set-active">
  <querytext>
    begin
      news.revision_set_active(:p_revision_id);
    end;
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-item-delete.item-delete">
  <querytext>
    begin
      news.del(:p_item_id);
    end;
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-make-permanent.make-permanent">
  <querytext>
    begin
      news.make_permanent(:p_item_id);
    end;
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-archive.archive">
  <querytext>
    begin
      news.archive(item_id => :p_item_id,
                   archive_date => :p_archive_date);
    end;
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-archive.archive-default">
  <querytext>
    begin
      news.archive(item_id => :p_item_id);
    end;
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-status.get-status">
  <querytext>
    begin
      :1 := news.status(to_date(:p_publish_date, 'YYYY-MM-DD'), to_date(:p_archive_date, 'YYYY-MM-DD'));
    end;
  </querytext>
</fullquery>

<fullquery name="_news__db-check-news-create.news-name">
  <querytext>
    begin
      :1 := news.name(news_id => :p_news_id);
    end;
  </querytext>
</fullquery>

</queryset>
