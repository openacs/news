ad_library {
    Stage pasted News images until the article or revision is saved.
}

namespace eval ::news::markdown_image {}

ad_proc -private ::news::markdown_image::directory {} {
    Return the staging directory for pasted News images.
} {
    return [file join [ns_config ns/parameters tmpdir] news-markdown-images]
}

ad_proc -private ::news::markdown_image::draft_path {image_id} {
    Find the staged image belonging to this user and News instance.
} {
    return [file join [directory] "[ad_conn package_id].[ad_conn user_id].$image_id"]
}

ad_proc -private ::news::markdown_image::mime_type {path} {
    Identify a supported bitmap by its contents.
} {
    if {![file isfile $path] || [catch {ns_imgtype $path} type] || $type ni {png jpeg gif}
        || [catch {ns_imgsize $path} size] || [llength $size] != 2
        || [lindex $size 0] <= 0 || [lindex $size 1] <= 0} {
        return ""
    }
    return image/$type
}

ad_proc -private ::news::markdown_image::enabled_p {} {
    Check the current News instance's image-paste policy and Attachments service.
    Existing attached images remain readable independently of this setting.
} {
    return [expr {[string is true -strict [parameter::get \
                       -package_id [ad_conn package_id] -parameter AllowImagePasteP -default 0]]
                  && [apm_package_enabled_p attachments]
                  && [namespace which ::attachments::richtext::file_attach] ne ""}]
}

ad_proc -private ::news::markdown_image::upload_url {{item_id ""}} {
    Issue an upload grant for the current article form.
} {
    if {[ad_conn user_id] == 0 || ![enabled_p]} {
        return ""
    }
    set grant [security::parameter::signed -max_age 86400 \
                   [list news-markdown-image [ad_conn package_id] [ad_conn user_id] $item_id]]
    return [export_vars -base [ad_conn package_url]markdown-image-upload {grant}]
}

ad_proc -private ::news::markdown_image::owns_article {package_id item_id} {
    Check that the article is in this News instance.
} {
    return [db_string news_markdown_image_article {
        select 1
        from news_items_live_or_submitted
        where item_id = :item_id and package_id = :package_id
    } -default 0]
}

ad_proc -private ::news::markdown_image::drafts {content format} {
    Collect this editor's staged images referenced by the article HTML.
} {
    set prefix [ad_conn package_url]markdown-image?image_id=
    if {$format ne "text/html" || [string first $prefix $content] == -1} {
        return {}
    }

    set drafts {}
    foreach tag [ns_parsehtml -onlytags -- $content] {
        lassign $tag element attributes
        if {![string equal -nocase $element img] || ![dict exists $attributes src]} continue
        set src [dict get $attributes src]
        if {[string first $prefix $src] != 0} continue
        # Responsive delivery adds query parameters after the stable image identity.
        set image_id [lindex [split [string range $src [string length $prefix] end] &] 0]
        if {![regexp {^[1-9][0-9]*$} $image_id] || [dict exists $drafts $image_id]} continue
        if {[acs_object_type $image_id] ne ""} continue

        set path [draft_path $image_id]
        set mime [mime_type $path]
        if {$mime eq "" || [ad_conn user_id] == 0
            || ![enabled_p]} {
            return -code error -errorcode {NEWS IMAGE UNAVAILABLE} "A pasted image is unavailable. Remove it or paste it again."
        }
        dict set drafts $image_id [list $path $mime]
    }
    return $drafts
}

ad_proc -private ::news::markdown_image::require_drafts {content format} {
    Collect drafts or return the normal News form error for an expired upload.
} {
    try {
        return [drafts $content $format]
    } trap {NEWS IMAGE UNAVAILABLE} {message} {
        ad_return_complaint 1 $message
        ad_script_abort
    }
}

ad_proc -private ::news::markdown_image::attach {item_id drafts} {
    Attach these images to the article item shared by its revisions.
} {
    dict for {image_id draft} $drafts {
        lassign $draft path mime
        set result [attachments::richtext::file_attach \
                        -item_id $image_id -object_id $item_id \
                        -import_file $path -mime_type $mime \
                        -title "Pasted image.[lindex [split $mime /] 1]" \
                        -user_id [ad_conn user_id] -peeraddr [ad_conn peeraddr] \
                        -package_id [ad_conn package_id]]
        if {![dict get $result success]} {
            error "Could not attach the pasted image."
        }
        ns_atclose [list ::news::markdown_image::discard_attached_draft $item_id $image_id $path]
    }
}

ad_proc -private ::news::markdown_image::discard_attached_draft {item_id image_id path} {
    Remove the draft after the article and attachment have committed.
} {
    if {[db_string news_markdown_image_committed {
        select 1 from attachments where object_id = :item_id and item_id = :image_id
    } -default 0]} {
        file delete -- $path
    }
}

ad_proc -private ::news::markdown_image::expire_drafts {} {
    Clean up abandoned uploads.
} {
    set cutoff [expr {[clock seconds] - 86400}]
    foreach path [glob -nocomplain -directory [directory] -types f *] {
        catch {
            if {[file mtime $path] < $cutoff} {
                file delete -- $path
            }
        }
    }
}
