<master>
<property name="context">@context;literal@</property>
<property name="doc(title)">@title;literal@</property>



<p>	
  #news.Author#: @creator_link;noquote@<br>
  #news.Revision_number#: @revision_no@<br>
  #news.Creation_Date#: @creation_date_pretty@<br>
  #news.Creation_IP#: @creation_ip@<br>
  #news.Release_Date#: @publish_date_pretty@<br>
  #news.Archive_Date#: @archive_date_pretty@
</p>
<hr>
<include src="/packages/news/lib/news"
    publish_title="@publish_title;noquote@ (#news.rev# @revision_no;noquote@)"
    publish_lead="@publish_lead@"
    publish_body="@publish_body;noquote@"
    publish_format="@publish_format;noquote@"
    creator_link="@creator_link;noquote@"
>
