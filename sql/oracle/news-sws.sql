-- 
-- packages/acs-interfaces/sql/news-sws.sql
--
-- @author khy@arsdigita.com
-- @creation-date 2001-01-17
-- @cvs-id $Id$
--

create or replace package news__sws
is
    function sws_title (
	object_id		in acs_objects.object_id%type
    ) return varchar2;

    function sws_url (
	object_id           	in acs_objects.object_id%type
    ) return varchar2;

    function sws_summary (
	object_id		in acs_objects.object_id%type
    ) return varchar2;    

    function sws_req_permission (
	object_id		in acs_objects.object_id%type
    ) return varchar2;

    function sws_site_node_id (
	object_id           in acs_objects.object_id%type
    ) return site_nodes.node_id%TYPE;

    function sws_application_id (
	object_id	    in acs_objects.object_id%type
    ) return apm_packages.package_id%TYPE;

    procedure sws_index_proc (
	object_id	    in acs_objects.object_id%type,
	bdata		in out nocopy BLOB
    );
end news__sws;
/


create or replace package body news__sws 
is
    function sws_title (
	object_id		in acs_objects.object_id%type
    ) return varchar2
    is
	news_title		varchar2(1000);
    begin
	news_title := news.name(object_id);	
        return news_title;
    end;


    function sws_url (
	object_id           in acs_objects.object_id%type
    ) return varchar2
    is 
        url                     varchar2(3000);     
	v_item_id			number;
	v_node_id                       number;
    begin 
	v_node_id := news__sws.sws_site_node_id(object_id);
	url := site_node.url(v_node_id);

        url := url || pot_service.get_obj_type_attr_value (
	       package_key 	    => 'news',
               object_type          => 'news',
               attribute            => 'display_page'
        );

	select item_id into v_item_id
	from cr_revisions
	where revision_id = object_id;
	
        return url||to_char(v_item_id);
    end sws_url;


    function sws_summary (
	object_id		in acs_objects.object_id%type
    ) return varchar2
    is
	v_summary	    varchar2(4000);
    begin
	select description into v_summary
	from cr_revisions
	where revision_id = object_id;

	return v_summary;
    end sws_summary;
    


    -- normal user,i.e. non news_admin can only see live revision 
    function sws_req_permission (
	object_id		in acs_objects.object_id%type
    ) return varchar2
    is
	v_item_id 	integer;
    begin
	select item_id into v_item_id 
	from cr_revisions 
	where revision_id = object_id; 
	if NVL(content_item.get_live_revision(v_item_id),0) = object_id
	then 	
	  return null;
	else 
	  return 'news_admin';
	end if;	
    end;

    function sws_site_node_id (
	object_id           in acs_objects.object_id%type
    ) return site_nodes.node_id%TYPE
    is
        v_node_id             site_nodes.node_id%type;
    begin
	select  node_id 
	into 	v_node_id
	from 	site_nodes
	where   object_id = news__sws.sws_application_id(news__sws.sws_site_node_id.object_id);

        return v_node_id;         
    end;



    function sws_application_id (
	object_id	    in acs_objects.object_id%TYPE
    ) return apm_packages.package_id%TYPE
    is
        v_application_id        apm_packages.package_id%type;
    begin
	select package_id	
	into v_application_id
	from cr_news 
	where news_id = object_id;

        return v_application_id;
    end;



    procedure sws_index_proc (
	object_id	    in acs_objects.object_id%type,
	bdata		    in out nocopy BLOB
    ) 
    is
	v_bdata		    BLOB;
	v_content_length    number;
    begin
	select	content	    ,
		dbms_lob.getlength(content)
	into	v_bdata,
		v_content_length
	from cr_revisions
	where revision_id = object_id;

	if v_content_length > 0 then
	    dbms_lob.copy  (
		dest_lob    => bdata	,
		src_lob	    => v_bdata	,
		amount	    => v_content_length
	    );
	end if;
    end;
end news__sws;
/
show errors;



begin
  acs_interface.assoc_obj_type_with_interface (
	    interface_name          => 'sws_display' ,
	    programming_language    => 'pl/sql'      ,
	    object_type             => 'news',
	    object_type_imp	    => 'news__sws'  
       );

  acs_interface.assoc_obj_type_with_interface (
	    interface_name          => 'sws_indexing' ,
	    programming_language    => 'pl/sql'      ,
	    object_type             => 'news',
	    object_type_imp	    => 'news__sws' 
       );

  sws_service.update_content_obj_type_info ('news');
  sws_service.rebuild_index;
end;
/
show errors;

begin
    pot_service.register_object_type (
	package_key                  => 'news',
	object_type                  => 'news'
    );

    pot_service.set_obj_type_attr_value (
	package_key                  => 'news',
	object_type                  => 'news',
	attribute		     => 'display_page',
        attribute_value              => 'item?item_id='
    );
end;
/
show errors;







