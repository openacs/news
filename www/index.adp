<master>
  <property name="context">@context;noquote@</property>
  <property name="title">@title;noquote@</property>

  <if @news_admin_p@ ne 0>
    <div style="float: right;">[<a href="admin/">#news.Administer#</a>]</div>
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

    <ul>
      <multiple name=news_items>
        <li> @news_items.publish_date@: <a href="item?item_id=@news_items.item_id@">@news_items.publish_title@</a></li>
      </multiple>
    </ul>
    <if @rss_exists@ true>
      <p><a href="@rss_url@">#rss-support.Syndication_Feed# <img
            src="/resources/rss-support/xml.gif" alt="Subscribe via RSS" /></a></p></if>
    
    <p>@pagination_link;noquote@</p>
  </else>
  <if @news_admin_p@ ne 0> 
    <ul>
      <li><a href=item-create>#news.Create_a_news_item#</a></li>
    </ul>  
  </if>
  <else>
    <if @news_create_p@ ne 0> 
      <ul>
        <li><a href=item-create>#news.Submit_a_news_item#</a></li>
      </ul>
    </if>
  </else>

  <if @view_switch_link@ ne "">
    <ul>
      <li>@view_switch_link;noquote@</li>
    </ul>
  </if>




