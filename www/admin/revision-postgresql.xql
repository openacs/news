<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="one_item">      
      <querytext>
      
    select item_id,
           revision_id,
           content_revision__get_number(:revision_id) as revision_no,
           publish_title,
           publish_lead,
           publish_body,
           publish_format,
           publish_date,
           archive_date,
           creation_ip,
           creation_date,
           '<a href="/shared/community-member?user_id=' || creation_user || '">' || item_creator ||  '</a>' as creator_link
    from   news_item_revisions
    where  item_id = :item_id
    and    revision_id = :revision_id
      </querytext>
</fullquery>

 
</queryset>
