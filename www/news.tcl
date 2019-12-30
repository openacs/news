ad_include_contract {
    /packages/news/www/news.tcl

    Display one news revision.
} {
    item_id:naturalnum,optional
    publish_title:optional
    publish_lead:html,optional
    publish_image:localurl,optional
    publish_body:html
    creator_link:html
    publish_format:notnull
}

set publish_body [ad_html_text_convert -from $publish_format -to text/html -- $publish_body]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
