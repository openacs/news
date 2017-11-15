<?xml version="1.0"?>
<queryset>

<partialquery name="max_age_filter">
  <querytext>
    AND CURRENT_DATE - DATE(publish_date) < $max_age
  </querytext>
</partialquery>

</queryset>