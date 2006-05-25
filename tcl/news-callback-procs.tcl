ad_library {
    Callbacks for search package.

    @author Dirk Gomez <openacs@dirkgomez.de>
    @creation-date 2005-06-12
    @cvs-id $Id$
}

##################
# Search callbacks
##################


ad_proc -public -callback search::datasource -impl news {} {

    @author openacs@dirkgomez.de
    @creation_date 2005-06-13

    returns a datasource for the search package
    this is the content that will be indexed by the full text
    search engine.

} {
    # Dirk Gomez: This needs to be refactored urgently, best when
    # somebody touches the news package anyway.  I copied this
    # straight from packages/news/lib/item.tcl. This page should be
    # put into a proc and then the search callback needs to be
    # refactored to make use of the new proc.

    set item_id $object_id

    set item_exist_p [db_0or1row one_item "
      select item_id,
       live_revision,
       publish_title,
       publish_lead,
       html_p,
       publish_date,
       creation_user,
       item_creator,
       publish_body
         from   news_items_live_or_submitted
         where  item_id = :item_id"]
        
    if { $item_exist_p } {
	
	# workaround to get blobs with >4000 chars into a var, content.blob_to_string fails! 
	# when this'll work, you get publish_body by selecting 'publish_body' directly from above view
	#
	# RAL: publish_body is already snagged in the 1st query above for postgres.
	#
	set get_content [db_map get_content]
	if {![string match "" $get_content]} {
	    set publish_body [db_string get_content "select  content
	      from    cr_revisions
	      where   revision_id = :live_revision"]
	}
	
	# text-only body
	if {[info exists html_p] && [string equal $html_p "f"]} {
	    set publish_body [ad_text_to_html -- $publish_body]
	}
	
	if { [ad_parameter SolicitCommentsP "news" 0]} {
	    set comments [general_comments_get_comments -print_content_p 1 -print_attachments_p 1 \
			      $item_id "[ad_conn package_url]item?item_id=$item_id"]
	} else {
	    set comments ""
	}
	
	# This is new, refactor everything above (Dirk Gomez)
	set combined_content "$publish_title\n"
	append combined_content "$publish_body\n"
	append combined_content "$comments\n"
	
    } else {
	set combined_content ""
	set publish_title ""
    }

    return [list object_id $object_id \
                title $publish_title \
                content $combined_content \
                keywords {} \
                storage_type text \
                mime text/plain ]
}

ad_proc -public -callback search::url -impl news {} {

    @author openacs@dirkgomez.de
    @creation_date 2005-06-13

    returns a url for a calendar item to the search package

} {
    db_1row get {
        select
        package_id
        from news_items_live_or_submitted
        where item_id = :object_id
        or item_id = (select item_id from cr_revisions where revision_id = :object_id)}

    return "[ad_url][db_string select_news_package_url {}]item?item_id=$object_id"
}

ad_proc -callback application-track::getApplicationName -impl news {} { 
        callback implementation 
    } {
        return "news"
    }    
    
    ad_proc -callback application-track::getGeneralInfo -impl news {} { 
        callback implementation 
    } {
	db_1row my_query {
    		SELECT count(1) as result
		FROM news_items_approved news,dotlrn_communities_full com
		WHERE community_id=:comm_id
		and apm_package__parent_id(news.package_id) = com.package_id		
	}
	
	return "$result"
    }      
    
 
    ad_proc -callback application-track::getSpecificInfo -impl news {} { 
        callback implementation 
    } {
   	
	upvar $query_name my_query
	upvar $elements_name my_elements

	

	set my_query {
		SELECT news.publish_title as name, news.item_creator as creator,news.publish_body as message,news.pretty_publish_date as initial_date, news.publish_date as finish_date
		FROM news_items_approved news,dotlrn_communities_full com
		WHERE community_id=:class_instance_id
		and apm_package__parent_id(news.package_id) = com.package_id }
		
	set my_elements {
    		name {
	            label "Name"
	            display_col name	                                    
	 	    html {align center}	 	    
		                
	        }
	        creator {
	            label "Creator"
	            display_col creator 	      	              
	 	    html {align center}	 	          
	        }
	        message {
	            label "Message"
	            display_col message 	      	              
	 	    html {align center}	 	          
	        }
	        initial_date {
	            label "Initial Date"
	            display_col initial_date 	      	              
	 	    html {align center}	 	          
	        }
	        finish_date {
	            label "Finish Date"
	            display_col finish_date 	      	               
	 	    html {align center}	 	                
	        }
	}
        return "OK"
    }         