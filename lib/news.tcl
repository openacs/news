ad_include_contract {
    Display one news revision.
} {
    publish_title:optional
    publish_lead:optional
    publish_body:allhtml
    creator_link:html
    publish_format:notnull
}

set publish_body [ad_html_text_convert -from $publish_format -to text/html -- $publish_body]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
