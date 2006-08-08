ad_library {
    Library for news's callback implementations

    Callbacks for search package.

    @author Dirk Gomez <openacs@dirkgomez.de>
    @creation-date 2005-06-12
    @cvs-id $Id$
}

ad_proc -callback merge::MergeShowUserInfo -impl news {
    -user_id:required
} {
    Show the news items 
} {
    set msg "News items of $user_id"
    ns_log Notice $msg
    set result [list $msg]

    set news [db_list_of_lists getaprovednews { *SQL* }]

    lappend result $news

    return $result
}

ad_proc -callback merge::MergePackageUser -impl news {
    -from_user_id:required
    -to_user_id:required
} {
    Merge the news of two users.
} {
    set msg "Merging news"
    ns_log Notice $msg
    set result [list $msg]

    db_dml update_from_news_approval { *SQL* }

    lappend result "Merge of news is done"

    return $result
}

#Callbacks for application-track

ad_proc -callback application-track::getApplicationName -impl news {} { 
        callback implementation 
    } {
        return "news"
    }    
    
ad_proc -callback application-track::getGeneralInfo -impl news {} { 
        callback implementation 
    } {
	db_1row my_query {
    		select count(n.item_id) as result
		FROM news_items_approved n, dotlrn_class_instances_full com
		WHERE class_instance_id=:comm_id
		and apm_package__parent_id(n.package_id) = com.package_id		
	}
	
	return "$result"
    }      
    
 
ad_proc -callback application-track::getSpecificInfo -impl news {} { 
        callback implementation 
    } {
   	
	upvar $query_name my_query
	upvar $elements_name my_elements

	set my_query {
		SELECT news.publish_title as name, news.pretty_publish_date as initial_date, news.publish_date as finish_date
		FROM news_items_approved news,dotlrn_communities_full com
		WHERE community_id=:class_instance_id
		and apm_package__parent_id(news.package_id) = com.package_id }
		
	set my_elements {
    		name {
	            label "Name"
	            display_col name	                                    
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
