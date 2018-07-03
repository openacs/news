
<property name="context">{/doc/news {News}} {News Design Document}</property>
<property name="doc(title)">News Design Document</property>
<master>
<h2>News Design Document</h2>

by <a href="mailto:stefan\@arsdigita.com">Stefan Deusch</a>
<hr>
<h3>I. Essentials</h3>
<ul>
<li>User directory: <a href="/news/">/news/</a>
</li><li>Tcl procedures: <a href="/api-doc/procs-file-view?path=packages/news/tcl/news-procs.tcl">/tcl/news-procs.tcl</a>
</li><li>Requirements document: <a href="/doc/news/requirements">/doc/news/requirements.html</a>
</li><li>Data model: <a href="/doc/sql/display-sql?url=news-create.sql&amp;package_key=news">news-create.sql</a>
, <a href="/doc/sql/display-sql?url=news-sws.sql&amp;package_key=news">news-sws.sql</a>
</li>
</ul>
<h3>II. Introduction</h3>

Most Web services and almost all corporate sites have a
company.com/news/ service. These can be used in a variety of ways,
e.g. for advertising or dissemination of related news items. News
items are such that they cease to be news after a while. When this
happens, these news items should automatically disappear into the
news archives without further administrator intervention. The News
application supports site-wide news coverage - appropriate when one
ACS installation is being used for a company - and subcommunity
news coverage where several organizations are using the same ACS
server
<h3>III. Historical Considerations</h3>

News applications previous to ACS 4 were less integrated into the
site and had less functionality. This version scopes instances
implicitly through use of the acs-permissioning system. The old
news allowed to edit the items, the new one allows version control.
The administrator can switch back to a historic version of a news
item.
<h3>IV. Competitive Analysis</h3>

The News application is consistent with the functionality of
similar systems on the Internet. It is built with ACS 4 and relies
on the object oriented nature of ACS 4. It is best used in
conjunction with other ACS applications such as general-comments,
site-wide-search, and file storage.
<h3>V. Design</h3>

Published or archived news items are presented as entries in a
hyperlinked list. Single news items are presented by taking
advantage of the ACS Templating system. The default news template
is in the file news.adp which takes
<ul>
<li><pre>\@publish_title\@</pre></li><li><pre>\@publish_body\@</pre></li><li><pre>\@creator_link\@</pre></li>
</ul>

as input. Publishers may wish to provide their own templates,
however even more flexibility can be introduced by supplying the
news body in HTML format. If someone submits a news body with
inconsistent HTML tags, the News application attempts to close
these tags in the preview page.
<p>The news body can have a MIME format of "text/plain"
or "text/html". Using HTML, the publisher can hyperlink
images, audio- and video files into the publication body from other
sites or from the local file storage module. This way, the news
application does not need its own content management. For instance,
one can download and install the ACS4 file-storage module from the
<a href="http://www.arsdigita.com/acs-repository/">acs-repository</a>,
upload some photographs in gif or jpeg format, and then link it
into the HTML news body, somewhat like this: &lt;img
src="http://myserver.org/file-storage/download/Fig1.gif"&gt;</p>
<p>If someone submits a news body with inconsistent HTML tags, the
News application attempts to close these tags in the preview
page.</p>
<h3>VI. API</h3>

Much of the API is covered in the <a href="/doc/sql/display-sql?url=news-create.sql&amp;package_key=news">news-create.sql</a>

file. The news package body holds all of the PL/SQL functions and
procedures.
<ul>
<li>news.new: creates a new news item</li><li>news.delete: deletes a news item</li><li>news.make_permanent: removes archival date from items</li><li>news.archive: archives items with a default date of now</li><li>news.set_approve: approves or revoked submitted items (for use
when the general public can submit news items). Approving means
setting the publish date.</li><li>news.status: returns info as to permanent, when it will
archive, when it will be released</li><li>news.revision_add: add a new revision to an existing news
item</li><li>news.revision_delete: delete a revision from an existing news
item (not used)</li><li>news.revision_activate: make a revision the active
revision</li>
</ul>

