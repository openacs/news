################################################################################
#
#  News package database and database configuration tests.
#
################################################################################

ad_library {
    acs-automated-testing test definitions for the news package to be sourced on
    server startup.

    @author peter.harper@open-msg.com
    @creation-date 2001-11-18
    @cvs-id $Id$
}


################################################################################
#                                                                              #
#                         I N I T  C L A S S E S                               #
#                                                                              #
################################################################################

################################################################################
#
# Init Class mount-news-package
#
aa_register_init_class "mount-news-package" {
    Mounts a copy of the news package in "/_test/news".
} {
    # Constructor
    # Export variables we want to be visible to the testcase and the destructor.
    aa_export_vars {_root_node_id _test_node_id _news_node_id _news_package_id
        _news_package_mounted_p _news_package_mounted_err}

    #
    # Firstly, make sure the mount point "/_test/news" exists.
    #
    set _news_node_id    -1
    set _test_node_id    -1
    set _root_node_id    -1
    set _news_package_id -1
    db_foreach get-site-nodes {
        select node_id, object_id, site_node.url(node_id) as url from site_nodes
    } {
        switch [string trim $url] {
            "/_test/news/" {
                set _news_node_id $node_id
                if {$object_id ne ""} {
                    set _news_package_id $object_id
                }
            }
            "/_test/" {
                set _test_node_id $node_id
            }
            "/" {
                set _root_node_id $node_id
            }
        }
    }

    set _news_package_mounted_p 1
    if {[catch {
        # Create the _test directory if it doesn't already exist.
        aa_log "here"
        if {$_test_node_id == -1} {
            set _test_node_id [site_node::new \
                                   -name "_test" \
                                   -parent_id $_root_node_id ]
        }
        # If an old news package exists, delete it.
        if {$_news_node_id != -1} {
            aa_log "Unmont and delete existing node instance."
            site_node::unmount -node_id $_news_node_id
            site_node::delete -node_id $_news_node_id
            if {$_news_package_id != -1} {
                aa_log "Deleting existing package instance."
                set p_package_id $_news_package_id
                rss_support::del_subscription -summary_context_id $p_package_id -owner news -impl_name news
                db_exec_plsql package-delete {
                    begin
                    apm_package.del(:p_package_id);
                    end;
                }
            }
        }

        # Mount the new news package and lookup the new node_id.
        set _news_package_id [site_node::instantiate_and_mount \
                                  -parent_node_id $_test_node_id \
                                  -node_name news \
                                  -package_name "News test" \
                                  -package_key news]

        set _news_node_id [site_node::get_node_id -url "/_test/news/"]
    } _news_package_mounted_err]} {
        set _news_node_id -1
        set _test_node_id -1
        set _root_node_id -1
        set _news_package_mounted_p 0
    }
} {
    # Destructor

    #
    # Unmount the news package and delete its directory.
    #
    if {$_news_package_mounted_p} {
        site_node::unmount -node_id $_news_node_id
        site_node::delete -node_id $_news_node_id
        site_node::delete -node_id $_test_node_id
        set p_package_id $_news_package_id
        rss_support::del_subscription -summary_context_id $p_package_id -owner news -impl_name news
        db_exec_plsql package-delete {
            begin
            apm_package.del(:p_package_id)
        }
    }
}


################################################################################
#                                                                              #
#                         C O M P O N E N T S                                  #
#                                                                              #
################################################################################

################################################################################
#
# Component db-news-globals
#
aa_register_component "db-news-globals" {
    Sets up general information regarding the news package
    <br>
    Exports:<br>
    _news_cr_root_folder_id<br>
    _news_cr_news_root_folder_id
} {
    aa_export_vars {_news_cr_root_folder_id _news_cr_news_root_folder_id}
    
    set _news_cr_root_folder_id [content::item::get_root_folder]
    set p_parent_id $_news_cr_root_folder_id
    set _news_cr_news_root_folder_id [db_string get-cr-news-root-folder {
        select item_id
        from cr_items
        where parent_id = :p_parent_id
        and   name = 'news'
    }]
}

################################################################################
#
# Component db-news-item-create
#
aa_register_component "db-news-item-create" {
    Creates a news item.  Expects the following variables to be populated:<br>
    p_title<br>
    p_text<br>
    p_package_id<br>
    p_is_live<br>
    p_full_details<br>
    <p>
    Populates:<br>
    news_id
} {
    aa_export_vars {p_full_details p_title p_text p_package_id p_is_live
        p_approval_user p_approval_ip p_approval_date p_archive_date 
        news_id}
    if {$p_full_details == "t"} {
        set p_approval_user [ad_conn "user_id"]
        set p_approval_ip   [ad_conn "peeraddr"]
        set p_approval_date [dt_sysdate]
        set p_archive_date  [dt_sysdate]
    } else {
        set p_approval_user [db_null]
        set p_approval_ip   [db_null]
        set p_approval_date [db_null]
        set p_archive_date  [db_null]
    }
    set news_id [db_exec_plsql item-create {
        begin
        :1 := news.new(
                       text => :p_text,
                       title => :p_title,
                       package_id => :p_package_id,
                       archive_date => :p_archive_date,
                       approval_user => :p_approval_user,
                       approval_date => :p_approval_date,
                       approval_ip   => :p_approval_ip,
                       is_live_p     => :p_is_live
                       );
        end;
    }]
}

