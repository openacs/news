ad_page_contract {
    Serve a private News draft image or an attachment of a visible article.
} {
    image_id:naturalnum,notnull
    {width ""}
}

# Only fixed variants are accepted, so arbitrary requests cannot grow the cache.
if {$width ne "" && $width ni [attachments::image::widths]} {
    ns_return 400 text/plain "Unsupported image width."
    ad_script_abort
}
ns_set put [ns_conn outputheaders] X-Content-Type-Options nosniff

set package_id [ad_conn package_id]
if {[namespace which ::attachments::richtext::file_attach] ne ""
    && [db_0or1row news_markdown_image_attachment {
        select a.object_id, r.revision_id
        from attachments a
        join cr_items i on i.item_id = a.item_id
        join acs_objects o on o.object_id = i.item_id and o.context_id = a.object_id
        join cr_revisions r on r.revision_id = i.live_revision
        where a.item_id = :image_id and o.package_id = :package_id
          and r.mime_type in ('image/png', 'image/jpeg', 'image/gif')
    }]} {
    permission::require_permission -object_id $object_id -privilege read
    set can_write_p [expr {[permission::permission_p -object_id $object_id -privilege write]
                           || [permission::permission_p -object_id $package_id -privilege news_admin] ? "t" : "f"}]
    if {![db_string news_markdown_image_visible {
        select 1
        from news_items_live_or_submitted
        where item_id = :object_id and package_id = :package_id
          and (:can_write_p = 't'
               or (live_revision is not null and (archive_date is null or archive_date > current_timestamp)))
    } -default 0]} {
        ns_returnnotfound
        ad_script_abort
    }
    # Authorize above on every request, including cache hits. Browser caches must
    # revalidate committed images when permissions or publication status change.
    ns_set put [ns_conn outputheaders] Cache-Control "private, no-cache"
    if {$width eq ""} {
        cr_write_content -revision_id $revision_id
    } else {
        set file [content::revision::get_cr_file_path -revision_id $revision_id]
        set mime [ns_imgtype $file]
        ns_returnfile 200 image/$mime [attachments::image::variant $file $width revision-$revision_id]
    }
    ad_script_abort
}

if {[ad_conn user_id] != 0 && [acs_object_type $image_id] eq ""} {
    set file [news::markdown_image::draft_path $image_id]
    set mime [news::markdown_image::mime_type $file]
    if {$mime ne ""} {
        ns_set put [ns_conn outputheaders] Cache-Control "private, no-store"
        ns_returnfile 200 $mime [attachments::image::variant $file $width]
        ad_script_abort
    }
}
ns_returnnotfound
ad_script_abort
