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
create function inline_0 ()
returns integer as '
declare
    default_context  acs_objects.object_id%TYPE;
    registered_users acs_objects.object_id%TYPE;
    the_public       acs_objects.object_id%TYPE;
begin
    default_context  := acs__magic_object_id(''default_context'');
    registered_users := acs__magic_object_id(''registered_users'');
    the_public       := acs__magic_object_id(''the_public'');
    

    -- give the public permission to read by default
    PERFORM acs_permission__grant_permission (
        default_context, -- object_id
        the_public,      -- grantee_id
        ''news_read''    -- privilege
    );

    -- give registered users permission to upload items by default
    -- However, they must await approval by users with news_admin privilege
    PERFORM acs_permission__grant_permission (
         default_context,  -- object_id
         registered_users, -- grantee_id
         ''news_create''   -- privilege
       );

    return 0;
end;
' language 'plpgsql';

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
create function inline_0 ()
returns integer as '
declare
    v_folder_id cr_folders.folder_id%TYPE;
begin
    v_folder_id := content_folder__new(
        ''news'', -- name
        ''news'', -- label
        ''News Item Root Folder, all news items go in here'', -- description
	null      -- parent_id
    );
-- associate content types with news folder
    PERFORM content_folder__register_content_type (
        v_folder_id, -- folder_id
        ''news'',    -- content_type
        ''t''        -- include_subtypes
    );
    PERFORM content_folder__register_content_type (
        v_folder_id,          -- folder_id
        ''content_revision'', -- content_type
        ''t''                 -- include_subtypes
    );

    return 0;
end;
' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


-- *** PACKAGE NEWS, plsql to create content_item ***
create function news__new (integer,varchar,timestamptz,text,varchar,varchar,
       varchar,integer,timestamptz,integer,timestamptz,varchar,varchar,
       varchar,integer,boolean)
returns integer as '
declare
    p_item_id       alias for $1;  -- default null
    --
    p_locale        alias for $2;  -- default null,
    --
    p_publish_date  alias for $3;  -- default null
    p_text          alias for $4;  -- default null
    p_nls_language  alias for $5;  -- default null
    p_title         alias for $6;  -- default null
    p_mime_type     alias for $7;  -- default ''text/plain''
    --
    p_package_id    alias for $8;  -- default null,     
    p_archive_date  alias for $9;  -- default null
    p_approval_user alias for $10; -- default null
    p_approval_date alias for $11; -- default null
    p_approval_ip   alias for $12; -- default null,     
    --
    p_relation_tag  alias for $13; -- default null
    --
    -- REMOVED: p_item_subtype  alias for $14; -- default ''content_revision''
    -- REMOVED: p_content_type  alias for $15; -- default ''news''
    -- REMOVED: p_creation_date alias for $16; -- default current_timestamp
    p_creation_ip   alias for $14; -- default null
    p_creation_user alias for $15; -- default null
    --
    p_is_live_p     alias for $16; -- default ''f''

    v_news_id       integer;
    v_item_id       integer;
    v_id            integer;
    v_revision_id   integer;
    v_parent_id     integer;
    v_name          varchar;
    v_log_string    varchar;
begin
    select content_item__get_id(''news'',null,''f'') 
    into   v_parent_id 
    from   dual;    
    --
    -- this will be used for 2xClick protection
    if p_item_id is null then
        select acs_object_id_seq.nextval 
        into   v_id 
        from   dual;
    else 
        v_id := p_item_id;
    end if; 
    --
    select ''news'' || to_char(current_timestamp,''YYYYMMDD'') || v_id 
    into   v_name 
    from   dual;    
    -- 
    v_log_string := ''initial submission''; 
    -- 
    v_item_id := content_item__new(
        v_name,               -- name
        v_parent_id,          -- parent_id
        v_id,                 -- item_id
        p_locale,             -- locale
        current_timestamp,    -- creation_date
        p_creation_user,      -- creation_user
	null,                 -- context_id
        p_creation_ip,        -- creation_ip
        ''content_item'',     -- item_subtype
        ''news'',             -- content_type
	null,                 -- title
	null,                 -- description
        p_mime_type,          -- mime_type
        p_nls_language,       -- nls_language
	null,                 -- data
	''text''	      -- storage_type
        -- relation tag is not used by any callers or any
        -- implementations of content_item__new
    );
    v_revision_id := content_revision__new(
        p_title,           -- title
        v_log_string,      -- description
        p_publish_date,    -- publish_date
        p_mime_type,       -- mime_type
        p_nls_language,    -- nls_language
        p_text,            -- data
        v_item_id,         -- item_id
	null,              -- revision_id
        current_timestamp, -- creation_date
        p_creation_user,   -- creation_user
        p_creation_ip      -- creation_ip
    );
    insert into cr_news 
        (news_id, 
         package_id, 
         archive_date,
         approval_user, 
         approval_date, 
         approval_ip)
    values
        (v_revision_id, 
         p_package_id, 
         p_archive_date,
         p_approval_user, 
         p_approval_date, 
         p_approval_ip);
    -- make this revision live when immediately approved
    if p_is_live_p = ''t'' then
        update 
            cr_items
        set
            live_revision = v_revision_id,
            publish_status = ''ready''
        where 
            item_id = v_item_id;
    end if;
    v_news_id := v_revision_id;
    return v_news_id;
