<master src="master">
<property name="context_bar">@context_bar@</property>
<property name="title">@title@</property>

<p>
<ul>
  <li>Your news item will be presented using the Default template defined in news.adp.
  <if @news_admin_p@ ne 0>
   <li>It will go live on @publish_date_ansi@.
   <li>
    <if @permanent_p@ eq "t">
      And be live until revoked.
    </if>
    <else>	
      It will move into the archive on @archive_date_ansi@.
    </else>
  </if>
  <else>
    <li>It will go live after it is approved by the News Administrator.
  </else>
  <li>To the readers it will look like:
</ul>

</p>

   <include src=news publish_body=@publish_body@ 
                     publish_title=@publish_title@
                     creator_link = @creator_link@>


<p>
    @form_action@
    @hidden_vars@
    <center>
     <input type=submit value=Confirm>
    </center>
  </form>
</p>


