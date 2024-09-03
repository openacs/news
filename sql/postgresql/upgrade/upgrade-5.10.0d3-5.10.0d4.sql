--
-- Don't call deprecated version of content_revision__new
--

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
   p_lead varchar

) RETURNS integer AS $$
DECLARE
    v_news_id       integer;
    v_item_id       integer;
    v_id            integer;
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
        select nextval('t_acs_object_id_seq')
        into   v_id
        from   dual;
    else
        v_id := p_item_id;
    end if;

    v_name := 'news-' || to_char(current_timestamp,'YYYYMMDD') || '-' || v_id;
    v_log_string := 'initial submission';

    v_item_id := content_item__new(
        v_name,               -- name
        v_parent_id,          -- parent_id
        v_id,                 -- item_id
        p_locale,             -- locale
        current_timestamp,    -- creation_date
        p_creation_user,      -- creation_user
        p_package_id,         -- context_id
        p_creation_ip,        -- creation_ip
        'content_item',       -- item_subtype
        'news',               -- content_type
        p_title,              -- title
        v_log_string,         -- description
        p_mime_type,          -- mime_type
        p_nls_language,       -- nls_language
        null,                 -- text
        p_text,               -- data
        null,                 -- relation_tag
        p_is_live_p,          -- live_p
        'text',	              -- storage_type
        p_package_id          -- package_id
    );

    -- Get the newly created revision_id as news_id.
    -- Use the "live_revision" (if set) or as fallback
    -- the "latest_revision"
    v_news_id := content_item__get_best_revision(v_item_id);

    --
    -- setting publish_date to the provided p_publish_date
    --
    update cr_revisions
    set publish_date = p_publish_date
    where revision_id = v_news_id;

    insert into cr_news
        (news_id,
         lead,
         package_id,
         archive_date,
         approval_user,
         approval_date,
         approval_ip)
    values
        (v_news_id,
         p_lead,
         p_package_id,
         p_archive_date,
         p_approval_user,
         p_approval_date,
         p_approval_ip);

    return v_news_id;
END;
$$ LANGUAGE plpgsql;
