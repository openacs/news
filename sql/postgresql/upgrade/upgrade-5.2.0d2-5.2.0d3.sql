
-- old define_function_args ('news__new','item_id,locale,publish_date,text,nls_language,title,mime_type;text/plain,package_id,archive_date,approval_user,approval_date,approval_ip,relation_tag,creation_ip,creation_user,is_live_p;f,lead')
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
   p_package_id integer,        -- default null
   p_archive_date timestamptz,  -- default null
   p_approval_user integer,     -- default null
   p_approval_date timestamptz, -- default null
   p_approval_ip varchar,       -- default null
   p_relation_tag varchar,      -- default null
   p_creation_ip varchar,       -- default null
   p_creation_user integer,     -- default null
   p_is_live_p boolean,         -- default 'f'
   p_lead varchar

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
    v_name := 'news-' || to_char(current_timestamp,'YYYYMMDD') || '-' || v_id;
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
        p_title,              -- title
	null,                 -- description
        p_mime_type,          -- mime_type
        p_nls_language,       -- nls_language
        null,                 -- text
	null,                 -- data
        null,                 -- relation_tag
        p_is_live_p,           -- live_p
	'text',	      -- storage_type
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
select define_function_args('news__revision_set_active','revision_id');

--
-- procedure news__revision_set_active/1
--
CREATE OR REPLACE FUNCTION news__revision_set_active(
   p_revision_id integer
) RETURNS integer AS $$
DECLARE
    v_news_item_p boolean;
    v_item_id cr_items.item_id%TYPE;
    v_title acs_objects.title%TYPE;
    -- could be used to check if really a 'news' item
BEGIN

    select item_id, title into v_item_id, v_title
    from cr_revisions
    where revision_id = p_revision_id;

    update cr_items
    set live_revision = p_revision_id,
        publish_status = 'ready'
    where item_id = v_item_id;

    -- We update the acs_objects title as well.

    update acs_objects set title = v_title
    where object_id = v_item_id and (title != v_title or title is null);

    return 0;
END;

$$ LANGUAGE plpgsql;