end;
' language 'plpgsql';


-- deletes a news item along with all its revisions and possible attachements
create function news__delete (integer)
returns integer as '
declare
    p_item_id alias for $1;
    v_item_id cr_items.item_id%TYPE;
    v_cm RECORD;
begin
    v_item_id := p_item_id;
    -- dbms_output.put_line(''Deleting associated comments...'');
    -- delete acs_messages, images, comments to news item

    FOR v_cm IN
        select message_id from acs_messages am, acs_objects ao
        where  am.message_id = ao.object_id
        and    ao.context_id = v_item_id
    LOOP
        -- images
        delete from images
            where image_id in (select latest_revision
                               from cr_items 
                               where parent_id = v_cm.message_id);
        PERFORM acs_message__delete(v_cm.message_id);
        delete from general_comments
            where comment_id = v_cm.message_id;
    END LOOP;
    delete from cr_news 
    where news_id in (select revision_id 
                      from   cr_revisions 
                      where  item_id = v_item_id);
    PERFORM content_item__delete(v_item_id);
    return 0;
end;
' language 'plpgsql';


-- (re)-publish a news item out of the archive by nulling the archive_date
-- this only applies to the currently active revision
create function news__make_permanent (integer)
returns integer as '
declare
    p_item_id alias for $1;
begin
    update cr_news
    set    archive_date = null
    where  news_id = content_item__get_live_revision(p_item_id);

    return 0;
end;
' language 'plpgsql';


-- archive a news item
-- this only applies to the currently active revision
create function news__archive (integer,timestamptz)
returns integer as '
declare
    p_item_id alias for $1;
    p_archive_date alias for $2; -- default current_timestamp
begin
    update cr_news  
    set    archive_date = p_archive_date
    where  news_id = content_item__get_live_revision(p_item_id);

    return 0;
end;
' language 'plpgsql';

-- RAL: an overloaded version using current_timestamp for archive_date
create function news__archive (integer)
returns integer as '
declare
    p_item_id alias for $1;
    -- p_archive_date alias for $2; -- default current_timestamp
begin
    return news__archive (p_item_id, current_timestamp);
end;
' language 'plpgsql';


-- approve/unapprove a specific revision
-- approving a revision makes it also the active revision
create function news__set_approve(integer,varchar,timestamptz,
       timestamptz,integer,timestamptz,varchar,boolean)
returns integer as '
declare
    p_revision_id     alias for $1;
    p_approve_p       alias for $2; -- default ''t''
    p_publish_date    alias for $3; -- default null
    p_archive_date    alias for $4; -- default null
    p_approval_user   alias for $5; -- default null
    p_approval_date   alias for $6; -- default current_timestamp
    p_approval_ip     alias for $7; -- default null
    p_live_revision_p alias for $8; -- default ''t''
    v_item_id         cr_items.item_id%TYPE;
begin
    select item_id into v_item_id
    from   cr_revisions 
    where  revision_id = p_revision_id;
    -- unapprove an revision (does not mean to knock out active revision)
    if p_approve_p = ''f'' then
        update  cr_news 
        set     approval_date = null,
                approval_user = null,
                approval_ip   = null,
                archive_date  = null
        where   news_id = p_revision_id;
        --
        update  cr_revisions
        set     publish_date = null
        where   revision_id  = p_revision_id;
    else
    -- approve a revision
        update  cr_revisions
        set     publish_date  = p_publish_date
        where   revision_id   = p_revision_id;
        --  
        update  cr_news 
        set archive_date  = p_archive_date,
            approval_date = p_approval_date,
            approval_user = p_approval_user,
            approval_ip   = p_approval_ip
        where news_id     = p_revision_id;
        -- 
        -- cannot use content_item.set_live_revision because it sets publish_date to sysdate
        if p_live_revision_p = ''t'' then
            update  cr_items
            set     live_revision = p_revision_id,
                    publish_status = ''ready''
            where   item_id = v_item_id;
        end if;
        --
    end if;

    return 0;
