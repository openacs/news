<master>
<property name="context">@context;noquote@</property>
<property name="title">@title;noquote@</property>

<if @halt_p@ not nil and @unapproved:rowcount@ gt 0>
  <h3>#news.Error#</h3>
  #news.The_action# <font color=red>@action@</font> #news.lt_cannot_be_applied_to_#
  <ul> 
    <multiple name=unapproved>
     <li><b>@unapproved.publish_title@</b> - @unapproved.creation_date_pretty@
            contributed by @unapproved.item_creator@
	 [ <a href=item?item_id=@unapproved.item_id@><b>#news.manage#</b></a> ]
    </multiple>
  </ul>
  <br>
  #news.lt_Manage_the_items_indi#
</if>	
<else>
  <b>#news.lt_Do_you_really_want_to# <font color=red>@action_pretty@</font><br> #news.lt_on_the_following_news#</b>

  <p><listtemplate name="news_items"></listtemplate></p>

  <form method=post action=process-2>	
    @hidden_vars;noquote@
    <blockquote><input type=submit value="#news.Yes#"></blockquote>
  </form>
</else>
