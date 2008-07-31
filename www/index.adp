<master>
  <property name="context">@context;noquote@</property>
  <property name="title">@title;noquote@</property>

    <listtemplate name="news"></listtemplate>

  <if @notification_chunk@ not nil>
    <p>@notification_chunk;noquote@</p>
  </if>
  <if @rss_exists@ true>
    <p>
      <a href="@rss_url@" title="#rss-support.Syndication_Feed#">
        <img src="/resources/rss-support/xml.gif" alt="Subscribe via RSS">
        #rss-support.Syndication_Feed#
      </a>
    </p>
  </if>
