<master src="master">
<property name="context_bar">@context_bar@</property>
<property name="title">@title@</property>


<p>Use the following form to add a revision to this news item.
The available fields from the current active revision are 
already filled in.<br>
Note that the <font color=red>red fields are required</font>.
When you're done click 'Preview' to see how the news item will look.
<p>

<form action=../preview method=post enctype=multipart/form-data>
@hidden_vars@
<table border=0>
  <tr>
    <th align=right><font color=red>Title</font></th>
    <td><input type=text size=80 maxlength=400 name=publish_title value="@publish_title@"></td>
  </tr>

 <tr>
  <th align=right valign=top><font color=red>Body</font></th>
  <td colspan=2><textarea name=publish_body cols=80 rows=20 wrap=soft>@publish_body@</textarea></td>
 </tr>

 <tr>
  <td> </td>
  <td colspan=2>
    <table>
     <tr><td>or upload text file: </td></tr>
     <tr><td><input type=file name=text_file size=40></td></tr>
    </table>
   </td>
 </tr>

  <tr>
    <td> </td>
    <td>The text is formatted as 
      <if @html_p@ not nil and @html_p@ ne "f"> 
        <input type=radio name=html_p value="f"> Plain Text&nbsp;
        <input type=radio name=html_p value="t" checked> HTML
      </if>
      <else>
        <input type=radio name=html_p value="f" checked> Plain Text&nbsp;
        <input type=radio name=html_p value="t"> HTML
      </else>
    </td>
  </tr>

  <tr>
    <th align=right><font color=red>Release Date</font></th>
    <td>@publish_date_select@</td>
  </tr>

  <tr>
    <th align=right>Archive Date</th>
    <td>@archive_date_select@ <br>
        @never_checkbox@
      <b>never</b> (show it permanently)</td>
  </tr>

  <tr>
    <th align=right><font color=red>Revision log</font></th>
    <td><input type=text size=80 maxlength=400 name=revision_log value=""><br>
  </tr>


  <tr>
  <th></th>
  <td align=left>
   <input type=submit value=Preview>
  </td>
  </tr>
</table>

<p>
</form>