The Tcl procedures are, see <a href="/api-doc/procs-file-view?path=packages/news/tcl/news-procs.tcl">/tcl/news-procs.tcl</a>

file.
<ul>
<li>news_items_archive: archives items at a certain date</li><li>news_items_make_permanent: removes archival date from
items</li><li>news_items_delete: deletes news items</li>
</ul>
<h3>VII. Data Model Discussion</h3>

The News application makes use of the existing ACS Content
Repository service. A news item consists of a row-entry in the
table cr_item, where all of the meta-information that isn&#39;t
already stored in acs_objects concerning these items is placed, one
or several rows in the revision table cr_revisions, and a custom
table, cr_news, which holds the remainder of the information
necessary to describe a news item. cr_news items are children of
cr_revision items.
<pre>
create table cr_news (
    news_id                     integer
                                constraint cr_news_id_fk references cr_revisions
                                constraint cr_news_pk primary key,
    -- include package_id to provide support for multiple instances
    package_id                  integer
                                constraint cr_news_package_id_nn not null,      
    -- regarding news item
    -- *** support for dates when items are displayed or archived ***
    -- unarchived news items have archive_date null
    archive_date                date,
    -- support for approval
    approval_user               integer
                                constraint cr_news_approval_user_fk
                                references users,
    approval_date               date,
    approval_ip                 varchar2(50)
);
</pre>

Note that different package instances of the News application can
be distinguished by the column 'package_id' (and not by the
inherited context_id in acs_objects). We therefore need only a
single cr_folder named 'news' to hold all news items.
<p>The data model in the context of the content repository are
further characterized by following:</p>
<ul>
<li>The items are assigned to the folder 'news' in the
content repository.</li><li>The PL/SQL API provides procedures and functions to create,
delete, approve, archive, query, release, or revise a news
item.</li><li>A new revision generates an entry in cr_news and cr_revisions
in parallel and updates the live_revision in cr_items.</li><li>The release date is stored in the publish_date column of
cr_revisions,</li><li>The archive_date is supplemented by cr_news.</li>
</ul>

A reminder to the column release_date is necessary here: Its
granularity is only one day, i.e. the release date is for instance
2001-01-01 00:00 (always at midnight). If someone wants to present
a view of 'new items' since last login (which can be more
than once since 00:00), one can use cr_news.approval_date for
differentiating since this is time-stamped by sysdate.
<h4>Permissions</h4>

With the ACS4 permissions model, the news administrator need no
longer coincide with the site administrator. This need only be the
case right after installation. The News application has a
hierarchical set of permissions which can be assigned to any party
as needed. The news root privilege is <code>news_admin</code>
 which
comprises <code>news_create, news_delete,</code>
 and
<code>news_read</code>
.
<p>By default, the <code>news_admin</code> permission inherits from
the site-wide admin. The <code>news_read</code> permission is
assigned to the public so that all users, including non-registered
users, have access to /news/. By default, the
<code>news_create</code> permission is assigned to registered
users. However, they can only submit a news items, but not approve
it. Approval requires news_admin privilege or can be set to take
place automatically by setting the parameter
<em>ApprovalPolicy</em> to 'open'. The news privileges can
be changed in /permissions/ by the administrator on the
/news/admin/index page. The needs of an individual site, e.g.
sharing the news administration duties among several individuals,
are thus covered.</p>
<h4>Legal Transactions</h4>
<h5>User Pages</h5>
<ul>
<li>View published news item list: index?view=active</li><li>View archived news item list: index?view=archive</li><li>View one news item: revision</li><li>Preview one news item before publishing/approving: preview</li>
</ul>
<h4>News Administrator Pages</h4>
<ul>
<li>View one news item with administrative information:
admin/revision</li><li>Administer news items: admin/index</li><li>Administer one news item: admin/item</li><li>Add/suggest a new news item: item-create</li><li>Edit existing news coverage by adding a revision:
admin/revision-add</li><li>Archive existing news coverage:
admin/process?action=archive</li><li>Make permanent existing news coverage:
admin/process?action=make_permanent</li><li>Approve existing news coverage: admin/approve</li><li>De-activate existing news coverage: admin/revoke</li><li>Delete existing news coverage: admin/process?action=delete</li><li>Set one revision the active one: admin/revision-set-active</li>
</ul>
<h3>VIII. User Interface</h3>

