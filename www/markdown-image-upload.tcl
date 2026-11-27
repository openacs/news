ad_page_contract {
    Stage a bitmap pasted into a News article or revision form.
} {
    grant:notnull
}

if {[ns_conn method] ne "POST"} {
    ns_return 405 text/plain "Use POST to upload an image."
    ad_script_abort
}

auth::require_login
set token [security::csrf::new]
if {$token eq "" || [ns_queryget __csrf_token] ne $token
    || [catch {security::parameter::validated $grant} scope]} {
    ns_return 403 text/plain "Invalid upload token."
    ad_script_abort
}
lassign $scope purpose package_id user_id article_id
if {$purpose ne "news-markdown-image" || $package_id ne [ad_conn package_id]
    || $user_id ne [ad_conn user_id]} {
    ns_return 403 text/plain "Invalid upload scope."
    ad_script_abort
}
if {![news::markdown_image::enabled_p]} {
    ns_return 403 text/plain "Image paste is disabled or unavailable for this News instance."
    ad_script_abort
}
if {$article_id eq ""} {
    permission::require_permission -object_id $package_id -privilege news_create
} else {
    permission::require_permission -object_id $package_id -privilege news_admin
    if {![news::markdown_image::owns_article $package_id $article_id]} {
        ns_returnnotfound
        ad_script_abort
    }
}

set files [ns_getformfile upload]
if {[llength $files] != 1 || ![security::safe_tmpfile_p -must_exist [lindex $files 0]]} {
    ns_return 400 text/plain "Upload one image."
    ad_script_abort
}
set file [lindex $files 0]
if {[news::markdown_image::mime_type $file] eq ""} {
    ns_return 415 text/plain "Paste a PNG, JPEG, or GIF image."
    ad_script_abort
}

set image_id [db_nextval acs_object_id_seq]
set directory [news::markdown_image::directory]
file mkdir $directory
set channel [file tempfile temporary $directory/upload-]
close $channel
try {
    file copy -force -- $file $temporary
    file attributes $temporary -permissions 0600
    file rename -- $temporary [news::markdown_image::draft_path $image_id]
} finally {
    file delete -- $temporary
}
# Dimensions are rendering hints only; delivery always inspects the actual file.
lassign [ns_imgsize $file] image_width image_height
ns_return 201 text/plain [export_vars -base [ad_conn package_url]markdown-image {image_id image_width image_height}]
ad_script_abort
