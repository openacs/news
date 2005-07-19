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