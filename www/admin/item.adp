<master src="master">
<property name="context_bar">@context_bar@</property>
<property name="title">@title@</property>

<p>
<dd><li><a href=revision-add?item_id=@item_id@>Add a new revision</a>	


@hidden_vars@

   <table width=100% border=0>
    <tr>
     <th>Revision #</th>
     <th>Active Revision</th>
     <th>Title</th>
     <th>Author</th>
     <th>Log Entry</th>
     <th>Status</th>
    </tr>

   <multiple name=item>
    <if @item.rownum@ odd>
    <tr>
    </if>
    <else>
     <tr bgcolor=e0e0e0>
    </else>
      <td align=center> 
       <a href=revision?item_id=@item.item_id@&revision_id=@item.revision_id@>
        <%= [expr @item:rowcount@ - @item.rownum@ +1] %>  </td>
       </a> 

      <td align=center> 
       <if @item.item_live_revision_id@ eq @item.revision_id@>
        active
       </if>
       <else>
        <a href="revision-set-active?item_id=@item_id@&new_rev_id=@item.revision_id@">
        make active
      </else>
      </td>

      <td align=center>
        <a href=revision?item_id=@item.item_id@&revision_id=@item.revision_id@>@item.publish_title@<a/></td>
      <td align=center><a href=/shared/community-member?user_id=@item.creation_user@>@item.item_creator@</a></td>
      <td>@item.log_entry@</td>
      <td>@item.status@
          <if @item.approval_needed_p@ ne 0>
              | <a href=approve?n_items=@item.item_id@&revision_id=@item.revision_id@&return_url=item?item_id=@item.item_id@>approve</a>
          </if>
	  <else>
              | <a href=revoke?revision_id=@item.revision_id@&item_id=@item_id@>revoke</a>
	  </else>
      </td>
    </tr>
   </multiple>

  </table>

