<master src="master">
<property name="context_bar">@context_bar@</property>
<property name="title">@title@</property>

<if @news_admin_p@ ne 0>
  <p>
    <table width=100%>
     <tr>
      <th align=right>
       [<a href="admin/">Administer</a>]
      </th>
     </tr>
    </table>	
</if>


<if @news_items:rowcount@ eq 0>
 <p><i>There are no news items available.</i>
</if>
<else>
<p>
 <if @allow_search_p@ eq "1">
 <table>
  <tr valign=top> 
      <td>Search</td>
      <td > 
      <form action=<%= [news_util_get_url search] %>search>
      <input type=text  name=q value="">
      </form> </td>
  </tr>
 </table>
 </if>

<ul>
 <multiple name=news_items>
   <li> @news_items.publish_date@: <a href=item?item_id=@news_items.item_id@>@news_items.publish_title@</a>
 </multiple>
</ul>


<p>

<center>
  @pagination_link@
</center>
</else>

<p>
<if @news_admin_p@ ne 0> 
<ul>
  <li><a href=item-create>Create a news item</a>
</ul>  
</if>
<else>
   <if @news_create_p@ ne 0> 
    <ul>
     <li><a href=item-create>Submit a news item</a>
    </ul>
   </if>
</else>

<if @view_switch_link@ ne "">
<ul>
  <li>@view_switch_link@
</ul>
</if>