################################################################################
#
# Component db-news-item-delete
#
aa_register_component "db-news-item-delete" {
    Deletes a news item.  Expects the following variables to be populated:<br>
    p_news_id<br>
} {
    aa_export_vars {p_item_id}
    db_exec_plsql item-delete {
        begin
        news.del(:p_item_id);
        end;
    }
}

################################################################################
#
# Component db-news-revision-create
#
aa_register_component "db-news-revision-create" {
    Creates a news item revision.  Expects the following variables to be populated:<br>
    p_title<br>
    p_text<br>
    p_description<br>
    p_package_id<br>
    p_make_active_revision_p<br>
    p_full_details<br>
    <p>
    Populates:<br>
    revision_id
} {
    aa_export_vars {p_item_id 
        p_full_details p_title p_text p_package_id p_make_active_revision_p
        p_description
        p_approval_user p_approval_ip p_approval_date p_archive_date 
        revision_id}
    if {$p_full_details == "t"} {
        set p_approval_user [ad_conn "user_id"]
        set p_approval_ip   [ad_conn "peeraddr"]
        set p_approval_date [dt_sysdate]
        set p_archive_date  [dt_sysdate]
    } else {
        set p_approval_user [db_null]
        set p_approval_ip   [db_null]
        set p_approval_date [db_null]
        set p_archive_date  [db_null]
    }
    set revision_id [db_exec_plsql revision-create {
        begin
        :1 := news.revision_new(
                                item_id => :p_item_id,
                                text => :p_text,
                                title => :p_title,
                                package_id => :p_package_id,
                                archive_date =>  :p_archive_date,
                                approval_user => :p_approval_user,
                                approval_date => :p_approval_date,
                                approval_ip   => :p_approval_ip,
                                make_active_revision_p => :p_make_active_revision_p
                                );
        end;
    }]
}

################################################################################
#
# Component db-news-get-live-revision
#
aa_register_component "db-news-get-live-revision" {
    Retrieves the id of the live revision of an item_id
    p_item_id<br>
    Provides<br>
    live_revision_id
} {
    aa_export_vars {p_item_id live_revision_id}
    set live_revision_id [db_exec_plsql get-live-revision {
        begin
        :1 := content_item.get_live_revision(:p_item_id);
        end;
    }]
}

################################################################################
#
# Component db-news-get-latest-revision
#
aa_register_component "db-news-get-latest-revision" {
    Retrieves the id of the latest revision of an item_id
    p_item_id<br>
    Provides<br>
    latest_revision_id
} {
    aa_export_vars {p_item_id latest_revision_id}
    set latest_revision_id [db_exec_plsql get-latest-revision {
        begin
        :1 := content_item.get_latest_revision(:p_item_id);
        end;
    }]
}

################################################################################
#
# Component db-news-set-approve
#
aa_register_component "db-news-set-approve" {
    Sets or removes the approved status on a news article<br>
    Expects<br>
    p_revision_id<br>
    p_approve_p<br>
    p_publish_date (if p_approve_p == 't')<br>
    p_archive_date (if p_approve_p == 't')<br>
    p_approval_user (if p_approve_p == 't')<br>
    p_approval_date (if p_approve_p == 't')<br>
    p_approval_ip (if p_approve_p == 't')<br>
    p_live_revision_p (if p_approve_p == 't')<br>
} {
    aa_export_vars {p_revision_id
        p_approve_p p_publish_date p_archive_date
        p_approval_user p_approval_date p_approval_ip
        p_live_revision_p}

    if {$p_approve_p == "f"} {
        db_exec_plsql set-approve-default {}
    } else {
        db_exec_plsql set-approve {}
    }
}

################################################################################
#
# Component db-news-revision-set-active
#
aa_register_component "db-news-revision-set-active" {
    Sets a specific revision as the live version of the item
    Requires:<br>
    p_revision_id<br>
} {
    aa_export_vars {p_revision_id}
    db_exec_plsql revision-set-active {
        begin
        news.revision_set_active(:p_revision_id);
        end;
    }
}

################################################################################
#
# Component db-news-revision-delete
#
aa_register_component "db-news-revision-delete" {
    Deletes a news revision.  Expects the following variables to be populated:<br>
    p_revision_id<br>
} {
    aa_export_vars {p_revision_id}
    db_exec_plsql revision-delete {
        begin
        news.revision_delete(:p_revision_id);
        end;
    }
}

################################################################################
#
# Component db-get-cr-news-row
#
aa_register_component "db-get-cr-news-row" {
    Retrieves the cr_news row information for the given news_id:
    Expects: <br>
    p_news_id<br>
    In addition to the actual row data, populates:<br>
    retrieval_ok_p<br>
} {
    aa_export_vars {p_news_id
        package_id archive_date approval_user approval_date approval_ip
        retrieval_ok_p}
    set retrieval_ok_p 1
    if {![db_0or1row get-cr-news-row {
        select package_id, archive_date,
        approval_user, approval_date, approval_ip 
        from cr_news
        where news_id = :p_news_id
    }]} {
        set retrieval_ok_p 0
    }
}

