
<property name="context">{/doc/news/ {News}} {News Package Requirements}</property>
<property name="doc(title)">News Package Requirements</property>
<master>
<h2>News Package Requirements</h2>

by <a href="mailto:stefan\@arsdigita.com">Stefan Deusch</a>
<h3>I. Introduction</h3>

This document outlines the requirements for the ArsDigita News
application built on the ACS 4.0 platform.
<h3>II. Vision Statement</h3>

Communities are formed with the goal of disseminating information
relevant to their members. Online communities have the advantage of
an ideal mechanism for disseminating this information in a timely
fashion. So it comes as no surprise that the dissemination of news
items to other members is one of the ways in which online
communities best realize this goal. The News application allows
community members to do just this. Posted news items can be
associated with community member comments as in a forum, however,
the primary intention of the News application is simply to give
members access to community related news items. News items are
listed by date, and when news items are no longer current, they are
automatically archived after an administrator-specifiable number of
days.
<p>Since administrators may wish to give access to these news items
by appeal to a variety of access schemes, the News application is
built upon a hierarchy of administrative privileges which may be
organized to reflect a variety of publication policies. In so
doing, the News application allows for an open newsgroup approach
as well as for a closely moderated corporate publication channel.
News is also different from the Press application insofar as press
items typically derive from sources external to the organization in
question.</p>
<h3>III. System/Application Overview</h3>

The News application shall make use of the <strong>content
repository</strong>
 service. Each news item consists of an entry in
<code>cr_items</code>
 and keeps track of revisions in
<code>cr_revisions</code>
. Additional attributes of a news item are
stored in an extra table, namely, title, body, release date,
archive date, templating info, and MIME type. The News application
includes a simple templating system which allows it to
appropriately render an individual news item embedded in customized
HTML. An item is displayed only within the context of the subsite
to which it belongs. The site-wide administrator should be able to
publish an item into all instances of a site. Thus there should be
four levels of user interface depending on the privileges of the
viewer:
<ul>
<li>a site-wide administrator with all privileges of creating,
revising, approving and deleting press items in all instances of
the news application,</li><li>a news administrator with the same privileges for a specific
instance of news,</li><li>a registered user interface with creation privileges,</li><li>a viewer interface for viewing the news items with the option
to leave comments.</li>
</ul>
<h3>IV. Use-cases and User-scenarios</h3>

The different classes of users are of the following categories:
administrators, submitters, and readers.<br>

The administrative power is either site-wide or instance-wide.
Typical user scenarios are as such:
<ul>
<li>Community members use the News package to see current news
postings.</li><li>Subsite administrators use the News package to post news of
interest to community members.</li>
</ul>

Suppose that www.company.com is running an ACS 4.0 based site. On
this site they have a Boston office subcommunity. Jane
Administrator is the subsite admininstator for the Boston office
subsite. Instead of spamming the employees in the office with
Boston news, she decides to enable the News package for their
subsite. First, she checks that the News package is installed and
enabled for office subsites. If it&#39;s not, then Jane must ask
Judy Sitewide Administrator to do this. Once the News package is
installed and enabled for office subsites, Jane enables the News
application specifically for the Boston Office subsite. Jane can
also change the configuration of the News application for the
Boston office subsite if she so chooses. Thus far, Jane has been
using the Subsite Administration Tools. Now that the News package
is ready, she can start adding news postings. Jane does this by
going to the administration pages of the News package. Jane can
also edit existing news items at these pages. If Joe User works in
the Boston Office, then by visiting the Boston Office News site Joe
can read up on any current Boston office related news that has been
posted as such.
<h3>V. Related Links</h3>
<ul>
<li>Design document (not available yet)</li><li>Test plan (Not available yet)</li>
</ul>
<h3>VI. Requirements</h3>
<h4>VI.1 Data Model</h4>

10.10 The News application should use the ACS Content Repository
and/or ACS Content as well as tie in with the ACS Interface service
package.<br>

10.10.10 cr_news: subtype cr_revisions to define news content
type<br>

