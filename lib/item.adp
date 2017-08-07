<master>

  <property name="context">@context;literal@</property>
  <property name="doc(title)">@title;literal@</property>


  <if @item_exist_p;literal@ false>
    <p>#news.lt_Could_not_find_the_re#</p>
  </if>
  <else>
    <include src="/packages/news/www/news"
      item_id="@item_id;literal@"
      publish_title="@publish_title;literal@"
      publish_lead="@publish_lead;literal@"
      publish_body="@publish_body;literal@"
      publish_image="@publish_image;literal@"
      creator_link="@creator_link;literal@">

      <if @comments@ ne "">
        <h3>#news.Comments#</h3>
        @comments;noquote@
      </if>

      <ul>
        <li>@comment_link;noquote@</li>
        <if @edit_link@ not nil>
          <li>@edit_link;noquote@</li>
        </if>
      </ul>

  </else>





