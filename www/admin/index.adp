<master src="master">
<property name="context_bar">@context_bar@</property>
<p>
<property name="title">@title@</property>

<ul>
  <li><a href="../item-create">Create a news item</a>
  <li><a href="/permissions/one?object_id=@package_id@">Set permissions</a>
  <li><a href="/admin/site-map/parameter-set?package_id=@package_id@">Set parameters</a>
</ul>

<p>

@view_link@
<if @news_items:rowcount@ eq 0>
 <i>There are no items available.</i><p>
</if>
<else>
<p>	
 <table border=0>
   <tr><td>
    <form method=post action=process>
      <table border=0 cellspacing=5 cellpadding=5>
        <tr>
          <th>Select</th>
          <th>ID#</th>
          <th>Title</th>
          <th>Author</th>
          <th>Release Date</th>
          <th>Archive Date</th>
          <th>Status</th>
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
          <td>@news_items.publish_title@ (rev. @news_items.revision_no@) [<a href=revision-add?item_id=@news_items.item_id@>revise</a>]</td>
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
     Click on item ID# to approve/revoke an item.<br>
     Click on "revise" to edit an item.
    </td>
   </tr>
   <tr>
     <td>
     <if @view@ ne "all">
      Do the following to the selected items:
      <select name=action>
	@select_actions@
       <option value=delete>Delete</option>	
       </select>
       <input type=submit value=Go>
     </if>
       </form>
     </td>
   </tr> 
 </table>
</else>



