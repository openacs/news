ad_library {
    Library for news's callback implementations

    Callbacks for search package.

    @author Enrique Catalan <quio@galileo.edu>
    @creation-date July 19, 2005
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

ad_proc -public -callback datamanager::move_new -impl datamanager {
     -object_id:required
     -selected_community:required
} {
    Move a new to another class or community
} {
     set new_package_id [news_get_package_id -community_id $selected_community]

db_dml update_news {}
db_dml update_news_acs_objects_1 {}
db_dml update_news_acs_objects_2 {}
}

ad_proc -public -callback datamanager::copy_new -impl datamanager {
     -object_id:required
     -selected_community:required
} {
    Copy a new to another class or community
} {
#get environment data
    set package_id [news_get_package_id -community_id $selected_community]

#get the revision's data

    set news_revisions_list [db_list_of_lists get_news_revisions_data {}]
    set news_revisions_number [llength $news_revisions_list]

#do the first revision
    set present_object_id [lindex [lindex $news_revisions_list 1] 0]
    db_1row get_news_data {}    
    set publish_date_ansi  [lindex [lindex $news_revisions_list 1] 1]
    set publish_body  [lindex [lindex $news_revisions_list 1] 2]   
    set mime_type     [lindex [lindex $news_revisions_list 1] 3]  
    set publish_title [lindex [lindex $news_revisions_list 1] 4]     


    set live_revision_p "t"

#create the new
    set news_id [news_create_new -publish_body $publish_body \
                                 -publish_title $publish_title \
                                 -publish_date_ansi $publish_date_ansi \
                                 -mime_type $mime_type \
                                 -package_id $package_id \
                                 -archive_date_ansi $archive_date_ansi \
                                 -approval_user $approval_user \
                                 -approval_date $approval_date \
                                 -approval_ip $approval_ip \
                                 -creation_ip $creation_ip \
                                 -user_id $user_id \
                                 -live_revision_p $live_revision_p \
                                 -publish_lead $publish_lead ]


#if there are revisions, they are included here   
    for {set i 2} {$i < $news_revisions_number} {incr i} {
 
        set present_object_id [lindex [lindex $news_revisions_list $i] 0]
        db_1row get_news_data {}       
        db_1row get_present_new_item {}       

        set publish_date_ansi  [lindex [lindex $news_revisions_list $i] 1]
        set publish_body  [lindex [lindex $news_revisions_list $i] 2]   
        set mime_type     [lindex [lindex $news_revisions_list $i] 3]  
        set publish_title [lindex [lindex $news_revisions_list $i] 4]         
        set revision_log [lindex [lindex $news_revisions_list $i] 5]        
#        db_1row get_live_revision {}           
#        if {$live_revision == $present_object_id} {
#            set active_revision_p "t"    
#        } else {
#            set active_revision_p "f"
#        }                       
set active_revision_p "t"    

     db_exec_plsql create_news_item_revision {}
    }  
#does the new includes images?


return $news_id    
}


ad_proc -public -callback datamanager::delete_new -impl datamanager {
     -object_id:required
} {
    Move a new to the trash
} {
     set trash_package_id [datamanager::get_trash_package_id]

db_dml del_update_news {}
db_dml del_update_news_acs_objects_1 {}
db_dml del_update_news_acs_objects_2 {}
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