end;
' language 'plpgsql';


-- the status function returns information on the puplish or archive status
-- it does not make any checks on the order of publish_date and archive_date
create function news__status (integer)
returns varchar as '
declare
    p_news_id alias for $1;
    v_archive_date timestamptz;
    v_publish_date timestamptz;
begin
    -- populate variables
    select archive_date into v_archive_date 
    from   cr_news 
    where  news_id = p_news_id;
    --
    select publish_date into v_publish_date
    from   cr_revisions
    where  revision_id = p_news_id;
    
    -- if publish_date is not null the item is approved, otherwise it is not
    if v_publish_date is not null then
        if v_publish_date > current_timestamp  then
            -- to be published (2 cases)
            -- archive date could be null if it has not been decided when to archive
	    -- RAL: the nasty ''extract'' code below was the only way I could figure
	    -- to get the same result as Oracle (eg, 2.4 days)
            if v_archive_date is null then 
                return ''going live in ''
                || text(round(extract(days from (v_publish_date - current_timestamp))
		+ extract(hours from (v_publish_date - current_timestamp))/24,1))
		|| '' days'';
            else 
                return ''going live in ''
                || text(round(extract(days from (v_publish_date - current_timestamp))
		+ extract(hours from (v_publish_date - current_timestamp))/24,1))
		|| '' days'' || '', archived in ''
                || text(round(extract(days from (v_archive_date - current_timestamp))
		+ extract(hours from (v_archive_date - current_timestamp))/24,1))
                || '' days'';
            end if;  
        else
            -- already released or even archived (3 cases)
            if v_archive_date is null then
                 return ''published, not scheduled for archive'';
            else
                if v_archive_date - current_timestamp > 0 then
                     return ''published, archived in ''
		     || text(round(extract(days from (v_archive_date - current_timestamp))
		     + extract(hours from (v_archive_date - current_timestamp))/24,1))
		     || '' days'';
                else 
                    return ''archived'';
                end if;
             end if;
        end if;     
    else 
        return ''unapproved'';
    end if;
end;
' language 'plpgsql';


create function news__name (integer)
returns varchar as '
declare
    p_news_id alias for $1;
    v_news_title cr_revisions.title%TYPE;
begin
    select title 
    into v_news_title
    from cr_revisions
    where revision_id = p_news_id;

    return v_news_title;
end;
' language 'plpgsql';


-- 
-- API for Revision management
-- 
create function news__revision_new (integer,timestamptz,text,varchar,text,
       varchar,integer,timestamptz,integer,timestamptz,varchar,timestamptz,varchar,
       integer,boolean)
returns integer as '
declare
    p_item_id                alias for $1;
    --
    p_publish_date           alias for $2;  -- default null
    p_text                   alias for $3;  -- default null
    p_title                  alias for $4;
    --
    -- here goes the revision log
    p_description            alias for $5;
    --
    p_mime_type              alias for $6;  -- default ''text/plain''
    p_package_id             alias for $7;  -- default null
    p_archive_date           alias for $8;  -- default null
    p_approval_user          alias for $9;  -- default null
    p_approval_date          alias for $10; -- default null
    p_approval_ip            alias for $11; -- default null
    --
    p_creation_date          alias for $12; -- default current_timestamp
    p_creation_ip            alias for $13; -- default null
    p_creation_user          alias for $14; -- default null
    --
    p_make_active_revision_p alias for $15; -- default ''f''

    v_revision_id    integer;
begin
    -- create revision
    v_revision_id := content_revision__new(
        p_title,         -- title
        p_description,   -- description
        p_publish_date,  -- publish_date
        p_mime_type,     -- mime_type
        null,            -- nls_language
        p_text,          -- text
        p_item_id,       -- item_id
        null,            -- revision_id
        p_creation_date, -- creation_date
        p_creation_user, -- creation_user
        p_creation_ip    -- creation_ip
    );
    -- create new news entry with new revision
    insert into cr_news
        (news_id, 
         package_id,
         archive_date, 
         approval_user, 
         approval_date, 
         approval_ip)
    values
        (v_revision_id, 
         p_package_id,
         p_archive_date, 
         p_approval_user, 
         p_approval_date,
         p_approval_ip);
    -- make active revision if indicated
    if p_make_active_revision_p = ''t'' then
        PERFORM news__revision_set_active(v_revision_id);
    end if;
    return v_revision_id;
