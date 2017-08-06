<?xml version="1.0"?>

<queryset>
    <rdbms><type>oracle</type><version>8.1.7</version></rdbms>

    <fullquery name="callback::search::url::impl::news.select_news_package_url">
        <querytext>
            select site_node.url(min(node_id))
            from site_nodes
            where object_id = :package_id
        </querytext>
    </fullquery>
</queryset>