################################################################################
#
# Component db-get-cr-revisions-row
#
aa_register_component "db-get-cr-revisions-row" {
    Retrieves the cr_revisions row information for the given news_id:
    Expects: <br>
    p_revision_id<br>
    In addition to the actual row data, populates:<br>
    retrieval_ok_p<br>
} {
    aa_export_vars {p_revision_id
        item_id title description publish_date mime_type nls_language
        content content_length
        retrieval_ok_p}
    set retrieval_ok_p 1
    if {![db_0or1row get-cr-revisions-row {
        select item_id, title, description, publish_date, mime_type,
        nls_language, content, content_length
        from cr_revisions
        where revision_id = :p_revision_id
    }]} {
        set retrieval_ok_p 0
    }
}

################################################################################
#
# Component db-get-cr-items-row
#
aa_register_component "db-get-cr-items-row" {
    Retrieves the cr_revisions row information for the given news_id:
    Expects: <br>
    p_revision_id<br>
    In addition to the actual row data, populates:<br>
    retrieval_ok_p<br>
} {
    aa_export_vars {p_item_id
        parent_id name live_revision latest_revision publish_status content_type
        retrieval_ok_p}
    set retrieval_ok_p 1
    if {![db_0or1row get-cr-items-row {
        select parent_id, name, live_revision, latest_revision,
        publish_status, content_type
        from cr_items
        where item_id = :p_item_id
    }]} {
        set retrieval_ok_p 0
    }
}

################################################################################
#
# Component db-news-make-permanent
#
aa_register_component "db-news-make-permanent" {
    Calls the news packages make_permanent function.
    p_item_id<br>
} {
    aa_export_vars {p_item_id}
    db_exec_plsql make-permanent {
        begin
        news.make_permanent(:p_item_id);
        end;
    }
}

################################################################################
#
# Component db-news-archive
#
aa_register_component "db-news-archive" {
    Calls the news packages archive function.
    p_item_id<br>
    p_archive_date<br>
} {
    aa_export_vars {p_item_id p_archive_date}
    if {$p_archive_date eq ""} {
        db_exec_plsql archive-default {
            begin
            news.archive(:p_item_id, null);
            end;
        }
    } else {
        db_exec_plsql archive {
            begin
            news.archive(:p_item_id, :p_archive_date);
            end;
        }
    }
}

################################################################################
#
# Component db-news-status
#
aa_register_component "db-news-status" {
    Calls the news packages status function.
    p_news_id<br>
} {
    aa_export_vars {p_publish_date p_archive_date status}

    set status [db_exec_plsql get-status {}]
}


################################################################################
#                                                                              #
#                           T E S T C A S E S                                  #
#                                                                              #
################################################################################

################################################################################
#
# Testcase check-permissions
#
aa_register_case -cats {
    db
    config
} -on_error {
    At least some of the news permission privileges aren't present, or have incorrect
    configurations.  The most probable cause of this is that the news package datamodel
    hasn't been installed.
} "check-permissions" {
    Checks the news related permissions.
    Checks that the permissions exist, and that they have the correct
    hierarchy.
} {
    #
    # Extract the list of all privileges and privilege hierarchies.
    #
    set priv_list {}
    db_foreach get-privileges {
        select privilege from acs_privileges
    } {
        lappend priv_list $privilege
    }

    set priv_h_list {}
    db_foreach get-privilege-hierarchies {
        select privilege, child_privilege from acs_privilege_hierarchy
    } {
        lappend priv_h_list "$privilege,$child_privilege"
    }

    aa_log "Check the news privileges exist"
    foreach priv {news_read news_create news_delete news_admin} {
        aa_true "Check $priv privilege exists" {[lsearch $priv_list $priv] != -1}
    }

    aa_log "Check the news privilege hierarchies are correct"
    foreach priv_pair {"read,news_read"
        "delete,news_delete"
        "news_admin,news_read"
        "news_admin,news_create"
        "news_admin,news_delete"
        "admin,news_admin"} {
        aa_true "Check $priv_pair privilege exists" {[lsearch $priv_h_list $priv_pair] != -1}
    }

    #
    # Now check that correct groups have the right privileges.
    #
    set registered_users_id [acs_magic_object registered_users]
    set the_public_id       [acs_magic_object the_public]

    aa_log "Check the correct groups have the right privileges."
    aa_true "Check public have news_read privilege" \
        [permission::permission_p -object_id $the_public_id -privilege news_read]
    aa_true "Check registered_users have news_create privilege" \
        [permission::permission_p -object_id $registered_users_id -privilege news_read]
}


