<master src="master">
<property name="context_bar">@context_bar@</property>
<property name="title">@title@</property>

<p>Use the following form to define your news item.
Note that the <font color=red>red fields are required</font>. 
When you're done click 'Preview' to see how the news item will appear.


<form action=preview method=post enctype=multipart/form-data>

<table border=0>
<tr>
  <th align=right><font color=red>Title</font></th>
  <td><input type=text size=80 maxlength=400 name=publish_title></td>
  <td></td>
</tr>

<tr>
  <th align=right valign=top><font color=red>Body</font></th>
  <td colspan=2><textarea name=publish_body cols=80 rows=20  wrap=soft></textarea></td>
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
  <td colspan=2>The text is formatted as &nbsp;
      <input type=radio name=html_p value="f" checked> Plain Text&nbsp;
      <input type=radio name=html_p value="t" > HTML
  </td>
</tr>

<if @immediate_approve_p@ ne 0>
<tr>
  <th align=right><font color=red>Release Date</font></th>
  <td colspan=2>@publish_date_select@</td>
</tr>

<tr>
  <th align=right>Archive Date</th>
  <td colspan=2>@archive_date_select@<br>
    <input type=checkbox name=permanent_p value=t>
    <b>never</b> (show it permanently)</td>
</tr>
</if>

<tr> 
  <td></td>
  <td align=left>
   <input type=hidden name=action value="News Item">
   <input type=submit value=Preview>	
  </td>
</tr>
</table>

<p>
</form>






