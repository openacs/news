-- /packages/news/sql/news-package-create.sql
--
-- @author stefan@arsdigita.com
-- @created 2000-12-13
-- @cvs-id $Id$
--
-- OpenACS Port: Robert Locke (rlocke@infiniteinfo.com)

-- *** PACKAGE NEWS, plsql to create content_item ***
select define_function_args ('news__new','item_id,locale,publish_date,text,nls_language,title,mime_type;text/plain,package_id,archive_date,approval_user,approval_date,approval_ip,relation_tag,creation_ip,creation_user,is_live_p;f,lead');

create or replace function news__new (integer,varchar,timestamptz,text,varchar,varchar,
       varchar,integer,timestamptz,integer,timestamptz,varchar,varchar,
       varchar,integer,boolean, varchar)
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
    p_lead          alias for $17;

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
        select nextval(''t_acs_object_id_seq'')
        into   v_id
        from   dual;
    else
        v_id := p_item_id;
    end if;
    --
    v_name := ''news-'' || to_char(current_timestamp,''YYYYMMDD'') || ''-'' || v_id;
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
	p_package_id,         -- context_id
        p_creation_ip,        -- creation_ip
        ''content_item'',     -- item_subtype
        ''news'',             -- content_type
        p_title,              -- title
	null,                 -- description
        p_mime_type,          -- mime_type
        p_nls_language,       -- nls_language
        null,                 -- text
	null,                 -- data
        null,                 -- relation_tag
        p_is_live_p,          -- live_p
	''text'',	      -- storage_type
        p_package_id          -- package_id
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
         lead,
         package_id,
         archive_date,
         approval_user,
         approval_date,
         approval_ip)
    values
        (v_revision_id,
         p_lead,
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
create or replace function news__delete (integer)
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
create or replace function news__make_permanent (integer)
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
create or replace function news__archive (integer,timestamptz)
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
create or replace function news__archive (integer)
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
create or replace function news__set_approve(integer,varchar,timestamptz,
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
create or replace function news__status (timestamptz, timestamptz)
returns varchar as '
declare
    p_publish_date alias for $1;
    p_archive_date alias for $2;
begin
    if p_publish_date is not null then
        if p_publish_date > current_timestamp then
            -- Publishing in the future
            if p_archive_date is null then 
                return ''going_live_no_archive'';
            else 
                return ''going_live_with_archive'';
            end if;  
        else
            -- Published in the past
            if p_archive_date is null then
                 return ''published_no_archive'';
            else
                if p_archive_date > current_timestamp then
                     return ''published_with_archive'';
                else 
                    return ''archived'';
                end if;
            end if;
        end if;
    else
        -- publish_date null
        return ''unapproved'';
    end if;
end;
' language 'plpgsql';

create or replace function news__name (integer)
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
create or replace function news__revision_new (integer,timestamptz,text,varchar,text,
       varchar,integer,timestamptz,integer,timestamptz,varchar,timestamptz,varchar,
       integer,boolean, varchar)
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
    p_lead                   alias for $16;

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
         lead,
         package_id,
         archive_date, 
         approval_user, 
         approval_date, 
         approval_ip)
    values
        (v_revision_id, 
         p_lead,
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


create or replace function news__revision_set_active (integer)
returns integer as '
declare
    p_revision_id alias for $1;
    v_news_item_p boolean;
    v_item_id cr_items.item_id%TYPE;
    v_title acs_objects.title%TYPE;
    -- could be used to check if really a ''news'' item
begin

    select item_id, title into v_item_id, v_title
    from cr_revisions
    where revision_id = p_revision_id;

    update cr_items
    set live_revision = p_revision_id,
        publish_status = ''ready''
    where item_id = v_item_id;

    -- We update the acs_objects title as well.

    update acs_objects set title = v_title
    where object_id = v_item_id and (title != v_title or title is null);

    return 0;
end;
' language 'plpgsql';



-- Incomplete for want of blob_to_string() in postgres 16 july 2000

create or replace function news__clone (integer, integer)
returns integer as '
declare
 p_old_package_id   alias for $1;   --default null,
 p_new_package_id   alias for $2;   --default null
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
                            ao.creation_user,
			    ci.locale,
			    ci.live_revision,
			    cr.revision_id,
			    cn.lead
                        from 
                            cr_items ci, 
                            cr_revisions cr,
                            cr_news cn,
                            acs_objects ao
                        where
			    cn.package_id = p_old_package_id
                        and ((ci.item_id = cr.item_id
                            and ci.live_revision = cr.revision_id 
                            and cr.revision_id = cn.news_id 
                            and cr.revision_id = ao.object_id)
                        or (ci.live_revision is null 
                            and ci.item_id = cr.item_id
                            and cr.revision_id = content_item__get_latest_revision(ci.item_id)
                            and cr.revision_id = cn.news_id
                            and cr.revision_id = ao.object_id))

        loop
            perform news__new(
						null,
						one_news.locale,
                				one_news.publish_date,
                				one_news.text,
                				one_news.nls_language,
                				one_news.title,
                				one_news.mime_type,
                				p_new_package_id,
                				one_news.archive_date,
                				one_news.approval_user,
                				one_news.approval_date,
                				one_news.approval_ip,
						null,
                				one_news.creation_ip,
                				one_news.creation_user,
						one_news.live_revision = one_news.revision_id,
						one_news.lead
            );

        end loop;
 return 0;
end;
' language 'plpgsql';


-- currently not used, because we want to audit revisions
create or replace function news__revision_delete (integer)
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



