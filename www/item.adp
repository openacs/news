<master>

  <property name="context">@context;noquote@</property>
  <property name="title">@title;noquote@</property>


  <if @item_exist_p@ false>
    <p>#news.lt_Could_not_find_the_re#</p>
  </if>
  <else>
    <include src=news
      item_id=@item_id;noquote@
      publish_title=@publish_title;noquote@
      publish_lead=@publish_lead@
      publish_body=@publish_body;noquote@
      publish_image=@publish_image@
      creator_link=@creator_link;noquote@>

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





