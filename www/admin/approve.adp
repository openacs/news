<master>
<property name="context">@context;literal@</property>
<property name="doc(title)">@title;literal@</property>

<p>
<table border="0">
<tr><th>#news.Title#</th>
     <th>#news.Creation_Date#</th>
     <th>#news.Author#</th>
</tr>
 <multiple name=items>
  <if @items.rownum@ odd>
  <tr class="odd">
  </if>
  <else>
  <tr class="even">
  </else>
  <td><a href="revision?item_id=@items.item_id@&amp;revision_id=@items.revision_id@">@items.publish_title@</a></td>
       <td>@items.creation_date@</td>
       <td>@items.item_creator@</td>
 </tr>
 </multiple>
</table>


<p>#news.lt_Select_the_publicatio#


<form action="approve-2" method="post" enctype="multipart/form-data">
@hidden_vars;noquote@
<multiple name="items">
<input type="hidden" name="revision_id" value="@items.revision_id@">
</multiple>
<p class="formLabel"><label for="publish_date">#news.Release_Date#</label></p>
<p class="formWidget"><input name="publish_date" type="date" value="@publish_date@"></p>

<p class="formLabel"><label for="archive_date">#news.Archive_Date#</p>
<p class="formWidget"><input name="archive_date" type="date" value="@archive_date@"><br>
<input type="checkbox" name="permanent_p" value="t" id="never"> <strong><label for="never">#news.never#</label></strong> #news.show_it_permanently#</p>


<p>

<input type="submit" value="#news.Release#">
</p>
</form>






