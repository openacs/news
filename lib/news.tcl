# /packages/news/www/news.tcl
# Display one news revision.

set publish_body [ad_html_text_convert -from $publish_format -to text/html -- $publish_body]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
