<master>
<property name="context">@context@</property>
<property name="title">@title@</property>


<p>#news.lt_Use_the_following_for#<br>
#news.Note_that_the# <font color=red>#news.lt_red_fields_are_requir#</font>#news.lt_When_youre_done_click#
<p>

<form action=../preview method=post enctype=multipart/form-data>
@hidden_vars@
<table border=0>
  <tr>
    <th align=right><font color=red>#news.Title#</font></th>
    <td><input type=text size=80 maxlength=400 name=publish_title value="@publish_title@"></td>
  </tr>

 <tr>
  <th align=right valign=top><font color=red>#news.Body#</font></th>
  <td colspan=2><textarea name=publish_body cols=80 rows=20 wrap=soft>@publish_body@</textarea></td>
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
    <td>#news.lt_The_text_is_formatted# 
      <if @html_p@ not nil and @html_p@ ne "f"> 
        <input type=radio name=html_p value="f"> #news.Plain_text#&nbsp;
        <input type=radio name=html_p value="t" checked> #news.HTML#
      </if>
      <else>
        <input type=radio name=html_p value="f" checked> #news.Plain_text#&nbsp;
        <input type=radio name=html_p value="t"> #news.HTML#
      </else>
    </td>
  </tr>

  <tr>
    <th align=right><font color=red>#news.Release_Date#</font></th>
    <td>@publish_date_select@</td>
  </tr>

  <tr>
    <th align=right>#news.Archive_Date#</th>
    <td>@archive_date_select@ <br>
        @never_checkbox@
      <b>#news.never#</b> #news.show_it_permanently#</td>
  </tr>

  <tr>
    <th align=right><font color=red>#news.Revision_log#</font></th>
    <td><input type=text size=80 maxlength=400 name=revision_log value=""><br>
  </tr>


  <tr>
  <th></th>
  <td align=left>
   <input type=submit value="#news.Preview#">
  </td>
  </tr>
</table>

<p>
</form>








