<master>
<property name="context">@context;noquote@</property>
<property name="title">@title;noquote@</property>

<p>
<ul>
  <li>#news.lt_Your_news_item_will_b#
  <if @news_admin_p@ ne 0>
   <li>#news.It_will_go_live_on# @publish_date_pretty@.
   <li>
    <if @permanent_p@ eq "t">
      #news.lt_And_be_live_until_rev#
    </if>
    <else>	
      #news.It_will_move_into_archive_on# @archive_date_pretty@.
    </else>
  </if>
  <else>
    <li>#news.lt_It_will_go_live_after#
  </else>
  <li>#news.lt_To_the_readers_it_wil#
</ul>

</p>

   <include src=news publish_body=@publish_body;noquote@ 
                     publish_title=@publish_title;noquote@
                     creator_link = @creator_link;noquote@>


<p>
    @form_action;noquote@
    @hidden_vars;noquote@
    <center>
     <input type=submit value="#news.Confirm#">
    </center>
  </form>
</p>






