<master>
<property name="title">Upload Image</property>
<property name="context"></property>

<p>Choose an image to upload and press the 'Upload' button to preview
it. When you're happy, press 'Accept' to use that image in the
article.</p>

<if @image_url@ not nil><img src="@image_url@"></if>
<if @mode@ eq preview>
<form action="preview" method="post">
@form_vars;noquote@
<input type="submit" value="Accept">
</form>
</if>

<formtemplate id="img"></formtemplate>
