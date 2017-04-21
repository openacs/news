<?xml version="1.0"?>
<queryset>

<fullquery name="_news__c_db-news-globals.get-cr-news-root-folder">
      <querytext>
        select item_id
        from cr_items
        where parent_id = :p_parent_id
        and   name = 'news'
      </querytext>
</fullquery>
 
<fullquery name="_news__c_get_cr_news_row.get-cr-news-row">
      <querytext>
        select news_id, package_id, archive_date,
               approval_user, approval_date, approval_ip 
        from cr_news
        where news_id = :p_news_id
      </querytext>
</fullquery>

<fullquery name="_news__c_get_cr_revisions_row.get-cr-revisions-row">
      <querytext>
        select item_id, title, description, publish_date, mime_type,
               nls_language, content, content_length
        from cr_revisions
        where revision_id = :p_revision_id
      </querytext>
</fullquery>


<fullquery name="_news__c_get_cr_items_row.get-cr-items-row">
      <querytext>
          select parent_id, name, live_revision, latest_revision,
                 publish_status, content_type
          from cr_items
          where item_id = :p_item_id
      </querytext>
</fullquery>


<fullquery name="_news__check-permissions.get-privileges">
      <querytext>
        select privilege from acs_privileges
      </querytext>
</fullquery>
 
<fullquery name="_news__check-permissions.get-privilege-hierarchies">
      <querytext>
        select privilege, child_privilege from acs_privilege_hierarchy
      </querytext>
</fullquery>

<fullquery name="_news__check-object-type.get-news-type-info">
      <querytext>
        select object_type, supertype
        from acs_object_types
        where object_type = 'news'
      </querytext>
</fullquery>

<fullquery name="_news__check-object-type.get-news-type-attribs">
      <querytext>
        select attribute_name
        from acs_attributes
        where object_type = 'news'
      </querytext>
</fullquery>

<fullquery name="_news__check-object-type.get-news-cr-folder">
      <querytext>
        select folder_id
        from cr_folders
        where label = 'news'
      </querytext>
</fullquery>

<fullquery name="_news__check-views.select-from-news-items-approved">
      <querytext>
        select count(*) from news_items_approved
      </querytext>
</fullquery>

<fullquery name="_news__check-views.select-from-news-items-live-or-submitted">
      <querytext>
        select count(*) from news_items_live_or_submitted
      </querytext>
</fullquery>

<fullquery name="_news__check-views.select-from-news-items-unapproved">
      <querytext>
        select count(*) from news_items_unapproved
      </querytext>
</fullquery>

<fullquery name="_news__check-views.select-from-news-item-revisions">
      <querytext>
        select count(*) from news_item_revisions
      </querytext>
</fullquery>

<fullquery name="_news__check-views.select-from-news-item-unapproved">
      <querytext>
        select count(*) from news_item_unapproved
      </querytext>
</fullquery>

<fullquery name="_news__check-views.select-from-news-item-full-active">
      <querytext>
        select count(*) from news_item_full_active
      </querytext>
</fullquery>

</queryset>
