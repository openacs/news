<master>
<property name="title">#news.Upload_Image#</property>
<property name="context"></property>

<p>#news.Choose_an_image_to_upload_and_press#</p>

<if @image_url@ not nil><img src="@image_url@"></if>
<if @mode@ eq preview>
<form action="preview" method="post">
@form_vars;noquote@
<input type="submit" value="Accept">
</form>
</if>

<formtemplate id="img"></formtemplate>
