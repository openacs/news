<?xml version="1.0"?>
<queryset>

<rdbms><type>postgresql</type><version>7.3</version></rdbms>

<fullquery name="ls"><querytext>
SELECT
  item_id,
  publish_title AS title,
  '' AS lead,
  publish_date
FROM
  news_items_approved
WHERE
  package_id = :package_id $max_age_filter
  AND (archive_date IS NULL OR archive_date > now())
ORDER BY
  publish_date DESC, item_id DESC
LIMIT $n
</querytext></fullquery>

</queryset>
