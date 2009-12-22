<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="itemlist">      
      <querytext>
      
select
    item_id,
    content_item__get_best_revision(item_id) as revision_id,
    content_revision__get_number(news_id) as revision_no,
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
