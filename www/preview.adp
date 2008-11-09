<master>
<property name="context">@context;noquote@</property>
<property name="title">@title;noquote@</property>

<h1>@title;noquote@</h1>
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

   <include src=news publish_body=@publish_body;noquote@ 
                     publish_lead=@publish_lead@
                     publish_image=@publish_image@
                     publish_title=@publish_title;noquote@
                     creator_link = @creator_link;noquote@>


<div>
    @form_action;noquote@
     <div>@hidden_vars;noquote@</div>
     <div class="form-button"><input type=submit value="#news.Confirm#"></div>
    </form>
<if @action@ eq "News Item">
  @edit_action;noquote@ 
  <div>@image_vars;noquote@</div>
  <div class="form-button"><input type="submit" value="Return to edit"></div>
  </form>
</if>
</div>






