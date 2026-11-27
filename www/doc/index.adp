
<property name="context">{/doc/news/ {News}} {News}</property>
<property name="doc(title)">News</property>
<master>
<style>
div.sect2 > div.itemizedlist > ul.itemizedlist > li.listitem {margin-top: 16px;}
div.sect3 > div.itemizedlist > ul.itemizedlist > li.listitem {margin-top: 6px;}
</style>              
<h1>News</h1>
<h2>Document overview</h2>
<table cellspacing="0" cellpadding="0">
<tr>
<td colspan="2"><a href="requirements">Requirements </a></td><td>Vision of a News application.</td>
</tr><tr>
<td colspan="2"><a href="design">Design</a></td><td>Details on implementation</td>
</tr>
</table>
<h2>Release Notes</h2>

The current release is 4.0.1. It is available from <a href="http://openacs.org/repository/">ACS package repository</a>
.
<h2>Permissions</h2>

If you install the package as site-wide admin, you have full
permission for any function in news. If you are the site-wide admin
and want somebody else to do the news administrator, assign him/her
the privilege 'news_admin' in <a href="/permissions/">/permissions/</a>
. If you are not the site-wide
admin, you must ask the latter to do so.
<h2>Markdown image paste</h2>
<p>In News 6.0.0d3 or newer, clipboard image uploads are controlled
by the package instance parameter <tt>AllowImagePasteP</tt>, which
defaults to <tt>0</tt> (disabled). To enable them for this News
instance:</p>
<ol>
<li>Install and enable Attachments 0.14.2 or newer and install
<tt>richtext-markdown</tt> 0.1d3 or newer.</li><li>Set the News instance parameter <tt>RichTextEditor</tt> to
<tt>markdown</tt> and <tt>AllowImagePasteP</tt> to <tt>1</tt>.</li><li>Select <strong>HTML</strong> as the article&#39;s content
format to use Write/Preview. The <strong>Markdown Text</strong>
format is a separate content format.</li>
</ol>
<p>The image-paste setting does not activate the editor, and
enabling site-wide richtext editing is not required. Authors still
need the existing News creation or administration permissions.</p>
<p>Pasted PNG, JPEG and GIF images are staged privately for
Preview, then attached to the article item when saved. They remain
available across revisions and are deleted with the article.
Delivery supports responsive resized variants through the shared
Attachments image cache and preserves the originals. No child mount
or File Storage mapping is required.</p>
<p>Disabling <tt>AllowImagePasteP</tt> prevents new uploads and
saving staged images, including from already open editor forms.
Existing attached images remain viewable. Other content formats
remain available.</p>
<h2>Reporting bug</h2>

Please file bugs in the <a href="http://openacs.org/bugtracker/openacs/">Bucktracker</a>
.
<hr>
<address><a href="mailto:stefan\@arsdigita.com">Stefan
Deusch</a></address>
<br>

Last modified: $&zwnj;Id: index.html,v 1.4 2017/08/07 23:48:12 gustafn
Exp $
