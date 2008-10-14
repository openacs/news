<% # This is the default template to render news items in admin/. Comments are not shown here %>

<h3>@publish_title@</h3>

<if @publish_lead@ not nil><p class="newsLead">@publish_lead@</p></if>

@publish_body;noquote@

<p>#news.Contributed_by# @creator_link;noquote@




