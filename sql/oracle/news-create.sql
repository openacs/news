-- /packages/news/sql/news-create.sql
--
-- @author stefan@arsdigita.com
-- @created 2000-12-13
-- @cvs-id $Id$


-- *** PERMISSION MODEL ***
--
begin
    -- the read privilege is by default granted to 'the_public'
    -- the site-wide administrator has to change this in /permissions/ 
    -- if he wants to restrict an instance to a specific party

    -- the news_admin has all privileges: read, create, delete, approve
    -- news_admin is a child of 'admin'.
    -- 'admin' is therefore the top-administrator, news_admin is the news administrator
    -- in the context of an instance

    acs_privilege.create_privilege('news_read');
    acs_privilege.create_privilege('news_create');
    acs_privilege.create_privilege('news_delete');

    -- bind privileges to global names  
    acs_privilege.add_child('read','news_read');
    acs_privilege.add_child('create','news_create');
    acs_privilege.add_child('delete','news_delete');

    -- add this to the news_admin privilege
    acs_privilege.create_privilege('news_admin', 'News Administrator');
    -- news administrator binds to global 'admin', plus inherits news_* permissions
    acs_privilege.add_child('admin','news_admin');      
    acs_privilege.add_child('news_admin','news_read');
    acs_privilege.add_child('news_admin','news_create');
    acs_privilege.add_child('news_admin','news_delete');
end;
/
show errors

-- assign permission to defined contexts within ACS by default
--
declare
    default_context acs_objects.object_id%TYPE;
    registered_users acs_objects.object_id%TYPE;
    the_public acs_objects.object_id%TYPE;
begin
    default_context  := acs.magic_object_id('default_context');
    registered_users := acs.magic_object_id('registered_users');
    the_public       := acs.magic_object_id('the_public');
    

    -- give the public permission to read by default
    acs_permission.grant_permission (
        object_id  => default_context,
        grantee_id => the_public,
        privilege  => 'news_read'
    );

    -- give registered users permission to upload items by default
    -- However, they must await approval by users with news_admin privilege
       acs_permission.grant_permission (
         object_id  => default_context,
         grantee_id => registered_users,
         privilege  => 'news_create'
       );

end;
/
show errors



-- *** DATAMODEL ***
-- we use the content repository (see http://cvs.arsdigita.com/acs/packages/acs-content-repository) plus this
create table cr_news (
    news_id                     integer
                                constraint cr_news_id_fk 
                                references cr_revisions
                                constraint cr_news_pk 
                                primary key,
    -- include package_id to provide support for multiple instances
    package_id                  integer
                                constraint cr_news_package_id_nn not null,          lead                        varchar(1000),
    -- regarding news item
    -- *** support for dates when items are displayed or archived ***
    -- unarchived news items have archive_date null
    archive_date                date,
    -- support for approval
    approval_user               integer
                                constraint cr_news_approval_user_fk
                                references users,
    approval_date               date,
    approval_ip                 varchar2(50)
);


-- index to avoid lock situation through parent table
create  index cr_news_appuser_id_fk on cr_news(approval_user);


-- *** NEWS item defitition *** ---
begin
content_type.create_type (
    content_type  => 'news',
    pretty_name   => 'News Item',
    pretty_plural => 'News Items',
    table_name    => 'cr_news',
    id_column     => 'news_id',
    name_method   => 'news.name'
);
end;
/

declare
    attr_id acs_attributes.attribute_id%TYPE;
begin
-- create attributes for widget generation

-- website archive date of news release
attr_id := content_type.create_attribute (
    content_type   => 'news',
    attribute_name => 'archive_date',
    datatype       => 'timestamp',
    pretty_name    => 'Archive Date',
    pretty_plural  => 'Archive Dates',
    column_spec    => 'date'
);
-- authorized user for approval
attr_id := content_type.create_attribute (
    content_type   => 'news',
    attribute_name => 'approval_user',
    datatype       => 'integer',
    pretty_name    => 'Approval User',
    pretty_plural  => 'Approval Users',
    column_spec    => 'integer'
);
-- approval date
attr_id := content_type.create_attribute (
    content_type   => 'news',
    attribute_name => 'approval_date',
    datatype       => 'timestamp',
    pretty_name    => 'Approval Date',
    pretty_plural  => 'Approval Dates',
    default_value  => sysdate,
    column_spec    => 'date'
);
-- approval IP address
attr_id := content_type.create_attribute (
    content_type   => 'news',
    attribute_name => 'approval_ip',
    datatype       => 'text',
    pretty_name    => 'Approval IP',
    pretty_plural  => 'Approval IPs',
    column_spec    => 'varchar2(50)'
);
-- lead
attr_id := content_type.create_attribute (
    content_type   => 'news',
    attribute_name => 'lead',
    datatype       => 'text',
    pretty_name    => 'Lead',
    pretty_plural  => 'Leads',
    column_spec    => 'varchar(1000)'
);

end;
/
show errors



-- *** CREATE THE NEWS FOLDER as our CONTAINER ***

-- create 1 news folder; different instances are filtered by package_id
declare
    v_folder_id cr_folders.folder_id%TYPE;
begin
    v_folder_id := content_folder.new(
        name        => 'news',
        label       => 'news',
        description => 'News Item Root Folder, all news items go in here'
    );
-- associate content types with news folder
    content_folder.register_content_type (
        folder_id        => v_folder_id,
        content_type     => 'news',
        include_subtypes => 't'
    );
    content_folder.register_content_type (
        folder_id        => v_folder_id,
        content_type     => 'content_revision',
        include_subtypes => 't'
    );
end;
/
show errors


@@ news-package-create.sql
@@ news-views-create.sql