end;
' language 'plpgsql';


create function news__revision_set_active (integer)
returns integer as '
declare
    p_revision_id alias for $1;
    v_news_item_p boolean;
    -- could be used to check if really a ''news'' item
begin
    update
        cr_items
    set
        live_revision = p_revision_id,
        publish_status = ''ready''
    where
        item_id = (select
                       item_id
                   from
                       cr_revisions
                   where
                       revision_id = p_revision_id);

    return 0;
end;
' language 'plpgsql';



-- Incomplete for want of blob_to_string() in postgres 16 july 2000

create function news__clone (integer, integer)
returns integer as '
declare
 p_new_package_id   alias for $1;   --default null,
 p_old_package_id   alias for $2;   --default null
 one_news		record;	 
begin
        for one_news in select
                            publish_date,
                            cr.content as text,
                            cr.nls_language,
                            cr.title as title,
                            cr.mime_type,
                            cn.package_id,
                            archive_date,
                            approval_user,
                            approval_date,
                            approval_ip,
                            ao.creation_date,
                            ao.creation_ip,
                            ao.creation_user
                        from 
                            cr_items ci, 
                            cr_revisions cr,
                            cr_news cn,
                            acs_objects ao
                        where
                            (ci.item_id = cr.item_id
                            and ci.live_revision = cr.revision_id 
                            and cr.revision_id = cn.news_id 
                            and cr.revision_id = ao.object_id)
                        or (ci.live_revision is null 
                            and ci.item_id = cr.item_id
                            and cr.revision_id = content_item__get_latest_revision(ci.item_id)
                            and cr.revision_id = cn.news_id
                            and cr.revision_id = ao.object_id)

        loop
            perform news__new(
                				one_news.publish_date,
                				one_news.text,
                				one_news.nls_language,
                				one_news.title,
                				one_news.mime_type,
                				new_package_id,
                				one_news.archive_date,
                				one_news.approval_user,
                				one_news.approval_date,
                				one_news.approval_ip,
                				one_news.creation_date,
                				one_news.creation_ip,
                				one_news.creation_user
            );

        end loop;
 return 0;
end;
' language 'plpgsql';





-- currently not used, because we want to audit revisions
create function news__revision_delete (integer)
returns integer as '
declare
    p_revision_id alias for $1;
begin
    -- delete from cr_news table
    delete from cr_news
    where  news_id = p_revision_id;

    -- delete revision
    PERFORM content_revision__delete(
        p_revision_id -- revision_id
    );

    return 0;
end;
' language 'plpgsql';


--
--  views on 'news' application that pick from cr_news, cr_items, cr_revisions
--  Re-arrange 'joins' for performance tuning
--  RAL: Casted all _date columns to ::date for consistency with Oracle views.
-- 

--  Views on multiple items

-- View on all released news items in its active revision
-- RAL: for now, changed:
--     content.blob_to_string(cr.content) as publish_body,
-- to
--     cr.content as publish_body
--
-- RAL: Dropped 'content' column from this view which is redundant and not
-- used anywhere.
--
create view news_items_approved
as
select
    ci.item_id as item_id,
    cn.package_id, 
    cr.title as publish_title,
    cr.content as publish_body,
    (case when cr.mime_type = 'text/html' then 't' else 'f' end) as html_p,
    to_char(cr.publish_date, 'Mon dd, yyyy') as pretty_publish_date,
    cr.publish_date,
    ao.creation_user,
    ps.first_names || ' ' || ps.last_name as item_creator,
    cn.archive_date::date as archive_date    
from 
    cr_items ci, 
    cr_revisions cr,
    cr_news cn,
    acs_objects ao,
    persons ps
where
    ci.item_id = cr.item_id
and ci.live_revision = cr.revision_id
and cr.revision_id = cn.news_id
and cr.revision_id = ao.object_id
and ao.creation_user = ps.person_id;


-- View of all news items in the system 
-- RAL: for now, changed:
-- content.blob_to_string(cr.content) as publish_body,
-- to
-- cr.content as publish_body
--
create view news_items_live_or_submitted
as 
select
    ci.item_id as item_id,
    cn.news_id,
    cn.package_id,
    cr.publish_date,
    cn.archive_date,
    cr.title as publish_title,
    cr.content as publish_body,
    (case when cr.mime_type = 'text/html' then 't' else 'f' end) as html_p,
    ao.creation_user,
    ps.first_names || ' ' || ps.last_name as item_creator,
    ao.creation_date::date as creation_date,
    ci.live_revision,
    news__status(cn.news_id) as status
