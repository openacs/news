<comment>This is the default template to render news items in admin/. This template is used as well by search!</comment>

<if @publish_title@ not nil><h1 class="newsTitle">@publish_title@</h1></if>
<if @publish_image@ not nil><img class="newsImage" src="@publish_image@" alt="News image"></if>
<if @publish_lead@ not nil><p class="newsLead">@publish_lead;noquote@</p></if>
<div class="newsBody">@publish_body;noquote@</div>
<p class="newsCredit" style="margin-top:1em"><small>#news.Contributed_by# @creator_link;noquote@</small></p>


