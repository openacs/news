<master src="master">
<property name="context">@context@</property>
<property name="title">@title@</property>


<if @item_exist_p@ eq "0">
   <h3>Could not find corresponding revision to requested news item</h3>
</if>

<else>
<p>	
<ul>
  <li>Author: @creator_link@
  <li>Revision Number: @revision_no@
  <li>Creation Date: @creation_date@
  <li>Creation IP: @creation_ip@
  <li>Release Date: @publish_date@
  <li>Archive Date: @archive_date@<nobr>
</ul>
<ul>
  <li><a href="item?item_id=@item_id@">administer item</a>
</ul>
<hr>
<p>
<br>
<include src=news
    publish_title="@publish_title@ (rev. @revision_no@)"
    publish_body=@publish_body@
    creator_link=@creator_link@
>
</else>
