The publicly accessible pages are in the root directory of the
mounted instance. The administrative pages are in /news/admin/. No
privilege check is needed in the news/admin/ directory.
<p>The corresponding links for <strong>Administer</strong> and
<strong>Create news item</strong> only appear for parties which
possess the appropriate privileges. Viewers not authorized to view
the index page (i.e. parties who were denied the
<code>news_read</code> permission) are shown the site-wide
'not-authorized' template.</p>
<p>The news gateway defaults to serving the parameter
<code>DisplayMax</code>, see sec. XI below, number of news items or
archived items. The rest of the items can be viewed with a centered
paging link at the bottom of the page. The link <code>archived
items | live items</code> appears if such exist.</p>
<p>The /admin/index page shows a table of the active revisions of
each news item. News items can have the status of:</p>
<ul>
<li>unapproved (only if a non-news-admin uploaded something), the
news_admin is approved automatically</li><li>approved and awaiting release</li><li>published (= approved and live)</li><li>archived</li>
</ul>

The /admin/index page has a dimensional slider to select items with
the corresponding status. To each selected view, a SELECT box with
allowable operations (on the items checked at their checkbox in the
first column of the table), is shown. For example, bulk-archiving
and deleting of published items can be effected in this way. For
archived items, one can re-publish or delete them.
<p>Note, that releasing/revoking can be done for an item
individually as well, following the ID# link in the second column
which leads to /admin/item. On that page, a new revision can be
added. There is no UI to <em>edit</em> a revision; A new revision
must be accompanied by a revision log string to describe the
changes. The /admin/item administration page shows the audit
history of an item in a similar format as that of the files shown
in <a href="http://cvs.arsdigita.com">cvs.arsdigita.com</a>. be
added.</p>
<p>Function of the archive date: The archive status is either a
date in the future after the release date or null for permanently
live items.</p>
<h3>IX. Making News Searchable with Site-Wide-Search</h3>

Follow the setup instruction in site-wide-search and read the
design doc. You have to follow specifically these steps:
<ol>
<li>download and install acs-interface from <a href="http://www.arsdigita.com/acs-repository/">www.arsdigita.com/acs-repository/</a>
</li><li>download and install site-wide-search from <a href="http://www.arsdigita.com/acs-repository/">www.arsdigita.com/acs-repository/</a>
</li><li>restart server</li><li>run SQL setup script for site-wide-search, specifically
<strong>sws-package-all.sql</strong>, by hand.</li><li>cd into news/sql and source news-sws.sql</li><li>mount site-wide-search, e.g. under /search - an instance must
be mounted for each package you intend to have search
functionality</li><li>if you want to search your items immediately, you must compile
the index manually - otherwise it is scheduled to run every 2
hours.
<pre>
     begin
        sws_service.update_content_obj_type_info ('news');
        sws_service.rebuild_index;
     end; 
     /
     </pre>
</li>
</ol>
<p>To drop an instance of the News application correctly, follow
these steps:</p>
<ol>
<li>drop news, and source news-sws-drop.sql</li><li>source site-wide-search/sql/content-revision-sws-drop.sql</li><li>source sws-package-all-drop.sql</li>
</ol>

As can be seen from the function news__sws.sws_req_permission each
searchable item requires an access permission. For users with the
privilege 'news_admin', no permission (null) is required
and all available revisions are searched as well. For all other
users a 'news_read' permission is returned on the published
revision, i.e. search results from the live revision (even though
they might already be archived). The search results, shown in the
mounted directory of site-wide-search, don&#39;t distinguish
between 'live' and 'archived' items.
<h3>X. General Comments</h3>

