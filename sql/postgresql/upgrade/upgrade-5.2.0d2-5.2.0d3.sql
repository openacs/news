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
    p_package_id    alias for $8;  -- default null
    p_archive_date  alias for $9;  -- default null
    p_approval_user alias for $10; -- default null
    p_approval_date alias for $11; -- default null
    p_approval_ip   alias for $12; -- default null
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
        select acs_object_id_seq.nextval
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
        p_is_live_p           -- live_p
	''text''	      -- storage_type
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