################################################################################
#
# Testcase check_views
#
aa_register_case -cats {
    db
    config
} -on_error {
} "check_views" {
    Checks the news related views.
    Checks that the views are valid by performing a select from each of them.
} {
    aa_log "Check the news_items_approved view."
    set error_p 0
    db_transaction {
        db_1row select-from-news-items-approved {
            select count(*) from news_items_approved
        }
    } on_error {
        set error_p 1
    }
    aa_false "Select from news_items_approved view okay" {$error_p}


    aa_log "Check the news_items_live_or_submitted view."
    set error_p 0
    db_transaction {
        db_1row select-from-news-items-live-or-submitted {
            select count(*) from news_items_live_or_submitted
        }
    } on_error {
        set error_p 1
    }
    aa_false "Select from news_items_live_or_submitted view okay" {$error_p}


    aa_log "Check the news_items_unapproved view."
    set error_p 0
    db_transaction {
        db_1row select-from-news-items-unapproved {
            select count(*) from news_items_unapproved
        }
    } on_error {
        set error_p 1
    }
    aa_false "Select from news_items_unapproved view okay" {$error_p}


    aa_log "Check the news_item_revisions view."
    set error_p 0
    db_transaction {
        db_1row select-from-news-item-revisions {
            select count(*) from news_item_revisions
        }
    } on_error {
        set error_p 1
    }
    aa_false "Select from news_item_revisions view okay" {$error_p}


    aa_log "Check the news_item_unapproved view."
    set error_p 0
    db_transaction {
        db_1row select-from-news-item-unapproved {
            select count(*) from news_item_unapproved
        }
    } on_error {
        set error_p 1
    }
    aa_false "Select from news_item_unapproved view okay" {$error_p}


    aa_log "Check the news_item_full_active view."
    set error_p 0
    db_transaction {
        db_1row select-from-news-item-full-active {
            select count(*) from news_item_full_active
        }
    } on_error {
        set error_p 1
    }
    aa_false "Select from news_item_full_active view okay" {$error_p}
}


################################################################################
#
# Testcase check_object_type
#
aa_register_case -cats {
    db
    config
} -on_error {
    The "news" object type doesn't exist, or has isn't configured correctly. 
    The most probable cause of this is that the news package datamodel hasn't been
    installed.
} "check_object_type" {
    Checks the news object type.
} {
    set news_type_exists_p [db_0or1row get-news-type-info {
        select supertype
        from acs_object_types
        where object_type = 'news'
    }]

    aa_true "Check news object type exists" {$news_type_exists_p}

    if {$news_type_exists_p} {
        aa_equals "Check the supertype is content_revision" $supertype "content_revision"

        db_foreach get-news-type-attribs {
            select attribute_name
            from acs_attributes
            where object_type = 'news'
        } {
            lappend attribs $attribute_name
        }
        aa_log "Check the news object attributes exist"
        foreach attribute_name {"archive_date"
            "approval_user"
            "approval_date"
            "approval_ip"} {
            aa_true "Check $attribute_name exists" {[lsearch $attribs $attribute_name] != -1}
        }

        set news_folder_exists_p [db_0or1row get-news-cr-folder {
            select folder_id
            from cr_folders
            where label = 'news'
        }]
        aa_true "Check news content_repository folder exists" {$news_folder_exists_p}
    }
}

################################################################################
#
# Testcase check_package_mount
#
aa_register_case -cats {
    db
} -init_classes {
    mount-news-package
} -on_error {
} "check_package_mount" {
    Checks the mountability of the news package.
} {
    aa_true "Check that the news package mount properly" $_news_package_mounted_p
    if {$_news_package_mounted_p} {
        aa_log "News node_id    :$_news_node_id"
        aa_log "News package_id :$_news_package_id"
    } else {
        aa_error "Error from initializer: $_news_package_mounted_err"
    }
}


