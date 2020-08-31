ad_library {

    APM callbacks for the news package

    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-01-20
    @cvs-id $Id$
}

namespace eval ::news::install {}

ad_proc -private ::news::install::after_install {
} {
    Setup service contracts

    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-01-20

    @return

    @error
} {
    news::sc::register_news_fts_impl
    news::install::register_rss
    news::install::register_notifications

}

ad_proc -private ::news::install::register_rss {
} {
    setup RSS support
} {
    set spec {
        name "news"
        aliases {
            datasource news__rss_datasource
            lastUpdated news__last_updated
        }
        contract_name "RssGenerationSubscriber"
        owner "news"
    }
    acs_sc::impl::new_from_spec -spec $spec
}

ad_proc -private ::news::install::register_notifications {
} {
    setup notifications
} {
    db_transaction {
        # Create the impl and aliases for a news item
        set impl_id [create_news_item_impl]

        # Create the notification type for a news item
        set type_id [create_news_item_type $impl_id]

        # Enable the delivery intervals and delivery methods for a news item
        enable_intervals_and_methods $type_id
    }
}

ad_proc -private ::news::install::after_instantiate {
    -package_id
    -node_id
} {
    Setup RSS feed per package instance

    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-01-20

    @param package_id

    @return

    @error
} {
    set subscr_id [rss_support::add_subscription \
                       -summary_context_id $package_id \
                       -impl_name "news" \
                       -owner "news" \
                       -lastbuild ""]

}

ad_proc -private news::install::after_upgrade {
    -from_version_name
    -to_version_name
} {
    Upgrade procedures
} {
    apm_upgrade_logic \
	-from_version_name $from_version_name \
	-to_version_name $to_version_name \
	-spec {
	    5.1.0d1 5.1.0b1 {
                news::install::register_rss
                news::install::register_notifications
	    }
	    5.2.0d3 5.2.0d4 {

            }
	    5.2.0d4 5.2.0d5 {

       		# Create the impl and aliases for a news item
	        set impl_id [::news::install::create_news_item_impl]

    		# Create the notification type for a news item
                set type_id [::news::install::create_news_item_type $impl_id]

                # Enable the delivery intervals and delivery methods for a news item
                ::news::install::enable_intervals_and_methods $type_id
	    }
	}
}

ad_proc -private news::install::before_uninstantiate {
    -package_id
} {
    Delete RSS feed per package instance
    Delete News items per package instance

    @author Stan Kaufman (skaufman@epimetrics.com)
    @creation-date 2005-08-03

    @param package_id

    @return

    @error
} {
    news_items_delete [db_list dead_news {}]
    rss_support::del_subscription -summary_context_id $package_id -owner news -impl_name news
}

ad_proc -private ::news::install::create_news_item_impl {

} {
    Register the service contract implementation and return the impl_id
    @return impl_id of the created implementation
} {
    return [acs_sc::impl::new_from_spec -spec {
        name news_item_notif_type
        contract_name NotificationType
        owner news
        aliases {
            GetURL news_notification_get_url
            ProcessReply news_notification_process_reply
        }
    }]
}

ad_proc -private ::news::install::create_news_item_type {
    impl_id
} {
    Create the notification type for one news item
    @return the type_id of the created type
} {
    return [notification::type::new \
                -sc_impl_id $impl_id \
                -short_name one_news_item_notif \
                -pretty_name "One News Item" \
                -description "Notification of a new news item"]
}

ad_proc -private ::news::install::enable_intervals_and_methods {type_id} {
    Enable the intervals and delivery methods of a specific type
} {
    # Enable the various intervals and delivery method
    notification::type::interval_enable \
	-type_id $type_id \
	-interval_id [notification::interval::get_id_from_name -name instant]

    notification::type::interval_enable \
	-type_id $type_id \
	-interval_id [notification::interval::get_id_from_name -name hourly]

    notification::type::interval_enable \
	-type_id $type_id \
	-interval_id [notification::interval::get_id_from_name -name daily]

    # Enable the delivery methods
    notification::type::delivery_method_enable \
	-type_id $type_id \
	-delivery_method_id [notification::delivery::get_id -short_name email]
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