10.10.20 news_templates: use filesystem for new templates, no extra
table
<p>10.30 Privilege<br>
10.30.10 Provide a site-wide admin level privilege: admin<br>
10.30.20 Provide an instance-wide admin level privilege:
news_admin<br>
10.30.30 Provide registered user level privileges: news_create<br>
10.30.40 Provide a public level privilege: news_read<br>
10.30.50 Specify the intended parent/child relations between these
privileges.</p>
<p>10.40 Parameters<br>
10.40.10 Provide a parameter 'MakeSearchable' which
indicates whether news item content should be accessible through
the ACS Content service package<br>
10.40.20 Provide a 'MaxDisplay' parameter which indicates
the maximum number of items to be displayed per site page<br>
10.40.30 Provide a 'DaysUntilArchive' parameter indicating
the default days until a news items is archived. This parameter
should be able to be overridden on a per news item basis through
the administration pages.<br>
10.40.40 Provide an 'AllowCommentsP' parameter indicating
general policy regarding whether or not news items should be able
to be commented upon.<br>
10.40.50 Provide a 'NotifyByEmailOnUploadP' if the news
administrator should be notified via email upon news items
submission<br>
</p>
<h4>VI.2 General User Interface</h4>

20.10 Provide a list of the titles and dates of all currently
published items<br>

20.20 Provide a link to the archive of old news items<br>

20.30 Provide a one-item view of each news item, displaying it in
its associated template format together with a link for
comments<br>

20.40 Ensure that non 'text/html' news bodies are converted
to HTML using Intermedia text filters
<h4>VI.3 Registered User Interface</h4>
<br>

30.10 Same requirements as under 20.x.<br>

30.20 Provide a link to create a news item<br>

30.30 Ensure that the news application allows registered users to
either enter text/html in a text area or to upload a complete
file.<br>

30.40 Provide for various MIME types for uploaded items, including
MS Word docs.<br>

30.50 Provide a display of those MIME types which are admissible
for upload.<br>

30.60 Ensure that a news item shall be allowed to include an audio
file (real player) for live reports.
<h4>VI.4 Administrator Interface</h4>

40.10 Same as under 30.x.<br>

40.20 Provide a link to the administrative pages<br>

40.30 Provide an administrative summary page of all news items<br>

40.40 Provide a switch to view either archived, live, or all
items<br>

40.50 Provide a selection box with commands for collective
administration<br>

40.60 Provide various archive functions on multiple items, like
'archive next day|week|month' for a set of selected
items.<br>

40.70 Allow for the approve functions to operate on multiple items
simultaneously<br>

40.80 Allow functions to move item(s) into different scopes (e.g.
from private to public news)<br>

40.90 Provide an administrative page for each individual item with
a list of revisions<br>

40.100 Provide a link to add a revision<br>

40.110 Ensure that clicking on a revision brings up the page as it
would look to the public
<p>40.120 Provide a view of unapproved items only.</p>
<h4>VI.5 Template Administration</h4>

50.10 Provide a link to an administrative suite of templates<br>

50.10.10 Allow for the viewing/testing of templates through
provided sample news items<br>

50.10.20 Upload template files<br>

50.10.30 Associate templates to news items<br>

50.10.40 Set default news template
<h4>VI.6 Additional Requirements</h4>

60.10 Provide a subscriber link to sign up for notifications for
when a new news item is posted. Ensure that notifications can be
had at user-specifiable frequency: immediately, daily, weekly,
monthly, and quarterly.<br>

60.20 Provide a counter of how many times an item has been
viewed<br>

60.30 Provide a display of the ranking of most seen items<br>

60.40 Provide a Yahoo-like 'Mail this news article to a
Friend' link
<hr>
<address><a href="mailto:stefan\@arsdigita.com">stefan\@arsdigita.com</a></address>
<br>
<!-- hhmts start -->Last modified: Tue Dec 12 14:15:00 2000
<!-- hhmts end -->
--------------5759157623D344C3E04E6F78--
