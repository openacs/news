<master>
<property name="context">@context@</property>
<property name="title">@title@</property>

<p>

<if @halt_p@ not nil and @unapproved:rowcount@ gt 0>
  <h3>#news.Error#</h3>
  #news.The_action# <font color=red>@action@</font> #news.lt_cannot_be_applied_to_#
  <ul> 
    <multiple name=unapproved>
     <li><b>@unapproved.publish_title@</b> - @unapproved.creation_date@
            contributed by @unapproved.item_creator@
	 [ <a href=item?item_id=@unapproved.item_id@><b>#news.manage#</b></a> ]
    </multiple>
  </ul>
<br>
#news.lt_Manage_the_items_indi#
</if>	

<else>
<p>
 <b>#news.lt_Do_you_really_want_to# <font color=red>@action@</font><br> #news.lt_on_the_following_news#</b>
 <p>
  <table border=0>
  <tr><th>#news.Title#<th>#news.Creation_Date#<th>#news.Author#</tr>
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
   <input type=submit value="#news.Yes#">
  </form>
</center>
</else>











