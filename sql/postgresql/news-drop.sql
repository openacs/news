-- /packages/news/sql/news-drop.sql
--
-- @author stefan@arsdigita.com
-- @created 2000-12-20
-- $Id$


-- unregister content_types from folder
create function inline_0 ()
returns integer as '
declare
    v_folder_id	  cr_folders.folder_id%TYPE;
    v_item_id     cr_items.item_id%TYPE;
    -- RAL: commented out, not used. GC should be probably dealt with in
    -- news__delete anyways.
    -- v_gc_id       general_comments.comment_id%TYPE;
    -- v_gc_msg_id   acs_messages.message_id%TYPE;
    v_item_cursor RECORD;
        
begin
    select content_item__get_id(''news'', null, ''f'') into v_folder_id from dual;

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
        ''content_revision'', -- content_type
        ''t''                 -- include_subtypes
    );
    PERFORM content_folder__unregister_content_type (
        v_folder_id, -- folder_id
        ''news'',      -- content_type
        ''t''          -- include_subtypes
    );

    -- this table must not hold reference to ''news'' type
    delete from cr_folder_type_map where content_type = ''news'';

    -- delete news folder
    PERFORM content_folder__delete(v_folder_id);

    return 0;
end;
' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


-- drop package news
drop function news__new (integer,varchar,timestamp,text,varchar,varchar,
       varchar,integer,timestamp,integer,timestamp,varchar,varchar,
       varchar,integer,boolean);
drop function news__delete (integer);
drop function news__make_permanent (integer);
drop function news__archive (integer,timestamp);
drop function news__archive (integer);
drop function news__set_approve(integer,varchar,timestamp,
       timestamp,integer,timestamp,varchar,boolean);
drop function news__status (integer);
drop function news__name (integer);
drop function news__revision_new (integer,timestamp,text,varchar,text,
       varchar,integer,timestamp,integer,timestamp,varchar,timestamp,varchar,
       integer,boolean);
drop function news__revision_set_active (integer);
drop function news__revision_delete (integer);


-- delete news views

drop view news_items_approved;
drop view news_items_live_or_submitted;
drop view news_items_unapproved;
drop view news_item_revisions;
drop view news_item_unapproved;
drop view news_item_full_active;


-- drop attributes
begin;

-- website archive date of news release
select content_type__drop_attribute (
    'news',         -- content_type
    'archive_date', -- attribute_name
    'f'             -- drop_column
);
-- assignement to an authorized user for approval
select content_type__drop_attribute (
    'news',          -- content_type
    'approval_user', -- attribute_name
    'f'              -- drop_column
);
-- approval date
select content_type__drop_attribute (
    'news',          -- content_type
    'approval_date', -- attribute_name
    'f'              -- drop_column
);
-- approval IP address
select content_type__drop_attribute (
    'news',        -- content_type
    'approval_ip', -- attribute_name
    'f'            -- drop_column
);
-- delete content_type 'news'
select acs_object_type__drop_type (
    'news', -- object_type
    't'     -- cascade_p
);

end;


-- drop indices to avoid lock situation through parent table

drop index cr_news_appuser_id_fk;

-- delete pertinent info from cr_news

drop table cr_news;


-- delete privileges;
create function inline_0 ()
returns integer as '
declare
    default_context  acs_objects.object_id%TYPE;
    registered_users acs_objects.object_id%TYPE;
    the_public       acs_objects.object_id%TYPE;
begin
    PERFORM acs_privilege__remove_child(''news_admin'',''news_approve'');
    PERFORM acs_privilege__remove_child(''news_admin'',''news_create'');
    PERFORM acs_privilege__remove_child(''news_admin'',''news_delete'');
    PERFORM acs_privilege__remove_child(''news_admin'',''news_read'');

    PERFORM acs_privilege__remove_child(''read'',''news_read'');
    PERFORM acs_privilege__remove_child(''create'',''news_create'');
    PERFORM acs_privilege__remove_child(''delete'',''news_delete'');
    PERFORM acs_privilege__remove_child(''admin'',''news_approve'');

    PERFORM acs_privilege__remove_child(''admin'',''news_admin'');

    default_context  := acs__magic_object_id(''default_context'');
    registered_users := acs__magic_object_id(''registered_users'');
    the_public       := acs__magic_object_id(''the_public'');

    PERFORM acs_permission__revoke_permission (
        default_context,  -- object_id
    	registered_users, -- grantee_id
    	''news_create''   -- privilege
    );
    PERFORM acs_permission__revoke_permission (
        default_context, -- object_id
	the_public,      -- grantee_id
	''news_read''    -- privilege
    );

    PERFORM acs_privilege__drop_privilege(''news_approve'');
    PERFORM acs_privilege__drop_privilege(''news_create'');
    PERFORM acs_privilege__drop_privilege(''news_delete'');
    PERFORM acs_privilege__drop_privilege(''news_read'');
    PERFORM acs_privilege__drop_privilege(''news_admin'');

    return 0;
end;
' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();
