ad_page_contract {
    Allows the content creator to upload an image to be attached to the
    news item. All parameters are passed in so that we can link back to
    the preview page with all fields still in tact.

    @author Tom Ayles (tom@beatniq.net)
    @creation-date 2004-01-12
    @cvs-id $Id$
} {
    action
    publish_title
    publish_lead
    publish_body:allhtml
    revision_log:optional
    html_p
    publish_date_ansi
    archive_date_ansi
    permanent_p
    upload.tmpfile:optional,tmpfile
    item_id:optional
}

# make sure only authorised users can upload images
permission::require_permission \
    -object_id [ad_conn package_id] -privilege news_create


set vars {action publish_title publish_lead publish_body html_p
    publish_date_ansi archive_date_ansi permanent_p}

if {[info exists item_id]} { lappend vars item_id revision_log }

form create img -html {enctype multipart/form-data} \
    -edit_buttons {{{Upload} {ok}}}

foreach var $vars {
    element create img $var -datatype string -widget hidden -optional
}

element create img upload \
    -datatype file \
    -widget file \
    -label {File} \
    -html [list accept [parameter::get -parameter ImageUploadTypes]] \
    -validate [list img_type \
                   {test_file_type [ns_queryget upload.tmpfile]} \
                   "Image must be one of the following types: [parameter::get -parameter ImageUploadTypes]" \
                  ]

# clear the upload file value on every request, as it otherwise it displays
# filename, tmppath, mime type which isn't at all useful
element set_value img upload {}

if { [form is_request img] } {
    foreach var $vars { element set_value img $var [set $var] }
    if { [info exists item_id] } {
        set image_id [news_get_image_id $item_id]
        if { ![empty_string_p $image_id] } { set image_url "image/$image_id" }
    }
}

if { [form is_valid img] } {
    form get_values img upload
    set srcfile [ns_queryget upload.tmpfile]
    set imgfile [ImageMagick::tmp_file]
    ImageMagick::convert \
        -geometry [parameter::get -parameter ImageGeometry] \
        -output_format [parameter::get -parameter ImageFormat] \
        $srcfile $imgfile
    element set_value img upload {}
    set imgfile [ImageMagick::shorten_tmp_file $imgfile]
    set image_url "image-view-tmpfile/$imgfile"
    set form_vars [eval "export_form_vars [join $vars] imgfile"]
    set mode preview
} else {
    set mode form
}

ad_return_template
