-- /packages/news/sql/news-package-create.sql
--
-- @author stefan@arsdigita.com
-- @created 2000-12-13
-- @cvs-id $Id$
--
-- OpenACS Port: Robert Locke (rlocke@infiniteinfo.com)

-- *** PACKAGE NEWS, plsql to create content_item ***



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

    --
    -- get the newly created revision_id as news_id
    --
    v_news_id := content_item__get_live_revision(v_item_id);

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



-- deletes a news item along with all its revisions and possible attachements

select define_function_args('news__delete','item_id');

--
-- procedure news__delete/1
--
CREATE OR REPLACE FUNCTION news__delete(
   p_item_id integer
) RETURNS integer AS $$
DECLARE
    v_item_id cr_items.item_id%TYPE;
    v_cm RECORD;
BEGIN
    v_item_id := p_item_id;
    -- dbms_output.put_line('Deleting associated comments...');
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
END;

$$ LANGUAGE plpgsql;


-- (re)-publish a news item out of the archive by nulling the archive_date
-- this only applies to the currently active revision

select define_function_args('news__make_permanent','item_id');

--
-- procedure news__make_permanent/1
--
CREATE OR REPLACE FUNCTION news__make_permanent(
   p_item_id integer
) RETURNS integer AS $$
DECLARE
BEGIN
    update cr_news
    set    archive_date = null
    where  news_id = content_item__get_live_revision(p_item_id);

    return 0;
END;

$$ LANGUAGE plpgsql;


-- archive a news item
-- this only applies to the currently active revision

select define_function_args('news__archive','item_id,archive_date;current_timestamp');

--
-- procedure news__archive/2
--
CREATE OR REPLACE FUNCTION news__archive(
   p_item_id integer,
   p_archive_date timestamptz DEFAULT current_timestamp

) RETURNS integer AS $$
DECLARE
BEGIN
    update cr_news
    set    archive_date = p_archive_date
    where  news_id = content_item__get_live_revision(p_item_id);

    return 0;
END;
$$ LANGUAGE plpgsql;



-- approve/unapprove a specific revision
-- approving a revision makes it also the active revision


-- added
select define_function_args('news__set_approve','revision_id,approve_p;t,publish_date;null,archive_date;null,approval_user;null,approval_date;current_timestamp,approval_ip;null,live_revision_p;t');

--
-- procedure news__set_approve/8
--
CREATE OR REPLACE FUNCTION news__set_approve(
   p_revision_id integer,
   p_approve_p varchar,         -- default 't'
   p_publish_date timestamptz,  -- default null
   p_archive_date timestamptz,  -- default null
   p_approval_user integer,     -- default null
   p_approval_date timestamptz, -- default current_timestamp
   p_approval_ip varchar,       -- default null
   p_live_revision_p boolean    -- default 't'

) RETURNS integer AS $$
DECLARE
    v_item_id         cr_items.item_id%TYPE;
BEGIN
    select item_id into v_item_id
    from   cr_revisions
    where  revision_id = p_revision_id;
    -- unapprove an revision (does not mean to knock out active revision)
    if p_approve_p = 'f' then
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
        if p_live_revision_p = 't' then
            update  cr_items
            set     live_revision = p_revision_id,
                    publish_status = 'ready'
            where   item_id = v_item_id;
        end if;
        --
    end if;

    return 0;
END;

$$ LANGUAGE plpgsql;


-- the status function returns information on the publish or archive status
-- it does not make any checks on the order of publish_date and archive_date


-- added
select define_function_args('news__status','publish_date,archive_date');

--
-- procedure news__status/2
--
CREATE OR REPLACE FUNCTION news__status(
   p_publish_date timestamptz,
   p_archive_date timestamptz
) RETURNS varchar AS $$
DECLARE
BEGIN
    if p_publish_date is not null then
        if p_publish_date > current_timestamp then
            -- Publishing in the future
            if p_archive_date is null then
                return 'going_live_no_archive';
            else
                return 'going_live_with_archive';
            end if;
        else
            -- Published in the past
            if p_archive_date is null then
                 return 'published_no_archive';
            else
                if p_archive_date > current_timestamp then
                     return 'published_with_archive';
                else
                    return 'archived';
                end if;
            end if;
        end if;
    else
        -- publish_date null
        return 'unapproved';
    end if;
END;

$$ LANGUAGE plpgsql;



-- added
select define_function_args('news__name','news_id');

--
-- procedure news__name/1
--
CREATE OR REPLACE FUNCTION news__name(
   p_news_id integer
) RETURNS varchar AS $$
DECLARE
    v_news_title cr_revisions.title%TYPE;
BEGIN
    select title
    into v_news_title
    from cr_revisions
    where revision_id = p_news_id;

    return v_news_title;
END;

$$ LANGUAGE plpgsql;


--
-- API for Revision management
--


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



-- Incomplete for want of blob_to_string() in postgres 16 july 2000



-- added
select define_function_args('news__clone','old_package_id,new_package_id');

--
-- procedure news__clone/2
--
CREATE OR REPLACE FUNCTION news__clone(
   p_old_package_id integer, --default null,
   p_new_package_id integer  --default null

) RETURNS integer AS $$
DECLARE
 one_news record;
BEGIN
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
END;

$$ LANGUAGE plpgsql;


-- currently not used, because we want to audit revisions


-- added
select define_function_args('news__revision_delete','revision_id');

--
-- procedure news__revision_delete/1
--
CREATE OR REPLACE FUNCTION news__revision_delete(
   p_revision_id integer
) RETURNS integer AS $$
DECLARE
BEGIN
    -- delete from cr_news table
    delete from cr_news
    where  news_id = p_revision_id;

    -- delete revision
    PERFORM content_revision__delete(
        p_revision_id -- revision_id
    );

    return 0;
END;

$$ LANGUAGE plpgsql;


