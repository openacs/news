<master src="master">
<property name="context">@context@</property>
<property name="title">@title@</property>

<p>

<if @halt_p@ not nil and @unapproved:rowcount@ gt 0>
  <h3>Error</h3>
  The action <font color=red>@action@</font> cannot be applied to the following item(s):
  <ul> 
    <multiple name=unapproved>
     <li><b>@unapproved.publish_title@</b> - @unapproved.creation_date@
            contributed by @unapproved.item_creator@
	 [ <a href=item?item_id=@unapproved.item_id@><b>manage</b></a> ]
    </multiple>
  </ul>
<br>
Manage the items individually for approval first.
</if>	

<else>
<p>
 <b>Do you really want to perform this action: <font color=red>@action@</font><br> on
 the following news item(s)?</b>
 <p>
  <table border=0>
  <tr><th>Title<th>Creation Date<th>Author</tr>
  <multiple name=news_items>
    <tr><td><li><a href=revision?item_id=@news_items.item_id@&revision_id=@news_items.revision_id@>@news_items.publish_title@</a></td>
        <td>@news_items.creation_date@</td>
	<td>@news_items.item_creator@</td>
    </tr>
  </multiple>
  </table>
	
<center>   
  <form method=post action=process-2>	
   @hidden_vars@
   <input type=submit value="Yes">
  </form>
</center>
</else>






