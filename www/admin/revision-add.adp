<master>
<property name="context">@context;noquote@</property>
<property name="title">@title;noquote@</property>


<p>#news.Use_the_following_form_to_define#</p>

<form action="../preview" method="post" enctype="multipart/form-data">
@hidden_vars;noquote@

<p class="formLabel"><label for="publish_title">#news.Title#</label><span class="formRequired">*</span></p>
<p class="formWidget"><input type=text size=63 maxlength=400 id="publish_title" name=publish_title value="@publish_title@"></p>

<p class="formLabel"><label for="publish_lead">#news.Lead#</label></p>
<p class="formWidget"><textarea id="publish_lead" name=publish_lead cols=50 rows=3>@publish_lead@</textarea></p>

<p class="formLabel"><label for="publish_body">#news.Body#</label><span class="formRequired">*</span></p>
<p class="formWidget"><textarea id="publish_body" name=publish_body cols=50 rows=20>@publish_body@</textarea><br />
<span class="advancedAdmin"><label for="text_file">#news.or_upload_text_file#</label><br /></span>
<p class="formWidget"><span class="advancedAdmin"><input type=file id="text_file" name=text_file size=40><br /></span>
#news.The_text_is_formatted_as# &nbsp;
      <if @html_p@ not nil and @html_p@ ne "f"> 
        <input type=radio name=html_p value="f" id="plain"> <label for="plain">#news.Plain_text#</label>&nbsp;
        <input type=radio name=html_p value="t" id="html" checked> <label for="html">#news.HTML#</label>
      </if>
      <else>
        <input type=radio name=html_p value="f" id="plain" checked> <label for="plain">#news.Plain_text#</label>&nbsp;
        <input type=radio name=html_p value="t" id="html"> <label for="html">#news.HTML#</label>
      </else>
</p>

<p class="formLabel">Image</p>
<p class="formWidget"><if @image_url@ not nil><img src="@image_url@"></if>
      [#news.use_preview_to_revise_image#]
</p>

<p class="formLabel">#news.Release_Date#</p>
<p class="formWidget">@publish_date_select;noquote@</p>

<p class="formLabel">#news.Archive_Date#</p>
<p class="formWidget">@archive_date_select;noquote@<br />
<input type=checkbox name=permanent_p value=t id="never"> <b><label for="never">#news.never#</label></b> #news.show_it_permanently#</p>

<p class="formLabel"><label for="revision_log">#news.Revision_log#</label><span class="formRequired">*</span></p>
<p class="formWidget"><input type=text size=63 maxlength=400 id="revision_log" name=revision_log value=""></p>



<p>   <input type=submit value="#news.Preview#">
</p>
</form>








