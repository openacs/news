<master>
<property name="context">@context;noquote@</property>
<property name="title">@title;noquote@</property>

<p>#news.lt_Your_news_item_will_b#</p>
<p>
  <if @news_admin_p@ ne 0>
   #news.It_will_go_live_on# @publish_date_pretty@.   
    <if @permanent_p@ eq "t">
      #news.lt_And_be_live_until_rev#
    </if>
    <else>	
      #news.It_will_move_into_archive_on# @archive_date_pretty@.
    </else>
  </if>
  <else>
    #news.lt_It_will_go_live_after#
  </else>
</p>
<p>
  #news.lt_To_the_readers_it_wil#
</p>

<form action="image-choose" method="post">
	@image_vars;noquote@
	<input type="submit" value="#news.Choose_an_image#">
</form>

   <include src=news publish_body=@publish_body;noquote@ 
                     publish_lead=@publish_lead@
                     publish_image=@publish_image@
                     publish_title=@publish_title;noquote@
                     creator_link = @creator_link;noquote@>


<p>
    @form_action;noquote@
    @hidden_vars;noquote@
     <input type=submit value="#news.Confirm#">
  </form>
<if @action@ eq "News Item">
  @edit_action;noquote@ @image_vars;noquote@
  <input type="submit" value="#news.Return_to_edit#">
</if>
</p>






