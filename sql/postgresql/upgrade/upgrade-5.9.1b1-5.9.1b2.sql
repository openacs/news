--
-- Don't call deprecated version of content_revision__new
--

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
        p_creation_ip,   -- creation_ip
	null,            -- content_length
        p_package_id     -- package_id
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

--
-- Remove leftover from old installations (perform cleanup which was missing since Feb 2005)
--
DROP FUNCTION IF EXISTS news__new(integer, character varying, timestamp with time zone, text, character varying, character varying, character varying, integer, timestamp with time zone, integer, timestamp with time zone, character varying, character varying, character varying, integer, boolean);
