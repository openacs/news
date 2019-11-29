-- /packages/news/sql/news-drop.sql
--
-- @author stefan@arsdigita.com
-- @created 2000-12-20
-- $Id$

-- unregister content_types from folder


--
-- procedure inline_0/0
--
CREATE OR REPLACE FUNCTION inline_0(

) RETURNS integer AS $$
DECLARE
    v_folder_id	  cr_folders.folder_id%TYPE;
    v_item_id     cr_items.item_id%TYPE;
    -- RAL: commented out, not used. GC should be probably dealt with in
    -- news__delete anyways.
    -- v_gc_id       general_comments.comment_id%TYPE;
    -- v_gc_msg_id   acs_messages.message_id%TYPE;
    v_item_cursor RECORD;
BEGIN
    select content_item__get_id('news', null, 'f') into v_folder_id from dual;

    -- delete all contents of news folder
    FOR v_item_cursor IN
        select item_id
        from   cr_items
        where  parent_id = v_folder_id
    LOOP
	-- all attached types/item are deleted in news.delete - modify there
       	PERFORM news__delete(v_item_cursor.item_id);
    END LOOP;

    -- unregister_content_types
    PERFORM content_folder__unregister_content_type (
        v_folder_id,        -- folder_id
        'content_revision', -- content_type
        't'                 -- include_subtypes
    );
    PERFORM content_folder__unregister_content_type (
        v_folder_id, -- folder_id
        'news',      -- content_type
        't'          -- include_subtypes
    );

    -- this table must not hold reference to 'news' type
    delete from cr_folder_type_map where content_type = 'news';

    -- delete news folder
    PERFORM content_folder__delete(v_folder_id);

    return 0;
END;

$$ LANGUAGE plpgsql;

select inline_0 ();
drop function inline_0 ();



-- Til: after adding content_type__drop_type above, dropping the table
-- and the index explicitly was not necessary anymore. Leaving the calls
-- commented out here though, so that they can be reactivated in case the lock
-- situation mentioned in the original comment below occurs for some reason.

-- drop indices to avoid lock situation through parent table
--drop index cr_news_appuser_id_fk;
-- delete pertinent info from cr_news
--drop table cr_news;

\i news-views-drop.sql

\i news-package-drop.sql


-- drop CR content_type
select content_type__drop_type(
        'news',    -- content_type
        't',       -- drop_children_p
        't'        -- drop_table_p
);


-- delete privileges;


--
-- procedure inline_0/0
--
CREATE OR REPLACE FUNCTION inline_0(

) RETURNS integer AS $$
DECLARE
    default_context  acs_objects.object_id%TYPE;
    registered_users acs_objects.object_id%TYPE;
    the_public       acs_objects.object_id%TYPE;
BEGIN
    PERFORM acs_privilege__remove_child('news_admin','news_approve');
    PERFORM acs_privilege__remove_child('news_admin','news_create');
    PERFORM acs_privilege__remove_child('news_admin','news_delete');
    PERFORM acs_privilege__remove_child('news_admin','news_read');

    PERFORM acs_privilege__remove_child('read','news_read');
    PERFORM acs_privilege__remove_child('create','news_create');
    PERFORM acs_privilege__remove_child('delete','news_delete');
    PERFORM acs_privilege__remove_child('admin','news_approve');

    PERFORM acs_privilege__remove_child('admin','news_admin');

    default_context  := acs__magic_object_id('default_context');
    registered_users := acs__magic_object_id('registered_users');
    the_public       := acs__magic_object_id('the_public');

    PERFORM acs_permission.revoke_permission (
        default_context,  -- object_id
    	registered_users, -- grantee_id
    	'news_create'   -- privilege
    );
    PERFORM acs_permission.revoke_permission (
        default_context, -- object_id
	the_public,      -- grantee_id
	'news_read'    -- privilege
    );

    PERFORM acs_privilege__drop_privilege('news_approve');
    PERFORM acs_privilege__drop_privilege('news_create');
    PERFORM acs_privilege__drop_privilege('news_delete');
    PERFORM acs_privilege__drop_privilege('news_read');
    PERFORM acs_privilege__drop_privilege('news_admin');

    return 0;
END;

$$ LANGUAGE plpgsql;

select inline_0 ();
drop function inline_0 ();

-- *** Drop News Notification Type ***
--
select notification_type__delete((
       select type_id from notification_types
        where short_name = 'one_news_item_notif'));

-- *** Service contract de-registration ***
--
select acs_sc_impl__delete(
	   'FtsContentProvider',		-- impl_contract_name
           'news'				-- impl_name
);

select acs_sc_impl__delete(
	   'RssGenerationSubscriber',		-- impl_contract_name
           'news'				-- impl_name
);

select acs_sc_impl__delete(
	   'NotificationType',          -- impl_contract_name
           'news_item_notif_type'	-- impl_name
);

