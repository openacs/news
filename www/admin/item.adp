<master>
<property name="context">@context@</property>
<property name="title">@title@</property>

<p>
<dd><li><a href=revision-add?item_id=@item_id@>#news.Add_a_new_revision#</a>	


@hidden_vars@

   <table width=100% border=0>
    <tr>
     <th>Revision #</th>
     <th>#news.Active_Revision#</th>
     <th>#news.Title#</th>
     <th>#news.Author#</th>
     <th>#news.Log_Entry#</th>
     <th>#news.Status#</th>
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
        #news.active#
       </if>
       <else>
        <a href="revision-set-active?item_id=@item_id@&new_rev_id=@item.revision_id@">
        #news.make_active#
      </else>
      </td>

      <td align=center>
        <a href=revision?item_id=@item.item_id@&revision_id=@item.revision_id@>@item.publish_title@<a/></td>
      <td align=center><a href=/shared/community-member?user_id=@item.creation_user@>@item.item_creator@</a></td>
      <td>@item.log_entry@</td>
      <td>@item.status@
          <if @item.approval_needed_p@ ne 0>
              | <a href=approve?n_items=@item.item_id@&revision_id=@item.revision_id@&return_url=item?item_id=@item.item_id@>#news.approve#</a>
          </if>
	  <else>
              | <a href=revoke?revision_id=@item.revision_id@&item_id=@item_id@>#news.revoke#</a>
	  </else>
      </td>
    </tr>
   </multiple>

  </table>





