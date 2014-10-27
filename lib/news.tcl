# /packages/news/www/news.tcl
# Display one news revision.

set publish_body [ad_html_text_convert -from $publish_format -to text/html -- $publish_body]
