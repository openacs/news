<?xml version="1.0"?>
<queryset>

<rdbms><type>oracle</type><version></version></rdbms>

<fullquery name="ls">
<querytext>
SELECT r.*
FROM 
(SELECT
  item_id,
  publish_title AS title,
  '' AS lead,
  publish_date
 FROM
  news_items_approved
 WHERE
  package_id = :package_id 
  $max_age_filter
  AND (archive_date IS NULL OR archive_date > sysdate)
 ORDER BY
  publish_date DESC, item_id DESC
) r
WHERE rownum <= $n 
</querytext>
</fullquery>

</queryset>