################################################################################
#
# Testcase db_check_news_create
#
aa_register_case -cats {
    db
} -init_classes {
    mount-news-package
} "db_check_news_create" {
    Creates and deletes a simple news article.  Checks contents of cr_news,
    cr_items and cr_revisions table after insert. Calls the news name function to retrieve
    the article name.  Tests <tt>news.new</tt>, <tt>news.delete</tt> and <tt>news.name</tt>.
} {
    set news_id -1

    if {!$_news_package_mounted_p} {
        aa_error "News package not mounted, error from initializer: $_news_package_mounted_err"
    } else {
        #
        # Attempt to create the article
        #
        set p_title         "My title"
        set p_text          "My text"
        set p_package_id    $_news_package_id
        set p_is_live       "t"
        set p_full_details  "t"
        aa_call_component db-news-globals
        aa_call_component db-news-item-create
    }
} {
    aa_true "Check the news_id is populated" {$news_id != -1}
    set item_id -1
    if {$news_id != -1} {
        aa_log "News id: $news_id"
        #
        # Retrieve the row from cr_news table and check its contents.  Notice that we
        # only check the date portion of the date strings.
        #
        aa_log "Retrieve cr_news row and check its contents"
        set p_news_id $news_id
        aa_call_component db-get-cr-news-row
        if {!$retrieval_ok_p} {
            aa_error "cr_news column not found for news_id $news_id"
        } else {
            aa_equals "Check package_id correct"    $package_id $_news_package_id
            aa_equals "Check archive_date correct"  \
                [string range $archive_date 0 [string length $p_archive_date]-1] \
                $p_archive_date
            aa_equals "Check approval_user correct" $approval_user $p_approval_user
            aa_equals "Check approval_date correct" \
                [string range $approval_date 0 [string length $p_approval_date]-1] \
                $p_approval_date
            aa_equals "Check approval_ip correct"   $approval_ip $p_approval_ip
        }

        #
        # Retrieve the row from cr_revisions table and check its contents.
        # NB: The get_cr_revisions_row populates item_id
        #
        aa_log "Retrieve cr_revisions row and check its contents"
        set p_revision_id $news_id
        aa_call_component db-get-cr-revisions-row
        if {!$retrieval_ok_p} {
            aa_error "cr_revisions row not found for news_id (revision_id) $news_id"
        } else {
            aa_equals "Check title correct"       $title       $p_title
            aa_equals "Check description correct" $description "initial submission"
            aa_equals "Check mime_type correct"   $mime_type   "text/plain"

            #
            # Retrieve the row from cr_items table and check its contents.
            #
            aa_log "Retrieve cr_items row and check its contents"
            set p_item_id $item_id
            aa_call_component db-get-cr-items-row
            if {!$retrieval_ok_p} {
                aa_error "cr_items row not found for item_id (revision_id) $news_id"
            } else {
                aa_equals "Check parent_id correct"     $parent_id $_news_cr_news_root_folder_id
                aa_equals "Check live_revision   correct" $live_revision   $news_id
                aa_equals "Check latest_revision correct" $latest_revision $news_id
                aa_equals "Check publish_status correct"  $publish_status  "ready"
                aa_equals "Check content_type correct"    $content_type    "news"

                #
                # Call the news.name function to retrieve the item name.
                #
                aa_log "Call news.name function to retrieve title of content revision"
                set p_news_id $news_id                
                set name [db_exec_plsql news-name {}]
                aa_equals "Check the return from news.name is correct" $name $p_title
            }
        }
    }
} {
    #
    # Delete the item.
    #
    if {$item_id != -1} {
        aa_log "Deleting the item."
        set p_item_id $item_id
        aa_call_component db-news-item-delete

        aa_log "Checking all table data removed."
        set p_news_id $news_id
        aa_call_component db-get-cr-news-row
        aa_false "Check the cr_news row was deleted" {$retrieval_ok_p}

        set p_item_id $item_id
        aa_call_component db-get-cr-items-row
        aa_false "Check the cr_items row was deleted" {$retrieval_ok_p}
        
        set p_revision_id $news_id
        aa_call_component db-get-cr-revisions-row
        aa_false "Check the cr_revisions row was deleted" {$retrieval_ok_p}
    }
}


################################################################################
#
# Testcase db_check_news_revision
#
aa_register_case -cats {
    db
} -init_classes {
    mount-news-package
} -on_error {
    This test may have failed because of a bug in the
    content_item.get_latest_revision
    database function; where two revisions are created so quickly that they
    have the same creation_date value associated with them.  This breaks the
    logic of the get latest revision function. This problem was found in the
    Alpha release of the OpenACS, and may have been fixed in later releases.
    <p>
    A posting <a href="http://openacs.org/bboard/q-and-a-fetch-msg.tcl?msg_id=0003CM&topic_id=14&topic=OpenACS%204%2e0%20Testing">
    here</a> at the OpenACS bboard was started concerning this problem.
} "db_check_news_revision" {
    Checks the news database functions for revision creation, deletion and management.
    Tests <tt>news.revison_new</tt>, <tt>news.revision_delete</tt>,
    <tt>news.revision_set_active</tt> functions.
} {
    set news_id -1

    if {!$_news_package_mounted_p} {
        aa_error "News package not mounted, error from initializer: $_news_package_mounted_err"
    } else {
        #
        # Create the article
        #
        set p_title         "My title"
        set p_text          "My text"
        set p_package_id    $_news_package_id
        set p_is_live       "t"
        set p_full_details  "t"
        aa_call_component db-news-globals
        aa_call_component db-news-item-create
    }
} {
    aa_true "Check the news_id is populated" {$news_id != -1}
    set item_id -1
    set revision1_id -1
    set revision2_id -1
    if {$news_id != -1} {
        aa_log "News id: $news_id"
        #
        # Retrieve the row from cr_revisions table to get item_id
        #
        set p_revision_id $news_id
        aa_call_component db-get-cr-revisions-row
        set revision1_id $news_id

        #
        # Check the first revision is the latest, and is live.
        #
        set p_item_id $item_id
        aa_call_component db-news-get-live-revision
        aa_call_component db-news-get-latest-revision
        aa_equals "Confirm that the initial revision of the article is the latest" \
            $latest_revision_id $revision1_id
        aa_equals "Confirm that the initial revision of the article is live" \
            $live_revision_id $revision1_id

        #
        # Create a new revision of the news article.
        #
        set p_item_id                $item_id
        set p_title                  "My title 2"
        set p_text                   "My text 2"
        set p_description            "Description 2"
        set p_package_id             $_news_package_id
        set p_full_details           "t"
        set p_make_active_revision_p "t"
        aa_call_component db-news-revision-create
        set revision2_id $revision_id

        #
        # Retrieve the cr_news column for the new revision
        #
        set p_news_id $revision2_id
        aa_call_component db-get-cr-news-row
        if {!$retrieval_ok_p} {
            aa_error "cr_news row not found for new revision news_id $revision2_id"
        } else {
            aa_log "Check the cr_news fields for the second revision"
            aa_equals "Check package_id correct"    $package_id $_news_package_id
            aa_equals "Check archive_date correct"  \
                [string range $archive_date 0 [string length $p_archive_date]-1] \
                $p_archive_date
            aa_equals "Check approval_user correct" $approval_user $p_approval_user
            aa_equals "Check approval_date correct" \
                [string range $approval_date 0 [string length $p_approval_date]-1] \
                $p_approval_date
            aa_equals "Check approval_ip correct"   $approval_ip $p_approval_ip

            #
            # Retrieve the row from cr_revisions table to get item_id
            #
            set p_revision_id $revision2_id
            aa_call_component db-get-cr-revisions-row
            if {!$retrieval_ok_p} {
                aa_error "cr_revisions row not found for new revision revision_id $revision2_id"
            } else {
                aa_equals "Check revision2 title correct"       $title       "My title 2"
                aa_equals "Check revision2 description correct" $description "Description 2"
                aa_equals "Check revision2 mime_type correct"   $mime_type   "text/plain"

                #
                # Check the second revision is now the latest, and is live.
                #
                set p_item_id $item_id
                aa_call_component db-news-get-live-revision
                aa_call_component db-news-get-latest-revision
                aa_equals "Confirm that the second revision of the article is the latest" \
                    $latest_revision_id $revision2_id
                aa_equals "Confirm that the second revision of the article is live" \
                    $live_revision_id $revision2_id

                #
                # Okay, lets set the original revision as active.
                #
                aa_log "Reset the first revision as live"
                set p_revision_id $revision1_id
                aa_call_component db-news-revision-set-active

                #
                # Check the second revision is still the latest, but the first one is live.
                #
                set p_item_id $item_id
                aa_call_component db-news-get-live-revision
                aa_call_component db-news-get-latest-revision
                aa_equals "Confirm that the second revision of the article is still the latest" \
                    $latest_revision_id $revision2_id
                aa_equals "Confirm that the first revision of the article is now live" \
                    $live_revision_id $revision1_id

                #
                # Delete the second revision
                #
                aa_log "Delete the second revision"
                set p_revision_id $revision2_id
                aa_call_component db-news-revision-delete

                #
                # Retrieve the row from cr_revisions table to get item_id
                #
                set p_revision_id $revision2_id
                aa_call_component db-get-cr-revisions-row
                aa_false "Check the revision row was deleted" $retrieval_ok_p
            }
        }
    }
} {
    #
    # Delete the item.
    #
    if {$item_id != -1} {
        aa_log "Deleting item."
        set p_item_id $item_id
        aa_call_component db-news-item-delete
    }
}

