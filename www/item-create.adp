<master>
<property name="context">@context;noquote@</property>
<property name="title">@title;noquote@</property>

<p>#news.lt_Use_the_following_for# <font color=red>#news.lt_red_fields_are_requir#</font>#news.lt_When_youre_done_click#


<form action=preview method=post enctype=multipart/form-data>

<table border=0>
<tr>
  <th align=right><font color=red>#news.Title#</font></th>
  <td><input type=text size=80 maxlength=400 name=publish_title></td>
  <td></td>
</tr>

<tr>
  <th align=right valign=top><font color=red>#news.Body#</font></th>
  <td colspan=2><textarea name=publish_body cols=80 rows=20  wrap=soft></textarea></td>
</tr>

<tr>
  <td> </td>
  <td colspan=2> 
    <table>
     <tr><td>#news.or_upload_text_file# </td></tr>
     <tr><td><input type=file name=text_file size=40></td></tr>
    </table>
   </td>  
</tr>

<tr>
  <td> </td>
  <td colspan=2>#news.The_text_is_formatted_as# &nbsp;
      <input type=radio name=html_p value="f" checked> #news.Plain_text#&nbsp;
      <input type=radio name=html_p value="t" > #news.HTML#
  </td>
</tr>

<if @immediate_approve_p@ ne 0>
<tr>
  <th align=right><font color=red>#news.Release_Date#</font></th>
  <td colspan=2>@publish_date_select;noquote@</td>
</tr>

<tr>
  <th align=right>#news.Archive_Date#</th>
  <td colspan=2>@archive_date_select;noquote@<br>
    <input type=checkbox name=permanent_p value=t>
    <b>#news.never#</b> #news.show_it_permanently#</td>
</tr>
</if>

<tr> 
  <td></td>
  <td align=left>
   <input type=hidden name=action value="News Item">
   <input type=submit value="#news.Preview#">	
  </td>
</tr>
</table>

<p>
</form>