This release allows general comments using the general-comments
package. The policy of general comments is determined by the
parameter SolicitCommentsP, see below. In order to work correctly,
the general-comments package has to be installed and mounted first.
Comments are only shown on the public pages, i.e. on
/news/item.tcl. No comments are shown on the /news//admin/ pages.
For administration of comments, one has to go into the site-wide
general-comments package.
<p>The most important integration of the comments facility is
reflected in the news.delete procedure of the package news. Before
the news item is deleted, all possible dependent comments including
picture attachments are dropped.</p>
<h3>XI. Parameters</h3>

The news application has three customizable parameters which have
to be set for each package instance through the site-map manager.
<ul>
<li>ActiveDays...number of days between release and archival</li><li>DisplayMax ... how many items are shown on the index page
(valid for live and archived items)</li><li>ApprovalPolicy...[open|wait] if open, submitted items are
approved immediately, wait means approval by the
administrator.</li><li>ShowSearchInterfaceP...[0,1] whether we show a 'Search
Box' for searching news items with site-wide-search (must be
installed).</li><li>SolicitCommentsP...[1,0] whether we allow comments on a news
item or not</li>
</ul>
<h3>XII. Acceptance Tests</h3>

You should test adding, viewing, editing, changing revisions,
changing status and deleting a news item:
<ul>
<li>Go to /news/ and click on the Administer link.</li><li>Add a news item</li><li>Verify that the item shows up on the admin side and the user
side with the correct number of days left for display.</li><li>Verify that the new revision is active, and that it is
displayed on the user side.</li><li>On the admin side, archive the item.</li><li>Ensure that the user now sees it as an archived item.</li><li>On the admin side, make the item permanent.</li><li>Ensure that the user now sees it as a live item.</li><li>Delete the item.</li>
</ul>

Uploads of up to 10.000-character news items was tested
successfully. HTML uploads appear correctly. However, some HTML
tags are filtered site-wide against malicious spamming. The
site-wide admin can turn them on/of at <a href="/admin/site-map">setting ACS Kernel parameters</a>
 at ACS Kernel
[set parameters].<br>

Pure text uploads preserve their formatting from the textarea - a
&lt;pre&gt; tag is wrapped around. That way the textarea for
entering the news body is used as a formatting editor.
<h3>XIII. Future Improvements</h3>
<ul>
<li>Use e-mail notification on submission and release, such as
supplied by ACS Notification in PL/SQL only.</li><li>Allow for more MIME types, especially Microsoft Word, and use
the corresponding Intermedia filter to render as HTML.</li><li>Add news categorization to the data model that allows to order
news articles by categories without creating new application
instances (e.g. sports, education, health, literature, music ,
politics, ...) - this also needs a UI to create categories and a
mapping table.</li>
</ul>
<h3>XIV. Authors</h3>

Please mail suggestions or bug reports to <a href="mailto:stefan\@arsdigita.com">Stefan Deusch</a>
<h3>XV. Revision History</h3>
<table cellpadding="2" cellspacing="2" width="90%" bgcolor="#EFEFEF">
<tr bgcolor="#E0E0E0">
<th width="10%">Document Revision #</th><th width="50%">Action Taken, Notes</th><th>When?(mm/dd/yyyy)</th><th>By Whom?</th>
</tr><tr>
<td>0.1</td><td>Creation</td><td>12/20/2000</td><td>Stefan Deusch</td>
</tr><tr>
<td>0.2</td><td>First pass edit</td><td>12/24/2000</td><td>Josh Finkler</td>
</tr><tr>
<td>1.0</td><td>Alpha Release ready</td><td>1/24/2001</td><td>Stefan Deusch</td>
</tr><tr>
<td>1.1</td><td>Minor revisions, restructuring of sections</td><td>1/25/2001</td><td>Josh Finkler</td>
</tr><tr>
<td>1.2</td><td>Alpha release wrap up</td><td>1/25/2001</td><td>Stefan Deusch</td>
</tr>
</table>
