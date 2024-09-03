-- /packages/news/sql/news-create.sql
--
-- @author stefan@arsdigita.com
-- @created 2000-12-13
-- @cvs-id $Id$
--
-- OpenACS Port: Robert Locke (rlocke@infiniteinfo.com)
--

-- *** PERMISSION MODEL ***
--

begin;
    -- the read privilege is by default granted to 'the_public'
    -- the site-wide administrator has to change this in /permissions/ 
    -- if he wants to restrict an instance to a specific party

    -- the news_admin has all privileges: read, create, delete, approve
    -- news_admin is a child of 'admin'.
    -- 'admin' is therefore the top-administrator, news_admin is the news administrator
    -- in the context of an instance

    select acs_privilege__create_privilege('news_read', null, null);
    select acs_privilege__create_privilege('news_create', null, null);
    select acs_privilege__create_privilege('news_delete', null, null);
    select acs_privilege__create_privilege('news_admin', 'News Administrator', null);

    -- bind privileges to global names  
    select acs_privilege__add_child('read', 'news_read');
    select acs_privilege__add_child('create', 'news_create');
    select acs_privilege__add_child('delete', 'news_delete');

    -- add this to the news_admin privilege
    -- news administrator binds to global 'admin', plus inherits news_* permissions
    select acs_privilege__add_child('admin', 'news_admin');
    select acs_privilege__add_child('news_admin', 'news_read');
    select acs_privilege__add_child('news_admin', 'news_create');

    select acs_privilege__add_child('news_admin', 'news_delete');

end;


-- assign permission to defined contexts within ACS by default
--


--
-- procedure inline_0/0
--
CREATE OR REPLACE FUNCTION inline_0(

) RETURNS integer AS $$
DECLARE
    default_context  acs_objects.object_id%TYPE;
    registered_users acs_objects.object_id%TYPE;
    the_public       acs_objects.object_id%TYPE;
BEGIN
    default_context  := acs__magic_object_id('default_context');
    registered_users := acs__magic_object_id('registered_users');
    the_public       := acs__magic_object_id('the_public');
    

    -- give the public permission to read by default
    PERFORM acs_permission.grant_permission (
        default_context, -- object_id
        the_public,      -- grantee_id
        'news_read'    -- privilege
    );

    -- give registered users permission to upload items by default
    -- However, they must await approval by users with news_admin privilege
    PERFORM acs_permission.grant_permission (
         default_context,  -- object_id
         registered_users, -- grantee_id
         'news_create'   -- privilege
       );

    return 0;
END;

$$ LANGUAGE plpgsql;

select inline_0 ();
drop function inline_0 ();


-- *** DATAMODEL ***
-- we use the content repository (see http://cvs.arsdigita.com/acs/packages/acs-content-repository) plus this
create table cr_news (
    news_id                     integer
                                constraint cr_news_id_fk 
                                references cr_revisions
                                constraint cr_news_pk 
                                primary key,
    -- article abstract 
    lead                        varchar(4000),
    -- include package_id to provide support for multiple instances
    package_id                  integer
                                constraint cr_news_package_id_nn not null,      
    -- regarding news item
    -- *** support for dates when items are displayed or archived ***
    -- unarchived news items have archive_date null
    archive_date                timestamptz,
    -- support for approval
    approval_user               integer
                                constraint cr_news_approval_user_fk
                                references users,
    approval_date               timestamptz,
    approval_ip                 varchar(50)

);


-- index to avoid lock situation through parent table
create  index cr_news_appuser_id_fk on cr_news(approval_user);


-- *** NEWS item defitition *** ---
begin;
    select content_type__create_type (
        'news',             -- content_type
	'content_revision', -- supertype
	'News Article',     -- pretty_name
	'News Articles',    -- pretty_plural
	'cr_news',          -- table_name
	'news_id',          -- id_column
	'news__name'        -- name_method
    );
end;


begin;
-- create attributes for widget generation

-- lead
SELECT content_type__create_attribute (
        'news',         -- content type
        'lead',         -- attr name
        'text',         -- datatype
        'Lead',         -- pretty name
        'Leads',        -- pretty plural
        null,           -- sort order
        null,           -- default value
        'varchar(4000)' -- column spec
);

-- website archive date of news release
    select content_type__create_attribute (
        'news',          -- content_type
	'archive_date',  -- attribute_name
	'timestamp',     -- datatype
	'Archive Date',  -- pretty_name
	'Archive Dates', -- pretty_plural
	null,            -- sort_order
	null,            -- default_value
	'timestamp'      -- column_spec
    );
-- authorized user for approval
    select content_type__create_attribute (
        'news',           -- content_type
        'approval_user',  -- attribute_name
        'integer',        -- datatype
        'Approval User',  -- pretty_name
        'Approval Users', -- pretty_plural
        null,             -- sort_order
        null,             -- default_value
        'integer'         -- column_spec
    );
-- approval date
    select content_type__create_attribute (
        'news',                -- content_type
        'approval_date',       -- attribute_name
        'timestamp',           -- datatype
        'Approval Date',       -- pretty_name
        'Approval Dates',      -- pretty_plural
        null,                  -- sort_order
        current_date::varchar, -- default_value
        'timestamp'            -- column_spec
    );
-- approval IP address
    select content_type__create_attribute (
        'news',         -- content_type
        'approval_ip',  -- attribute_name
        'text',         -- datatype
        'Approval IP',  -- pretty_name
        'Approval IPs', -- pretty_plural
        null,           -- sort_order
        null,           -- default_value
        'varchar(50)'   -- column_spec
    );
end;


-- *** CREATE THE NEWS FOLDER as our CONTAINER ***

-- create 1 news folder; different instances are filtered by package_id


--
-- procedure inline_0/0
--
CREATE OR REPLACE FUNCTION inline_0(

) RETURNS integer AS $$
DECLARE
    v_folder_id cr_folders.folder_id%TYPE;
BEGIN
    v_folder_id := content_folder__new(
        'news', -- name
        'news', -- label
        'News Item Root Folder, all news items go in here', -- description
	null      -- parent_id
    );
-- associate content types with news folder
    PERFORM content_folder__register_content_type (
        v_folder_id, -- folder_id
        'news',    -- content_type
        't'        -- include_subtypes
    );
    PERFORM content_folder__register_content_type (
        v_folder_id,          -- folder_id
        'content_revision', -- content_type
        't'                 -- include_subtypes
    );

    return 0;
END;

$$ LANGUAGE plpgsql;

select inline_0 ();
drop function inline_0 ();

-- Create views after package since they need news__status

\i news-package-create.sql

\i news-views-create.sql
