<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="itemlist">      
      <querytext>
      
select
    item_id,
    content_item.get_best_revision(item_id) as revision_id,
    content_revision.get_number(news_id) as revision_no,
    publish_title,
    to_char(publish_date, 'YYYY-MM-DD HH24:MI:SS') as publish_date_ansi,
    to_char(archive_date, 'YYYY-MM-DD HH24:MI:SS') as archive_date_ansi,
    creation_user,
    item_creator,
    package_id,
    status
from 
    news_items_live_or_submitted
where 
    package_id = :package_id    
    $view_option
order by item_id desc
      </querytext>
</fullquery>

 
</queryset>
