<master>

<property name="context">@context;noquote@</property>
<property name="title">@title;noquote@</property>


<if @item_exist_p@ eq "0">
   <h3>#news.lt_Could_not_find_the_re#</h3>
</if>
<else>
<include src=news
    item_id=@item_id;noquote@
    publish_title=@publish_title;noquote@
    publish_body=@publish_body;noquote@
    creator_link=@creator_link;noquote@>

<if @comments@ ne "">
<h3>#news.Comments#</h3>
@comments@
</if>

<if @comment_link@ ne "">
<ul>
<li>
@comment_link@
</ul>
</if>

</else>





