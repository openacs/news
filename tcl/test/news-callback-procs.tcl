ad_library {
    Automated tests for news-callbacks.

    @author Luis de la Fuente (lfuente@it.uc3m.es)
    @creation-date 14 November 2005
}

aa_register_case news_move {
    Test the cabability of moving news.
} {    

    aa_run_with_teardown \
        -rollback \
        -test_code {
            #Create origin and destiny communities
            set origin_club_key [dotlrn_club::new -pretty_name [ad_generate_random_string]]
            set destiny_club_key [dotlrn_club::new -pretty_name [ad_generate_random_string]]    
            #Get origin and destiny packages
            set orig_package_id [news_get_package_id -community_id $origin_club_key]
            set dest_package_id [news_get_package_id -community_id $destiny_club_key]
            #create the new

            set news_id [news_create_new -package_id $orig_package_id]

            #is the forum at the origin?
            set orig_success_p [db_string orig_success_p {
                select 1 from cr_news where news_id  = :news_id and package_id = :orig_package_id
            } -default "0"]
            aa_equals "new is first at origin" $orig_success_p 1
            # Move the new
            callback -catch datamanager::move_new -object_id $news_id -selected_community $destiny_club_key


            #is the forum at the destiny?
            set dest_success_p [db_string dest_success_p {
                select 1 from cr_news where news_id = :news_id and package_id = :dest_package_id
            } -default "0"]

            #is the forum at the origin?
            set orig_success_p [db_string orig_success_p {
                select 0 from cr_news where news_id  = :news_id and package_id = :orig_package_id
            } -default "1"]

            aa_equals "new is not at origin" $orig_success_p 1
            aa_equals "new was moved succesfully" $dest_success_p 1

        }
}


aa_register_case news_copy {
    Test the cabability of copying news.
} {    

    aa_run_with_teardown \
        -rollback \
        -test_code {
            #Create origin and destiny communities
            set origin_club_key [dotlrn_club::new -pretty_name [ad_generate_random_string]]
            set destiny_club_key [dotlrn_club::new -pretty_name [ad_generate_random_string]]    
            #Get origin and destiny packages
            set orig_package_id [news_get_package_id -community_id $origin_club_key]
            set dest_package_id [news_get_package_id -community_id $destiny_club_key]

            #create the new
            set news_id [news_create_new -package_id $orig_package_id]

            #is the forum at the origin?
            set orig_success_p [db_string orig_success_p {
                select 1 from cr_news where news_id  = :news_id and package_id = :orig_package_id
            } -default "0"]
            aa_equals "new is first at origin" $orig_success_p 1

            set created_new [callback -catch datamanager::copy_new -object_id $news_id -selected_community $destiny_club_key]

            #is the forum at the destiny?
            set dest_success_p [db_string dest_success_p {
                select 1 from cr_news where news_id = :created_new and package_id = :dest_package_id
            } -default "0"]

            #is the forum at the origin?
            set orig_success_p [db_string orig_success_p {
                select 1 from cr_news where news_id  = :news_id and package_id = :orig_package_id
            } -default "0"]

            aa_equals "new is correctly placed at origin" $orig_success_p 1
            aa_equals "new was copied succesfully" $dest_success_p 1
           
        }
}

