<master>
<property name="doc(title)">@title;noquote@</property>
<property name="context">@context;noquote@</property>

<h1>@title;noquote@</h1>

<include src="/packages/news/lib/news"
    publish_title = "@publish_title;noquote@"
    publish_body = "@publish_body;noquote@"
    publish_format = "@publish_format;noquote@"
    creator_link = "@creator_link;noquote@">

<if @comments@ ne "">
  <h2>#news.Comments#</h2>
  @comments;noquote@
</if>

<if @footer_links@ not nil>
  <div class="action-list">
    <ul>
      <li>@footer_links;noquote@</li>
    </ul>
  </div>
</if>
