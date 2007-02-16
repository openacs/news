<master>
<property name="context">@context;noquote@</property>
<p>
<property name="title">@title;noquote@</property>

<ul>
  <li><a href="../item-create">#news.Create_a_news_item#</a>
  <li><if @rss_exists@ true>#rss-support.Rss_feed_active# [<a
  href="rss">#rss-support.Remove_feed#</a>]</if><else>#rss-support.Rss_feed_inactive#[<a href="rss">
  #rss-support.Create_feed#</a>]</else>
    </ul>

<p>

@view_link;noquote@
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
        <tr class="odd">
        </if>
        <else>
        <tr class="even">
        </else>
          <td align=center><input type=checkbox name=n_items  value=@news_items.item_id@></td>
          <td><a href=item?item_id=@news_items.item_id@>@news_items.item_id@</a></td>
          <td class="adminLink">@news_items.publish_title@ (#news.rev# @news_items.revision_no@) <a href=revision-add?item_id=@news_items.item_id@>#news.revise#</a></td>
          <td><a href=/shared/community-member?user_id=@news_items.creation_user@>@news_items.item_creator@</a></td>
          <td>@news_items.publish_date_pretty@</td>
          <td>@news_items.archive_date_pretty@</td>
          <td>@news_items.pretty_status@</td>
         </tr>
         </multiple>
       </table>
 
     <if @view@ ne "all">
     <p>
      #news.lt_Do_the_following_to_t#
      <select name=action>
	@select_actions;noquote@
       <option value=delete>#news.Delete#</option>	
       </select>
       <input type=submit value="#news.Go#">
       </p>
     </if>
       </form>
       </td></tr></table>
</else>









