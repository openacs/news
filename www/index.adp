<master>
  <property name="context">@context;noquote@</property>
  <property name="title">@title;noquote@</property>

  <if @news_admin_p@ ne 0>
    <div style="float: right;">[<a href="admin/" title="#news.Administer#">#news.Administer#</a>]</div>
  </if>


  <if @news_items:rowcount@ eq 0>
    <p><i>#news.lt_There_are_no_news_ite#</i></p>
  </if>
  <else>
    <if @allow_search_p@ eq "1" and @search_url@ ne "">
      <div>#news.Search#
        <form action="@search_url@search">
          <input type="text"  name="q" value="" />
          <input type="submit" name="search" value="Search" />
        </form>
      </div>
    </if>

    <if @notification_chunk@ not nil >
	<p>@notification_chunk;noquote@</if>

    <multiple name=news_items>
      <p> @news_items.publish_date@: <a href="item?item_id=@news_items.item_id@" title="#news.show_content_news_items_publish_title#">@news_items.publish_title@</a></li>
        <if @news_items.publish_lead@ not nil><br />@news_items.publish_lead@</if></p>
    </multiple>

    <if @rss_exists@ true>
      <p><a href="@rss_url@" title="#rss-support.Syndication_Feed#">#rss-support.Syndication_Feed# <img
            src="/resources/rss-support/xml.gif" alt="Subscribe via RSS" /></a></p></if>

    <p>@pagination_link;noquote@</p>
  </else>
  <if @news_admin_p@ ne 0> 
    <ul>
      <li><a href="item-create" title="#news.Create_a_news_item#">#news.Create_a_news_item#</a></li>
    </ul>  
  </if>
  <else>
    <if @news_create_p@ ne 0> 
      <ul>
        <li><a href="item-create" title="#news.Submit_a_news_item#">#news.Submit_a_news_item#</a></li>
      </ul>
    </if>
  </else>

  <if @view_switch_link@ ne "">
    <ul>
      <li>@view_switch_link;noquote@</li>
    </ul>
  </if>




