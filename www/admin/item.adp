<master>
<property name="context">@context;noquote@</property>
<property name="title">@title;noquote@</property>



<p class="adminLink"><a href=revision-add?item_id=@item_id@>#news.Add_a_new_revision#</a></p>

   <table>
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
    <tr class="odd">
    </if>
    <else>
     <tr class="even">
    </else>
      <td align=center> 
       <a href=revision?item_id=@item.item_id@&revision_id=@item.revision_id@>
        <%= [expr @item:rowcount@ - @item.rownum@ +1] %>  </td>
       </a> 

      <td> 
       <if @item.item_live_revision_id@ eq @item.revision_id@>
        #news.active#
       </if>
       <else>
        <a href="revision-set-active?item_id=@item_id@&new_rev_id=@item.revision_id@">
        #news.make_active#
      </else>
      </td>

      <td>
        <a href=revision?item_id=@item.item_id@&revision_id=@item.revision_id@>@item.publish_title@<a/></td>
      <td><a href=/shared/community-member?user_id=@item.creation_user@>@item.item_creator@</a></td>
      <td>@item.log_entry@</td>
      <td class="adminLink">@item.status@
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





