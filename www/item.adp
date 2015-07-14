<master>
<property name="doc(title)">@title;literal@</property>
<property name="context">@context;literal@</property>

<h1>@title;noquote@</h1>

<include src="/packages/news/lib/news"
    publish_title="@publish_title;literal@"
    publish_body="@publish_body;literal@"
    publish_format="@publish_format;literal@"
    creator_link="@creator_link;literal@">

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
