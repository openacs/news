<master>
<property name="context">@context;noquote@</property>
<property name="title">@title;noquote@</property>


<if @item_exist_p@ eq "0">
   <p>#news.lt_Could_not_find_corres#</p>
</if>

<else>
<p>	
  #news.Author#: @creator_link;noquote@<br />
  #news.Revision_number#: @revision_no@<br />
  #news.Creation_Date#: @creation_date@<br />
  #news.Creation_IP#: @creation_ip@<br />
  #news.Release_Date#: @publish_date@<br />
  #news.Archive_Date#: @archive_date@
</p>
<hr>
<include src="../news"
    publish_title="@publish_title;noquote@ (#news.rev# @revision_no;noquote@)"
    publish_lead=@publish_lead@
    publish_body=@publish_body;noquote@
    creator_link=@creator_link;noquote@
>
</else>




























