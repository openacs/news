<master>
<property name="context">@context@</property>
<p>
<property name="title">@title@</property>

<ul>
  <li><a href="../item-create">#news.Create_a_news_item#</a>
</ul>

<p>

@view_link@
<if @news_items:rowcount@ eq 0>
 <i>#news.lt_There_are_no_items_av#</i><p>
</if>
<else>
<p>	
 <table border=0>
   <tr><td>
    <form method=post action=process>
      <table border=0 cellspacing=5 cellpadding=5>
        <tr>
          <th>#news.Select#</th>
          <th>ID#</th>
          <th>#news.Title#</th>
          <th>#news.Author#</th>
          <th>#news.Release_Date#</th>
          <th>#news.Archive_Date#</th>
          <th>#news.Status#</th>
        </tr>
        <multiple name=news_items>
        <if @news_items.rownum@ odd>
        <tr>
        </if>
        <else>
        <tr bgcolor=#eeeeee>
        </else>
          <td align=center bgcolor=white><input type=checkbox name=n_items  value=@news_items.item_id@></td>
          <td align=left><a href=item?item_id=@news_items.item_id@>@news_items.item_id@</a></td>
          <td>@news_items.publish_title@ (#news.rev# @news_items.revision_no@) [<a href=revision-add?item_id=@news_items.item_id@>#news.revise#</a>]</td>
          <td><a href=/shared/community-member?user_id=@news_items.creation_user@>@news_items.item_creator@</a></td>
          <td align=left>@news_items.publish_date@</td>
          <td align=left>@news_items.archive_date@</td>
          <td>@news_items.status@</td>
         </tr>
         </multiple>
       </table>
      </td>
   </tr>
   <tr>
    <td>
     #news.lt_Click_on_item_ID_to_a#<br>
     #news.lt_Click_on_revise_to_ed#
    </td>
   </tr>
   <tr>
     <td>
     <if @view@ ne "all">
      #news.lt_Do_the_following_to_t#
      <select name=action>
	@select_actions@
       <option value=delete>#news.Delete#</option>	
       </select>
       <input type=submit value=#news.Go#>
     </if>
       </form>
     </td>
   </tr> 
 </table>
</else>









