<master>
<property name="context">@context@</property>
<property name="title">@title@</property>

<p>
<table border=0>
<tr><th>#news.Title#</th>
     <th>#news.Creation_Date#</th>
     <th>#news.Author#</th>
</tr>
 <multiple name=items>
 <tr><td><a href="revision?item_id=@items.item_id@&revision_id=@items.revision_id@">@items.publish_title@</a></td>
       <td>@items.creation_date@</td>
       <td>@items.item_creator@</td>
 </tr>
 </multiple>
</table>


<p>#news.lt_Select_the_publicatio#


<form action=approve-2 method=post enctype=multipart/form-data>
@hidden_vars@
<input type=hidden name=revision_id value="<multiple name=items>@items.revision_id@ </multiple>">

<table border=1>
<tr>
  <th align=right><font color=red>#news.Publication_Date#</font></th>
  <td colspan=2>@publish_date_select@</td>
</tr>
<tr>
  <th align=right>#news.Archive_Date#</th>
  <td colspan=2>@archive_date_select@ <br>
    <input type=checkbox name=permanent_p value=t>
    <b>#news.never#</b> #news.show_it_permanently#</td>
</tr>
</table>

<p>

<center>
<input type=submit value="#news.Release#">
</center>

</form>