################################################################################
#
# Testcase db_check_news_archive
#
aa_register_case -cats {
    db
} -init_classes {
    mount-news-package
} "db_check_news_archive" {
    Checks the news database functions make_permanent and news_archive.
} {
    set news_id -1

    if {!$_news_package_mounted_p} {
        aa_error "News package not mounted, error from initializer: $_news_package_mounted_err"
    } else {
        #
        # Attempt to create the article
        #
        set p_title         "My title"
        set p_text          "My text"
        set p_package_id    $_news_package_id
        set p_is_live       "t"
        set p_full_details  "t"
        aa_call_component db-news-globals
        aa_call_component db-news-item-create
    }
} {
    aa_true "Check the news_id is populated" {$news_id != -1}
    set item_id -1
    if {$news_id != -1} {
        aa_log "News id: $news_id"
        #
        # Retrieve the row from cr_revisions table to get item_id
        #
        set p_revision_id $news_id
        aa_call_component db-get-cr-revisions-row

        #
        # Call make_permanent to nullify the archive_date.
        #
        set p_item_id $item_id
        aa_call_component db-news-make-permanent

        #
        # Retrieve the news row to check its archive date.
        #
        set p_news_id $news_id
        aa_call_component db-get-cr-news-row
        aa_equals "Check the archive_date is null" $archive_date [db_null]

        #
        # Set the archive period, providing an explicit archive date.
        #
        set p_item_id $item_id
        set p_archive_date "2005-11-05"
        aa_call_component db-news-archive

        #
        # Retrieve the news row to check its archive date.
        #
        set p_news_id $news_id
        aa_call_component db-get-cr-news-row
        aa_equals "Check the explicitly set archive_date is $p_archive_date" \
            [string range $archive_date 0 [string length $p_archive_date]-1] \
            $p_archive_date

        #
        # Set the archive period, relying on the overloaded "default" function for
        # archive_date.
        #
        set p_item_id $item_id
        set p_archive_date ""
        aa_call_component db-news-archive

        #
        # Retrieve the news row to check its archive date.
        #
        # Note, this could potentially fail if for some reason it executes over
        # midnight......
        #
        set p_news_id $news_id
        aa_call_component db-get-cr-news-row
        aa_true "Check the cr_news row was found" $retrieval_ok_p
        set todays_date [clock format [clock seconds] -format "%Y-%m-%d"]
        aa_equals "Check the explicitly set archive_date is $todays_date" \
            [string range $archive_date 0 [string length $todays_date]-1] \
            $todays_date
    }
} {
    #
    # Delete the item.
    #
    if {$item_id != -1} {
        aa_log "Deleting the item."
        set p_item_id $item_id
        aa_call_component db-news-item-delete
    }
}


