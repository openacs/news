<?xml version="1.0"?>

<queryset>

<fullquery name="archive_next_week">
      <querytext>
      select DATE(next_day(current_timestamp,'Monday'))
      </querytext>
</fullquery>

<fullquery name="archive_next_month">
      <querytext>
      select DATE(last_day(current_timestamp)) + 1
      </querytext>
</fullquery>

</queryset>
