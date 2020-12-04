<master>
  <property name="context">@context;literal@</property>
  <property name="doc(title)">@title;literal@</property>

<listtemplate name="news"></listtemplate>

<p><include src="/packages/notifications/lib/notification-widget" type="one_news_item_notif"
    object_id="@package_id;literal@"
    pretty_name="News"
    url="@news_url;literal@" >

<if @rss_exists_p;literal@ true>
  <p>
    <a href="@rss_url@" title="#rss-support.Syndication_Feed#">
      <img src="/resources/rss-support/xml.gif" alt="Subscribe via RSS">
      #rss-support.Syndication_Feed#
    </a>
  </p>
</if>
