<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="one_item">      
      <querytext>
      
    select item_id,
           revision_id,
           content_revision.get_number(:revision_id) as revision_no,
           publish_title,
           html_p,
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


<fullquery name="get_content">      
      <querytext>
      select  content
    from    cr_revisions
    where   revision_id = :revision_id
      </querytext>
</fullquery>

</queryset>
