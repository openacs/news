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





-- added

-- old define_function_args('news__new','item_id;null,locale;null,publish_date;null,text;null,nls_language;null,title;null,mime_type;text/plain,package_id;null,archive_date;null,approval_user;null,approval_date;null,approval_ip;null,relation_tag;null,creation_ip;null,creation_user;null,is_live_p;f,lead;f')
-- new
select define_function_args('news__new','item_id;null,locale;null,publish_date;null,text;null,nls_language;null,title;null,mime_type;text/plain,package_id;null,archive_date;null,approval_user;null,approval_date;null,approval_ip;null,relation_tag;null,creation_ip;null,creation_user;null,is_live_p;f,lead');


--
-- procedure news__new/17
--
CREATE OR REPLACE FUNCTION news__new(
   p_item_id integer,           -- default null
   p_locale varchar,            -- default null,
   p_publish_date timestamptz,  -- default null
   p_text text,                 -- default null
   p_nls_language varchar,      -- default null
   p_title varchar,             -- default null
   p_mime_type varchar,         -- default 'text/plain'
   p_package_id integer,        -- default null,
   p_archive_date timestamptz,  -- default null
   p_approval_user integer,     -- default null
   p_approval_date timestamptz, -- default null
   p_approval_ip varchar,       -- default null,
   p_relation_tag varchar,      -- default null
   p_creation_ip varchar,       -- default null
   p_creation_user integer,     -- default null
   p_is_live_p boolean,         -- default 'f'
   p_lead varchar               -- default 'f'

) RETURNS integer AS $$
DECLARE
    --
    --
    --
    --
    --
    --

    v_news_id       integer;
    v_item_id       integer;
    v_id            integer;
    v_revision_id   integer;
    v_parent_id     integer;
    v_name          varchar;
    v_log_string    varchar;
BEGIN
    select content_item__get_id('news',null,'f') 
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
    select 'news' || to_char(current_timestamp,'YYYYMMDD') || v_id 
    into   v_name 
    from   dual;    
    -- 
    v_log_string := 'initial submission'; 
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
        'content_item',     -- item_subtype
        'news',             -- content_type
	null,                 -- title
	null,                 -- description
        p_mime_type,          -- mime_type
        p_nls_language,       -- nls_language
	null,                 -- data
	'text'	      -- storage_type
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
    if p_is_live_p = 't' then
        update 
            cr_items
        set
            live_revision = v_revision_id,
            publish_status = 'ready'
        where 
            item_id = v_item_id;
    end if;
    v_news_id := v_revision_id;
    return v_news_id;
END;

$$ LANGUAGE plpgsql;




-- added
select define_function_args('news__revision_new','item_id,publish_date;null,text;null,title,description,mime_type;text/plain,package_id;null,archive_date;null,approval_user;null,approval_date;null,approval_ip;null,creation_date;current_timestamp,creation_ip;null,creation_user;null,make_active_revision_p;f,lead');

--
-- procedure news__revision_new/16
--
CREATE OR REPLACE FUNCTION news__revision_new(
   p_item_id integer,
   p_publish_date timestamptz,       -- default null
   p_text text,                      -- default null
   p_title varchar,
   p_description text,
   p_mime_type varchar,              -- default 'text/plain'
   p_package_id integer,             -- default null
   p_archive_date timestamptz,       -- default null
   p_approval_user integer,          -- default null
   p_approval_date timestamptz,      -- default null
   p_approval_ip varchar,            -- default null
   p_creation_date timestamptz,      -- default current_timestamp
   p_creation_ip varchar,            -- default null
   p_creation_user integer,          -- default null
   p_make_active_revision_p boolean, -- default 'f'
   p_lead varchar

) RETURNS integer AS $$
DECLARE
    --
    --
    -- here goes the revision log
    --
    --
    --

    v_revision_id    integer;
BEGIN
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
    if p_make_active_revision_p = 't' then
        PERFORM news__revision_set_active(v_revision_id);
    end if;
    return v_revision_id;
END;

$$ LANGUAGE plpgsql;


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
