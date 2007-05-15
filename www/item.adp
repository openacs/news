<master>
<property name="title">@title;noquote@</property>
<property name="context">@context;noquote@</property>

<h1>@title;noquote@</h1>
<if @item_exist_p@ eq "0">
   <h2>#news.lt_Could_not_find_the_re#</h2>
</if>
<else>
<include src=news
    item_id=@item_id;noquote@
    publish_title=@publish_title;noquote@
    publish_body=@publish_body;noquote@
    creator_link=@creator_link;noquote@>

<if @comments@ ne "">
  <h2>#news.Comments#</h2>
  @comments;noquote@
</if>

<ul>
<if @comment_link@ not nil>
  <li>@comment_link;noquote@</li>
</if>
<if @edit_link@ not nil>
  <li>@edit_link;noquote@</li>
</if>
</ul>

</else>





