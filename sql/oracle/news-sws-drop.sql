begin

    acs_interface.remove_obj_type_impl (
	    interface_name          => 'sws_display' ,
	    programming_language    => 'pl/sql'      ,
	    object_type             => 'news'
    );

    acs_interface.remove_obj_type_impl (
	    interface_name          => 'sws_indexing' ,
	    programming_language    => 'pl/sql'      ,
	    object_type             => 'news'
    );	

    pot_service.delete_obj_type_attr_value (
	    package_key		    => 'news'	,
	    object_type		    => 'news'	,
	    attribute		    => 'display_page'
    );

    pot_service.unregister_object_type (
	    package_key		    => 'news'	,
	    object_type		    => 'news'
    );
end;
/

drop package news__sws;

