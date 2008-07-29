<master>
<property name="title">@title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="focus">news.publish_title</property>

<h1>@title;noquote@</h1>

<p>Use the following form to define your news item.Note that the fields marked with <span class="formRequired">*</span> are required.
When you're done click 'Preview' to see how the news item will look and to choose an image for the article.</p>


<form action=preview method=post enctype=multipart/form-data name=news>

<p class="formLabel"><label for="publish_title">#news.Title#</label><span class="formRequired">*</span></p>
<p class="formWidget"><input type=text size=63 maxlength=400 id="publish_title" name=publish_title value="@publish_title@"></p>

<p class="formLabel"><label for="publish_lead">#news.Lead#</label></p>
<p class="formWidget"><textarea id="publish_lead" name=publish_lead cols=50 rows=3>@publish_lead@</textarea></p>

<p class="formLabel"><label for="publish_body">#news.Body#</label><span class="formRequired">*</span></p>
<p class="formWidget"><textarea id="publish_body" name=publish_body cols=50 rows=20  wrap=soft>@publish_body@</textarea><br>
<span class="advancedAdmin"><label for="text_file">#news.or_upload_text_file#</label><br></span>
<p class="formWidget"><span class="advancedAdmin"><input type=file id="text_file" name=text_file size=40><br></span>
#news.The_text_is_formatted_as# &nbsp;
      <input type=radio name=html_p value="f" id="plain"<if @html_p@ false> checked</if>> <label for="plain">#news.Plain_text#</label>&nbsp;
      <input type=radio name=html_p value="t" id="html"<if @html_p@ true> checked</if>> <label for="html">#news.HTML#</label>
</p>

<if @immediate_approve_p@ ne 0>
<p class="formLabel"><label for="publish_date">#news.Release_Date#</label></p>
<p class="formWidget">@publish_date_select;noquote@</p>

<p class="formLabel"><label for="archive_date">#news.Archive_Date#</label></p>
<p class="formWidget">@archive_date_select;noquote@<br>
<input type=checkbox name=permanent_p value=t id="never" <if @permanent_p@ true> checked</if>> <b><label for="never">#news.never#</label></b> #news.show_it_permanently#</p>
</p>
</if>

<p>
   <input type=hidden name=action value="News Item">
   <input type=submit value="#news.Preview#">	
</p>
</form>











