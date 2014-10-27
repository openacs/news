<comment>This is the default template to render news items in admin/. Comments are not shown here</comment>
<if @publish_title@ not nil><h1>@publish_title@</h1></if>
<if @publish_lead@ not nil><p class="newsLead">@publish_lead@</p></if>
<div class="newsBody">@publish_body;noquote@</div>
<p class="newsCredit">#news.Contributed_by# @creator_link;noquote@</p>
