<?xml version="1.0"?>
<queryset>
  
<rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="_news__i_mount-news-package.get-site-nodes">
  <querytext>
    select node_id, object_id, site_node__url(node_id) as url from site_nodes
  </querytext>
</fullquery>

<fullquery name="_news__i_mount-news-package.package-delete">
  <querytext>
    select apm_package__delete(:p_package_id);
  </querytext>
</fullquery>

<fullquery name="_news__d_mount-news-package.package-delete">
  <querytext>
    select apm_package__delete(:p_package_id);
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-globals.get-cr-root-folder">
  <querytext>
    select content_item_globals.c_root_folder_id;
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-item-create.item-create">
  <querytext>
   select news__new(
      null,
      null,
      current_timestamp, :p_text, null, :p_title, 'text/plain',
      :p_package_id, :p_archive_date, :p_approval_user, :p_approval_date, :p_approval_ip,
      null,
      null,null,
      :p_is_live,null
    );
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-item-delete.item-delete">
  <querytext>
    select news__delete(:p_item_id);
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-revision-create.revision-create">
  <querytext>
    select news__revision_new(
      :p_item_id,
      current_timestamp, :p_text, :p_title,
      :p_description,
      'text/plain', :p_package_id, :p_archive_date, :p_approval_user, :p_approval_date,
                                                                      :p_approval_ip,
      current_timestamp, null, null,
      :p_make_active_revision_p
    );
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-get-live-revision.get-live-revision">
  <querytext>
    select content_item__get_live_revision(:p_item_id);
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-get-latest-revision.get-latest-revision">
  <querytext>
    select content_item__get_latest_revision(:p_item_id);
  </querytext>
</fullquery>
 
<fullquery name="_news__c_db-news-set-approve.set-approve-default">
  <querytext>
    select news__set_approve(:p_revision_id,
                             :p_approve_p,
                             null, null, null, null, null, null);
  </querytext>
</fullquery>
 
<fullquery name="_news__c_db-news-set-approve.set-approve">
  <querytext>
    select news__set_approve(:p_revision_id,
                             :p_approve_p,
                             :p_publish_date,
                             :p_archive_date,
                             :p_approval_user,
                             :p_approval_date,
                             :p_approval_ip,
                             :p_live_revision_p);
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-revision-set-active.revision-set-active">
  <querytext>
    select news__revision_set_active(:p_revision_id);
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-revision-delete.revision-delete">
  <querytext>
    select news__revision_delete(:p_revision_id);
  </querytext>
</fullquery>
 
<fullquery name="_news__c_db-news-make-permanent.make-permanent">
  <querytext>
    select news__make_permanent(:p_item_id);
  </querytext>
</fullquery>
 
<fullquery name="_news__c_db-news-archive.archive-default">
  <querytext>
    select news__archive(:p_item_id);
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-archive.archive">
  <querytext>
    select news__archive(:p_item_id, :p_archive_date);
  </querytext>
</fullquery>

<fullquery name="_news__c_db-news-status.get-status">
  <querytext>
     select news__status(to_timestamp(:p_publish_date, 'YYYY-MM-DD'), to_timestamp(:p_archive_date, 'YYYY-MM-DD'));
  </querytext>
</fullquery>

<fullquery name="_news__db-check-news-create.news-name">
  <querytext>
     select news__name(:p_news_id);
  </querytext>
</fullquery>

 
</queryset>