################################################################################
#
# Testcase db_check_news_set_approve
#
aa_register_case -cats {
    db
} -init_classes {
    mount-news-package
} "db_check_news_set_approve" {
    Checks the news database function for approving/unapproving news articles.
    Tests <tt>news.set_approve</tt> function.
} {
    set news_id -1

    if {!$_news_package_mounted_p} {
        aa_error "News package not mounted, error from initializer: $_news_package_mounted_err"
    } else {
        #
        # Create the article
        #
        set p_title         "My title"
        set p_text          "My text"
        set p_package_id    $_news_package_id
        set p_is_live       "t"
        set p_full_details  "t"
        aa_call_component db-news-globals
        aa_call_component db-news-item-create
    }
} {
    aa_true "Check the news_id is populated" {$news_id != -1}
    set item_id -1
    set revision1_id -1
    set revision2_id -1
    if {$news_id != -1} {
        #
        # Retrieve the row from cr_revisions table to get item_id
        #
        set p_revision_id $news_id
        aa_call_component db-get-cr-revisions-row
        set revision1_id $news_id

        #
        # Create a new revision of the news article.
        #
        set p_item_id                $item_id
        set p_title                  "My title 2"
        set p_text                   "My text 2"
        set p_description            "Description 2"
        set p_package_id             $_news_package_id
        set p_full_details           "t"
        set p_make_active_revision_p "t"
        aa_call_component db-news-revision-create
        set revision2_id $revision_id

        #
        # Unapprove revision2.
        #
        set p_revision_id $revision2_id
        set p_approve_p "f"
        aa_call_component db-news-set-approve

        #
        # Retrieve the cr_news column for revision 2
        #
        set p_news_id $revision2_id
        aa_call_component db-get-cr-news-row
        if {!$retrieval_ok_p} {
            aa_error "cr_news row not found for new revision news_id $revision2_id"
        } else {
            aa_equals "Check the archive_date is null"  $archive_date  [db_null]
            aa_equals "Check the approval_date is null" $approval_date [db_null]
            aa_equals "Check the aprroval_user is null" $approval_user [db_null]
            aa_equals "Check the approval_ip is null"   $approval_ip   [db_null]
        }

        #
        # Retrieve the row from cr_revisions table to check publish date.
        #
        set p_revision_id $revision2_id
        aa_call_component db-get-cr-revisions-row
        if {!$retrieval_ok_p} {
            aa_error "cr_revisions row not found for new revision revision_id $revision2_id"
        } else {
            aa_equals "Check revision 2 publish_date is null" $publish_date [db_null]
        }

        #
        # Approve revision 1 and set it as the live revision.
        #
        set p_revision_id $revision1_id
        set p_approve_p "t"
        set p_publish_date  "2001-11-01"
        set p_archive_date  "2001-11-02"
        set p_approval_user [ad_conn "user_id"]
        set p_approval_date "2001-11-03"
        set p_approval_ip   [ad_conn "peeraddr"]
        set p_live_revision_p "t"
        aa_call_component db-news-set-approve

        #
        # Check the second revision is now live.
        #
        set p_item_id $item_id
        aa_call_component db-news-get-live-revision
        aa_equals "Confirm that revision 1 of the article is now live" \
            $live_revision_id $revision1_id

        #
        # Retrieve the cr_news column for revision 1
        #
        set p_news_id $revision1_id
        aa_call_component db-get-cr-news-row
        if {!$retrieval_ok_p} {
            aa_error "cr_news row not found for new revision news_id $revision1_id"
        } else {
            aa_equals "Check the archive_date is correct" \
                [string range $archive_date 0 [string length $p_archive_date]-1] \
                $p_archive_date
            aa_equals "Check the approval_date is correct" \
                [string range $approval_date 0 [string length $p_approval_date]-1] \
                $p_approval_date
            aa_equals "Check the aprroval_user is correct" \
                [string range $approval_user 0 [string length $p_approval_user]-1] \
                $p_approval_user
            aa_equals "Check the approval_ip is correct" \
                [string range $approval_ip 0 [string length $p_approval_ip]-1] \
                $p_approval_ip
        }

        #
        # Retrieve the row from cr_revisions table to check publish date.
        #
        set p_revision_id $revision1_id
        aa_call_component db-get-cr-revisions-row
        if {!$retrieval_ok_p} {
            aa_error "cr_revisions row not found for new revision revision_id $revision1_id"
        } else {
            aa_equals "Check revision 1 publish_date is null" \
                [string range $publish_date 0 [string length $p_publish_date]-1] \
                $p_publish_date
        }
    }
} {
    #
    # Delete the item.
    #
    if {$item_id != -1} {
        aa_log "Deleting item."
        set p_item_id $item_id
        aa_call_component db-news-item-delete
    }
}


