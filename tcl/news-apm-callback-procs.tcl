# 

ad_library {
    
    APM callbacks for the news package
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-01-20
    @arch-tag: 0f0b0270-4074-410a-a5f9-386d402adc46
    @cvs-id $Id$
}

namespace eval ::news::install {}

ad_proc -public ::news::install::after_install {
} {
    Setup RSS support service contract
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-01-20
    
    @return 
    
    @error 
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

ad_proc -public ::news::install::after_mount {
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
    rss_gen_report $subscr_id
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
                news::install::after_install
	    }
	}
}
