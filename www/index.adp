<master>
<property name="context">@context;noquote@</property>
<property name="title">@title;noquote@</property>

<if @news_admin_p@ ne 0>
  <p>
    <table width="100%">
     <tr>
      <th align=right>
       [<a href="admin/">#news.Administer#</a>]
      </th>
     </tr>
    </table>	
</if>


<if @news_items:rowcount@ eq 0>
 <p><i>#news.lt_There_are_no_news_ite#</i>
</if>
<else>
<p>
 <if @allow_search_p@ eq "1" and @search_url@ ne "">
 <table>
  <tr valign=top> 
      <td>#news.Search#</td>
      <td > 
      <form action=@search_url@search>
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
  @pagination_link;noquote@
</center>
</else>

<p>
<if @news_admin_p@ ne 0> 
<ul>
  <li><a href=item-create>#news.Create_a_news_item#</a>
</ul>  
</if>
<else>
   <if @news_create_p@ ne 0> 
    <ul>
     <li><a href=item-create>#news.Submit_a_news_item#</a>
    </ul>
   </if>
</else>

<if @view_switch_link@ ne "">
<ul>
  <li>@view_switch_link;noquote@
</ul>
</if>