################################################################################
#
# Testcase db_check_news_status
#
aa_register_case -cats {
    db
} -init_classes {
    mount-news-package
} "db_check_news_status" {
    Checks the news database function that returns information about a news article publish
    and archive status.
    Tests <tt>news.status</tt> function.
} {
    set news_id -1

    if {!$_news_package_mounted_p} {
        aa_error "News package not mounted, error from initializer: $_news_package_mounted_err"
    } else {
        #
        # Create the article
        #
        set p_title         "My title"
        set p_text          "My text"
        set p_package_id    $_news_package_id
        set p_is_live       "t"
        set p_full_details  "t"
        aa_call_component db-news-globals
        aa_call_component db-news-item-create
    }
} {
    aa_true "Check the news_id is populated" {$news_id != -1}
    set item_id -1
    set revision1_id -1
    set revision2_id -1
    if {$news_id != -1} {
        #
        # Retrieve the row from cr_revisions table to get item_id
        #
        set p_revision_id $news_id
        aa_call_component db-get-cr-revisions-row
        set revision1_id $news_id

        #
        # Unapprove revision 1 and set it as the live revision.
        #
        aa_log "Unapproving revision 1, setting publish_date null, archive_date null"
        set p_revision_id $revision1_id
        set p_approve_p "t"
        set p_publish_date  [db_null]
        set p_archive_date  [db_null]
        set p_approval_user [ad_conn "user_id"]
        set p_approval_date [db_null]
        set p_approval_ip   [ad_conn "peeraddr"]
        set p_live_revision_p "t"
        aa_call_component db-news-set-approve

        #
        # Check the status of revision 1.
        #
        set p_news_id $revision1_id
        aa_call_component db-news-status
        aa_equals "Unapproved status" $status unapproved

        #
        # Approve revision 1 and set it as the live revision.
        #
        aa_log "Approving revision 1, setting archive date as null"
        set p_revision_id $revision1_id
        set p_approve_p "t"
        set p_publish_date  [clock format [clock scan "+ 1 year"] -format %Y-%m-%d] ; # in the future
        set p_archive_date  [db_null]
        set p_approval_user [ad_conn "user_id"]
        set p_approval_date "2001-11-03"
        set p_approval_ip   [ad_conn "peeraddr"]
        set p_live_revision_p "t"
        aa_call_component db-news-set-approve

        #
        # Check the status of revision 1.
        #
        set p_news_id $revision1_id
        aa_call_component db-news-status
        aa_equals "Going live no archive status" $status going_live_no_archive

        #
        # Approve revision 1 and set it as the live revision.
        #
        aa_log "Approving revision 1, setting archive date as future value"
        set p_revision_id $revision1_id
        set p_approve_p "t"
        set p_publish_date  [clock format [clock scan "+ 1 year"] -format %Y-%m-%d] ; # in the future
        set p_archive_date  "2005-11-10"
        set p_approval_user [ad_conn "user_id"]
        set p_approval_date "2001-11-03"
        set p_approval_ip   [ad_conn "peeraddr"]
        set p_live_revision_p "t"
        aa_call_component db-news-set-approve

        #
        # Check the status of revision 1.
        #
        set p_news_id $revision1_id
        aa_call_component db-news-status
        aa_equals "Going live scheduled for archive status" $status going_live_with_archive

        #
        # Approve revision 1 and set it as the live revision.
        #
        aa_log "Approving revision 1, setting publish date in past, archive date null"
        set p_revision_id $revision1_id
        set p_approve_p "t"
        set p_publish_date  "2000-11-01"
        set p_archive_date  [db_null]
        set p_approval_user [ad_conn "user_id"]
        set p_approval_date "2001-11-03"
        set p_approval_ip   [ad_conn "peeraddr"]
        set p_live_revision_p "t"
        aa_call_component db-news-set-approve

        #
        # Check the status of revision 1.
        #
        set p_news_id $revision1_id
        aa_call_component db-news-status
        aa_equals "Published no archive status" $status published_no_archive

        #
        # Approve revision 1 and set it as the live revision.
        #
        aa_log "Approving revision 1, setting publish date in past, archive date in past"
        set p_revision_id $revision1_id
        set p_approve_p "t"
        set p_publish_date  "2000-11-01"
        set p_archive_date  "2000-11-01"
        set p_approval_user [ad_conn "user_id"]
        set p_approval_date "2001-11-03"
        set p_approval_ip   [ad_conn "peeraddr"]
        set p_live_revision_p "t"
        aa_call_component db-news-set-approve

        #
        # Check the status of revision 1.
        #
        set p_news_id $revision1_id
        aa_call_component db-news-status
        aa_equals "Archived status" $status archived

        #
        # Approve revision 1 and set it as the live revision.
        #
        aa_log "Approving revision 1, setting publish date in past, archive date in future"
        set p_revision_id $revision1_id
        set p_approve_p "t"
        set p_publish_date  "2000-11-01"
        set p_archive_date [clock format [clock scan "+ 1 year"] -format %Y-%m-%d] ; # in the future
        set p_approval_user [ad_conn "user_id"]
        set p_approval_date "2001-11-03"
        set p_approval_ip   [ad_conn "peeraddr"]
        set p_live_revision_p "t"
        aa_call_component db-news-set-approve

        #
        # Check the status of revision 1.
        #
        set p_news_id $revision1_id
        aa_call_component db-news-status
        aa_equals "Published with archive" $status published_with_archive
    }
} {
    #
    # Delete the item.
    #
    if {$item_id != -1} {
        aa_log "Deleting item."
        set p_item_id $item_id
        aa_call_component db-news-item-delete
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
