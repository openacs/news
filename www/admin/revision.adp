<master>
<property name="context">@context;noquote@</property>
<property name="title">@title;noquote@</property>


<if @item_exist_p@ eq "0">
   <h3>#news.lt_Could_not_find_corres#</h3>
</if>

<else>
<p>	
<ul>
  <li>#news.Author#: @creator_link@
  <li>#news.Revision_number#: @revision_no@
  <li>#news.Creation_Date#: @creation_date@
  <li>#news.Creation_IP#: @creation_ip@
  <li>#news.Release_Date#: @publish_date@
  <li>#news.Archive_Date#: @archive_date@<nobr>
</ul>
<ul>
  <li><a href="item?item_id=@item_id@">#news.administer_item#</a>
</ul>
<hr>
<p>
<br>
<include src=news
    publish_title="@publish_title;noquote@ (#news.rev# @revision_no;noquote@)"
    publish_body=@publish_body;noquote@
    creator_link=@creator_link;noquote@
>
</else>




























