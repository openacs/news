-- /packages/news/sql/news-drop.sql
--
-- @author stefan@arsdigita.com
-- @created 2000-12-20
-- $Id$


-- unregister content_types from folder
declare
    v_folder_id	cr_folders.folder_id%TYPE;
    v_item_id   cr_items.item_id%TYPE;
    v_gc_id     general_comments.comment_id%TYPE;
    v_gc_msg_id acs_messages.message_id%TYPE;

    -- cursor on news items   
    cursor item_cursor IS
        select item_id
        from   cr_items
        where  parent_id = v_folder_id;
begin
    select content_item.get_id('news') into v_folder_id from dual;

-- delete all contents of news folder
    OPEN item_cursor;
    LOOP
        FETCH item_cursor into v_item_id;
	-- all attached types/item are deleted in news.delete - modify there
       	news.del(v_item_id);    
        EXIT WHEN item_cursor%NOTFOUND;
    END LOOP;
    CLOSE item_cursor;

-- unregister_content_types
    content_folder.unregister_content_type (
        folder_id        => v_folder_id,
        content_type     => 'content_revision',
        include_subtypes => 't'
    );
    content_folder.unregister_content_type (
        folder_id        => v_folder_id,
        content_type     => 'news',
        include_subtypes => 't'
    );

-- this table must not hold reference to 'news' type
delete from cr_folder_type_map where content_type = 'news';  

-- delete news folder
    content_folder.del(v_folder_id);

end;
/
show errors



drop package news;

-- delete news views

drop view news_items_approved;

drop view news_items_live_or_submitted;

drop view news_items_unapproved;

drop view news_item_revisions;

drop view news_item_unapproved;

drop view news_item_full_active;

-- drop indices to avoid lock situation through parent table

drop index cr_news_appuser_id_fk;


-- delete pertinent info from cr_news

drop table cr_news;



-- drop attributes
begin

-- website archive date of news release
content_type.drop_attribute (
    content_type   => 'news',
    attribute_name => 'archive_date'
);
-- assignement to an authorized user for approval
content_type.drop_attribute (
    content_type   => 'news',
    attribute_name => 'approval_user'
);
-- approval date
content_type.drop_attribute (
    content_type   => 'news',
    attribute_name => 'approval_date'
);
-- approval IP address
content_type.drop_attribute (
    content_type   => 'news',
    attribute_name => 'approval_ip'
);
-- delete content_type 'news'
acs_object_type.drop_type (
    object_type => 'news',
    cascade_p => 't'
);
end;

/
show errors







-- delete privileges;
declare
    default_context acs_objects.object_id%TYPE;
    registered_users acs_objects.object_id%TYPE;
    the_public acs_objects.object_id%TYPE;
begin
    acs_privilege.remove_child('news_admin','news_approve');
    acs_privilege.remove_child('news_admin','news_create');
    acs_privilege.remove_child('news_admin','news_delete');
    acs_privilege.remove_child('news_admin','news_read');

    acs_privilege.remove_child('read','news_read');
    acs_privilege.remove_child('create','news_create');
    acs_privilege.remove_child('delete','news_delete');
    acs_privilege.remove_child('admin','news_approve');

    acs_privilege.remove_child('admin','news_admin');	

    default_context := acs.magic_object_id('default_context');
    registered_users := acs.magic_object_id('registered_users');
    the_public := acs.magic_object_id('the_public');
    acs_permission.revoke_permission (
        object_id => default_context,
    	grantee_id => registered_users,
    	privilege => 'news_create'
    );
    acs_permission.revoke_permission (
        object_id => default_context,
	grantee_id => the_public,
	privilege => 'news_read'
    );

    acs_privilege.drop_privilege('news_approve');
    acs_privilege.drop_privilege('news_create');
    acs_privilege.drop_privilege('news_delete');
    acs_privilege.drop_privilege('news_read');
    acs_privilege.drop_privilege('news_admin');

end;
/
show errors




















