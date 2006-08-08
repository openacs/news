------------------------------------------------------------------------------
-- Add a Lead or abstract chunk to news.
-- @author Tom Ayles (tom@beatniq.net)
-- @creation-date 2004-01-08
-- @cvs-id $Id$
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- This first section alters the data model so that a news item can have a
-- lead. The lead is a short text description of the article that is used on
-- the front page of the package.
------------------------------------------------------------------------------

ALTER TABLE cr_news ADD COLUMN lead varchar(4000);

SELECT content_type__create_attribute (
        'news',         -- content type
        'lead',         -- attr name
        'text',         -- datatype
        'Lead',         -- pretty name
        'Leads',        -- pretty plural
        null,           -- sort order
        null,           -- default value
        'varchar(1000)' -- column spec
);

-- Beware the number of parameters in this definition
-- means that a default build of PGSQL 7.2  can't use it.



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
    p_lead          alias for $17; -- default ''f''

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
	p_package_id,         -- context_id
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


create function news__revision_new (integer,timestamptz,text,varchar,text,
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


-- replace views. vaguely back-compatible, as all previous queries should still
-- work (all we've done is add the publish_lead column)
DROP VIEW news_items_approved;
CREATE VIEW news_items_approved
AS
select
    ci.item_id as item_id,
    cn.package_id, 
    cr.title as publish_title,
    cn.lead as publish_lead,
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

DROP VIEW news_items_live_or_submitted;
CREATE VIEW news_items_live_or_submitted
AS 
select
    ci.item_id as item_id,
    cn.news_id,
    cn.package_id,
    cr.publish_date,
    cn.archive_date,
    cr.title as publish_title,
    cn.lead as publish_lead,
    cr.content as publish_body,
    (case when cr.mime_type = 'text/html' then 't' else 'f' end) as html_p,
    ao.creation_user,
    ps.first_names || ' ' || ps.last_name as item_creator,
    ao.creation_date::date as creation_date,
    ci.live_revision,
    news__status(cr.publish_date, cn.archive_date) as status
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

DROP VIEW news_items_unapproved;
CREATE VIEW news_items_unapproved
AS 
select      
    ci.item_id as item_id,
    cr.title as publish_title,
    cn.lead as publish_lead,
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

DROP VIEW news_item_revisions;
CREATE VIEW news_item_revisions
AS 
select
    cr.item_id as item_id,
    cr.revision_id,
    ci.live_revision,
    cr.title as publish_title,
    cn.lead as publish_lead,
    cr.content as publish_body,
    cr.publish_date,
    cn.archive_date,
    cr.description as log_entry,
    (case when cr.mime_type = 'text/html' then 't' else 'f' end) as html_p,
    cr.mime_type as mime_type,
    cn.package_id,
    ao.creation_date::date as creation_date,
    news__status(cr.publish_date, cn.archive_date) as status,
    case when exists (select 1 
                      from cr_revisions cr2
                      where cr2.revision_id = cn.news_id
                        and cr2.publish_date is null
                      ) then 1 else 0 end 
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

DROP VIEW news_item_full_active;
CREATE VIEW news_item_full_active
AS 
select
    ci.item_id as item_id,
    cn.package_id as package_id,
    revision_id,        
    cr.title as publish_title,
    cn.lead as publish_lead,
    cr.content as publish_body,
    (case when cr.mime_type = 'text/html' then 't' else 'f' end) as html_p,
    cr.publish_date,
    cn.archive_date,
    news__status(cr.publish_date, cn.archive_date) as status,
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