from 
    cr_items ci, 
    cr_revisions cr,
    cr_news cn,
    acs_objects ao,
    persons ps
where
    (ci.item_id = cr.item_id
    and ci.live_revision = cr.revision_id 
    and cr.revision_id = cn.news_id 
    and cr.revision_id = ao.object_id
    and ao.creation_user = ps.person_id)
or (ci.live_revision is null 
    and ci.item_id = cr.item_id
    and cr.revision_id = content_item__get_latest_revision(ci.item_id)
    and cr.revision_id = cn.news_id
    and cr.revision_id = ao.object_id
    and ao.creation_user = ps.person_id);


-- View of unapproved items 
create view news_items_unapproved
as 
select      
    ci.item_id as item_id,
    cr.title as publish_title,
    cn.package_id as package_id,
    ao.creation_date::date as creation_date,
    ps.first_names || ' ' || ps.last_name as item_creator
from 
    cr_items ci,
    cr_revisions cr,
    cr_news cn,
    acs_objects ao,
    persons ps
where 
    cr.revision_id = ao.object_id
and ao.creation_user = ps.person_id
and cr.revision_id = content_item__get_live_revision(ci.item_id)
and cr.revision_id = cn.news_id
and cr.item_id = ci.item_id
and cr.publish_date is null;


-- One News Item Views
--
-- View of all revisions of a news item
-- RAL: for now, changed:
-- content.blob_to_string(cr.content) as publish_body,
-- to
-- cr.content as publish_body
--
create view news_item_revisions
as 
select
    cr.item_id as item_id,
    cr.revision_id,
    ci.live_revision,
    cr.title as publish_title,
    cr.content as publish_body,
    cr.publish_date,
    cn.archive_date,
    cr.description as log_entry,
    (case when cr.mime_type = 'text/html' then 't' else 'f' end) as html_p,
    cr.mime_type as mime_type,
    cn.package_id,
    ao.creation_date::date as creation_date,
    news__status(news_id) as status,
    case when exists (select 1 from cr_news where news_id = revision_id 
         and news__status(news_id) = 'unapproved') then 1 else 0 end 
         as
         approval_needed_p,
    ps.first_names || ' ' || ps.last_name as item_creator,
    ao.creation_user,
    ao.creation_ip,
    ci.name as item_name
from
    cr_revisions cr,
    cr_news cn,
    cr_items ci,
    acs_objects ao,
    persons ps
where 
    cr.revision_id = ao.object_id
and cr.revision_id = cn.news_id
and ci.item_id = cr.item_id
and ao.creation_user = ps.person_id;


-- View of a submitted news item or active revision in unapproved state
create view news_item_unapproved
as 
select
    cr.revision_id,
    ci.name as item_name,
    ps.first_names || ' ' || ps.last_name as item_creator,
    ao.creation_ip as item_creation_ip,
    ao.creation_date::date as creation_date
from 
    cr_revisions cr,
    cr_items ci,
    acs_objects ao,
    persons ps    
where 
    ci.item_id = cr.item_id
and cr.revision_id = ao.object_id
and ao.creation_user = ps.person_id;


-- View of a news item as of its active revision
-- RAL: for now, changed:
-- content.blob_to_string(cr.content) as publish_body,
-- to
-- cr.content as publish_body
--
create view news_item_full_active
as 
select
    ci.item_id as item_id,
    cn.package_id as package_id,
    revision_id,        
    title as publish_title,
    cr.content as publish_body,
    (case when cr.mime_type = 'text/html' then 't' else 'f' end) as html_p,
    cr.publish_date,
    cn.archive_date,
    news__status(cr.revision_id) as status,
    ci.name as item_name,
    ps.person_id as creator_id,
    ps.first_names || ' ' || ps.last_name as item_creator
from
    cr_items ci, 
    cr_revisions cr,
    cr_news cn,
    acs_objects ao,
    persons ps
where 
    cr.item_id = ci.item_id
and (cr.revision_id = ci.live_revision
    or (ci.live_revision is null 
    and cr.revision_id = content_item__get_latest_revision(ci.item_id)))
and cr.revision_id = cn.news_id
and ci.item_id = ao.object_id
and ao.creation_user = ps.person_id;


-- plsql to create keywords for news items
-- no additional code necessary for news items right now.

-- plsql for searches: will be covered by site-wide search
-- no additional code necessary for news  items right now.


-- *** Search contract registration ***
--
\i news-sc-create.sql
