-- /packages/news/sql/news-create.sql
--
-- @author stefan@arsdigita.com
-- @created 2000-12-13
-- @cvs-id $Id$


-- *** PERMISSION MODEL ***
--
begin
    -- the read privilege is by default granted to 'the_public'
    -- the site-wide administrator has to change this in /permissions/ 
    -- if he wants to restrict an instance to a specific party

    -- the news_admin has all privileges: read, create, delete, approve
    -- news_admin is a child of 'admin'.
    -- 'admin' is therefore the top-administrator, news_admin is the news administrator
    -- in the context of an instance

    acs_privilege.create_privilege('news_read');
    acs_privilege.create_privilege('news_create');
    acs_privilege.create_privilege('news_delete');

    -- bind privileges to global names  
    acs_privilege.add_child('read','news_read');
    acs_privilege.add_child('create','news_create');
    acs_privilege.add_child('delete','news_delete');

    -- add this to the news_admin privilege
    acs_privilege.create_privilege('news_admin', 'News Administrator');
    -- news administrator binds to global 'admin', plus inherits news_* permissions
    acs_privilege.add_child('admin','news_admin');      
    acs_privilege.add_child('news_admin','news_read');
    acs_privilege.add_child('news_admin','news_create');
    acs_privilege.add_child('news_admin','news_delete');
end;
/
show errors

-- assign permission to defined contexts within ACS by default
--
declare
    default_context acs_objects.object_id%TYPE;
    registered_users acs_objects.object_id%TYPE;
    the_public acs_objects.object_id%TYPE;
begin
    default_context  := acs.magic_object_id('default_context');
    registered_users := acs.magic_object_id('registered_users');
    the_public       := acs.magic_object_id('the_public');
    

    -- give the public permission to read by default
    acs_permission.grant_permission (
        object_id  => default_context,
        grantee_id => the_public,
        privilege  => 'news_read'
    );

    -- give registered users permission to upload items by default
    -- However, they must await approval by users with news_admin privilege
       acs_permission.grant_permission (
         object_id  => default_context,
         grantee_id => registered_users,
         privilege  => 'news_create'
       );

end;
/
show errors



-- *** DATAMODEL ***
-- we use the content repository (see http://cvs.arsdigita.com/acs/packages/acs-content-repository) plus this
create table cr_news (
    news_id                     integer
                                constraint cr_news_id_fk 
                                references cr_revisions
                                constraint cr_news_pk 
                                primary key,
    -- include package_id to provide support for multiple instances
    package_id                  integer
                                constraint cr_news_package_id_nn not null,      
    -- regarding news item
    -- *** support for dates when items are displayed or archived ***
    -- unarchived news items have archive_date null
    archive_date                date,
    -- support for approval
    approval_user               integer
                                constraint cr_news_approval_user_fk
                                references users,
    approval_date               date,
    approval_ip                 varchar2(50)
);


-- index to avoid lock situation through parent table
create  index cr_news_appuser_id_fk on cr_news(approval_user);


-- *** NEWS item defitition *** ---
begin
content_type.create_type (
    content_type  => 'news',
    pretty_name   => 'News Item',
    pretty_plural => 'News Items',
    table_name    => 'cr_news',
    id_column     => 'news_id',
    name_method   => 'news.name'
);
end;
/

declare
    attr_id acs_attributes.attribute_id%TYPE;
begin
-- create attributes for widget generation

-- website archive date of news release
attr_id := content_type.create_attribute (
    content_type   => 'news',
    attribute_name => 'archive_date',
    datatype       => 'timestamp',
    pretty_name    => 'Archive Date',
    pretty_plural  => 'Archive Dates',
    column_spec    => 'date'
);
-- authorized user for approval
attr_id := content_type.create_attribute (
    content_type   => 'news',
    attribute_name => 'approval_user',
    datatype       => 'integer',
    pretty_name    => 'Approval User',
    pretty_plural  => 'Approval Users',
    column_spec    => 'integer'
);
-- approval date
attr_id := content_type.create_attribute (
    content_type   => 'news',
    attribute_name => 'approval_date',
    datatype       => 'timestamp',
    pretty_name    => 'Approval Date',
    pretty_plural  => 'Approval Dates',
    default_value  => sysdate,
    column_spec    => 'date'
);
-- approval IP address
attr_id := content_type.create_attribute (
    content_type   => 'news',
    attribute_name => 'approval_ip',
    datatype       => 'text',
    pretty_name    => 'Approval IP',
    pretty_plural  => 'Approval IPs',
    column_spec    => 'varchar2(50)'
);
end;
/
show errors



-- *** CREATE THE NEWS FOLDER as our CONTAINER ***

-- create 1 news folder; different instances are filtered by package_id
declare
    v_folder_id cr_folders.folder_id%TYPE;
begin
    v_folder_id := content_folder.new(
        name        => 'news',
        label       => 'news',
        description => 'News Item Root Folder, all news items go in here'
    );
-- associate content types with news folder
    content_folder.register_content_type (
        folder_id        => v_folder_id,
        content_type     => 'news',
        include_subtypes => 't'
    );
    content_folder.register_content_type (
        folder_id        => v_folder_id,
        content_type     => 'content_revision',
        include_subtypes => 't'
    );
end;
/
show errors


-- *** PACKAGE NEWS, plsql to create content_item ***
create or replace package news
as 
    function new (
        item_id                 in cr_items.item_id%TYPE 	  default null,
        --
        locale                  in cr_items.locale%TYPE 	  default null, 
        --
        publish_date            in cr_revisions.publish_date%TYPE default null,
        text                    in varchar2                       default null,
        nls_language            in cr_revisions.nls_language%TYPE default null,
        title                   in cr_revisions.title%TYPE 	  default null,
        mime_type               in cr_revisions.mime_type%TYPE    default 'text/plain',
        --
        package_id              in cr_news.package_id%TYPE 	  default null,        
        archive_date            in cr_news.archive_date%TYPE      default null,
        approval_user           in cr_news.approval_user%TYPE     default null,
        approval_date           in cr_news.approval_date%TYPE     default null,
        approval_ip             in cr_news.approval_ip%TYPE       default null,      
        --
        relation_tag            in cr_child_rels.relation_tag%TYPE 
                                                                  default null,
        --
        item_subtype            in acs_object_types.object_type%TYPE 
                                                                  default 'content_revision',
        content_type            in acs_object_types.object_type%TYPE 
                                                                  default 'news',
        creation_date           in acs_objects.creation_date%TYPE default sysdate,
        creation_ip             in acs_objects.creation_ip%TYPE   default null,
        creation_user           in acs_objects.creation_user%TYPE default null,
        --
        is_live_p               in varchar2                       default 'f' 
    ) return cr_news.news_id%TYPE;

    procedure del (
        item_id in cr_items.item_id%TYPE
    );  

    procedure archive (
        item_id in cr_items.item_id%TYPE,
        archive_date in cr_news.archive_date%TYPE default sysdate       
    );  

    procedure make_permanent (
           item_id in cr_items.item_id%TYPE
    );

   
    procedure set_approve (
        revision_id      in cr_revisions.revision_id%TYPE,       
	approve_p        in varchar2 default 't',  
        publish_date     in cr_revisions.publish_date%TYPE  	default null,
        archive_date     in cr_news.archive_date%TYPE 		default null,
        approval_user    in cr_news.approval_user%TYPE 		default null,
        approval_date    in cr_news.approval_date%TYPE 		default sysdate,
        approval_ip      in cr_news.approval_ip%TYPE 		default null, 
        live_revision_p  in varchar2 default 't'
    );



    function status (
        publish_date     in cr_revisions.publish_date%TYPE,
        archive_date     in cr_news.archive_date%TYPE
    ) return varchar2;


    function name (
	news_id in cr_news.news_id%TYPE
    ) return varchar2;   


    --  
    -- API for revisions: e.g. when the news admin wants to revise a news item
    --
    function revision_new (
        item_id                 in cr_items.item_id%TYPE,       
        --
        publish_date            in cr_revisions.publish_date%TYPE    default null,
        text                    in varchar2                   default null,
        title                   in cr_revisions.title%TYPE,
        --
        -- here goes the revision log
        description             in cr_revisions.description%TYPE,
        --
        mime_type               in cr_revisions.mime_type%TYPE 	     default 'text/plain',
        package_id              in cr_news.package_id%TYPE 	     default null,        
        archive_date            in cr_news.archive_date%TYPE         default null,
        approval_user           in cr_news.approval_user%TYPE        default null,
        approval_date           in cr_news.approval_date%TYPE        default null,
        approval_ip             in cr_news.approval_ip%TYPE          default null,      
        --
        creation_date           in acs_objects.creation_date%TYPE    default sysdate,
        creation_ip             in acs_objects.creation_ip%TYPE      default null,           
        creation_user           in acs_objects.creation_user%TYPE    default null,
        --
        make_active_revision_p  in varchar2 default 'f'
    ) return cr_revisions.revision_id%TYPE;


    procedure revision_delete (
       revision_id in cr_revisions.revision_id%TYPE
    );


    procedure revision_set_active (
       revision_id in cr_revisions.revision_id%TYPE
    );

    procedure clone (
        new_package_id          in cr_news.package_id%TYPE 	  default null,
        old_package_id          in cr_news.package_id%TYPE 	  default null
    );

end news;
/
show errors



create or replace package body news
    as
    function new (
        item_id                 in cr_items.item_id%TYPE             default null,
        --
        locale                  in cr_items.locale%TYPE              default null, 
        --
        publish_date            in cr_revisions.publish_date%TYPE    default null,
        text                    in varchar2                          default null,
        nls_language            in cr_revisions.nls_language%TYPE    default null,
        title                   in cr_revisions.title%TYPE           default null,
        mime_type               in cr_revisions.mime_type%TYPE       default 
	                					     'text/plain',
        --
        package_id              in cr_news.package_id%TYPE           default null,      
        archive_date            in cr_news.archive_date%TYPE         default null,
        approval_user           in cr_news.approval_user%TYPE        default null,
        approval_date           in cr_news.approval_date%TYPE        default null,
        approval_ip             in cr_news.approval_ip%TYPE          default null,      
        --
        relation_tag            in cr_child_rels.relation_tag%TYPE   default null,
        --
        item_subtype            in acs_object_types.object_type%TYPE default 
                                                                     'content_revision',
        content_type            in acs_object_types.object_type%TYPE default 'news',
        creation_date           in acs_objects.creation_date%TYPE    default sysdate,
        creation_ip             in acs_objects.creation_ip%TYPE      default null,
        creation_user           in acs_objects.creation_user%TYPE    default null,
        --
        is_live_p               in varchar2                          default 'f'
    ) return cr_news.news_id%TYPE
    is
        v_news_id         integer;
        v_item_id         integer;
        v_id              integer;
        v_revision_id     integer;
        v_parent_id       integer;
        v_name            varchar2(200);
        v_log_string      varchar2(400);
    begin
        select content_item.get_id('news') 
        into   v_parent_id 
        from   dual;    
        --
        -- this will be used for 2xClick protection
        if item_id is null then
            select acs_object_id_seq.nextval 
            into   v_id 
            from   dual;
        else 
            v_id := item_id;
        end if; 
        --
        select 'news' || to_char(sysdate,'YYYYMMDD') || v_id 
        into   v_name 
        from   dual;    
        -- 
        v_log_string := 'initial submission'; 
        -- 
        v_item_id := content_item.new(
            item_id       => v_id,
            name          => v_name,
            parent_id     => v_parent_id,
            context_id    => package_id,
            locale        => locale,
            item_subtype  => item_subtype,
            content_type  => content_type,
            mime_type     => mime_type,
            nls_language  => nls_language,
            relation_tag  => relation_tag,
            creation_date => creation_date,
            creation_ip   => creation_ip,        
            creation_user => creation_user
        );
        v_revision_id := content_revision.new(
            title         => title,
            description   => v_log_string,
            publish_date  => publish_date,
            mime_type     => mime_type,
            nls_language  => nls_language,
            text          => text,
            item_id       => v_item_id,
            creation_date => creation_date,
            creation_ip   => creation_ip,
            creation_user => creation_user
        );
        insert into cr_news 
            (news_id, 
             package_id, 
             archive_date,
             approval_user, 
             approval_date, 
             approval_ip)
        values
            (v_revision_id, 
             package_id, 
             archive_date,
             approval_user, 
             approval_date, 
             approval_ip);
        -- make this revision live when immediately approved
        if is_live_p = 't' then
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
    end new;


    -- deletes a news item along with all its revisions and possibnle attachements
    procedure del (
        item_id in cr_items.item_id%TYPE
    ) is
    v_item_id   cr_items.item_id%TYPE;

    cursor comment_cursor IS
        select message_id 
        from   acs_messages am, acs_objects ao
	where  am.message_id = ao.object_id
        and    ao.context_id = v_item_id;

    begin
    v_item_id := news.del.item_id;
	dbms_output.put_line('Deleting associated comments...');
	-- delete acs_messages, images, comments to news item
	for v_cm in  comment_cursor loop
	    -- images
	    delete from images
        	where image_id in (select latest_revision
                                   from cr_items 
                                   where parent_id = v_cm.message_id);
	    acs_message.del(v_cm.message_id);
            delete from general_comments
		where comment_id = v_cm.message_id;	 
        end loop;
        delete from cr_news 
        where news_id in (select revision_id 
                          from   cr_revisions 
                          where  item_id = v_item_id);
        content_item.del(v_item_id);
    end del;


    -- (re)-publish a news item out of the archive by nulling the archive_date
    -- this only applies to the currently active revision
    procedure make_permanent (
        item_id in cr_items.item_id%TYPE
     )
    is
    begin
        update cr_news
        set    archive_date = null
        where  news_id = content_item.get_live_revision(news.make_permanent.item_id);
    end make_permanent;


    -- archive a news item
    -- this only applies to the currently active revision
    procedure archive (
        item_id in cr_items.item_id%TYPE,
        archive_date in cr_news.archive_date%TYPE default sysdate       
    )
    is
    begin
        update cr_news  
        set    archive_date = news.archive.archive_date
        where  news_id = content_item.get_live_revision(news.archive.item_id);
    end archive;

  
    -- approve/unapprove a specific revision
    -- approving a revision makes it also the active revision
    procedure set_approve(  
        revision_id      in cr_revisions.revision_id%TYPE,       
	approve_p        in varchar2 default 't',  
        publish_date     in cr_revisions.publish_date%TYPE default null,
        archive_date     in cr_news.archive_date%TYPE default null,
        approval_user    in cr_news.approval_user%TYPE default null,
        approval_date    in cr_news.approval_date%TYPE default sysdate,
        approval_ip      in cr_news.approval_ip%TYPE default null, 
        live_revision_p  in varchar2 default 't'
    )
    is
        v_item_id cr_items.item_id%TYPE;
    begin
        select item_id into v_item_id 
        from   cr_revisions 
        where  revision_id = news.set_approve.revision_id;
        -- unapprove an revision (does not mean to knock out active revision)
        if news.set_approve.approve_p = 'f' then
            update  cr_news 
            set     approval_date = null,
                    approval_user = null,
                    approval_ip   = null,
                    archive_date  = null
            where   news_id = news.set_approve.revision_id;
            --
            update  cr_revisions
            set     publish_date = null
            where   revision_id  = news.set_approve.revision_id;
        else
        -- approve a revision
            update  cr_revisions
            set     publish_date  = news.set_approve.publish_date
            where   revision_id   = news.set_approve.revision_id;
            --  
            update  cr_news 
            set archive_date  = news.set_approve.archive_date,
                approval_date = news.set_approve.approval_date,
                approval_user = news.set_approve.approval_user,
                approval_ip   = news.set_approve.approval_ip
            where news_id     = news.set_approve.revision_id;
            -- 
            -- cannot use content_item.set_live_revision because it sets publish_date to sysdate
            if news.set_approve.live_revision_p = 't' then
                update  cr_items
                set     live_revision = news.set_approve.revision_id,
                        publish_status = 'ready'
                where   item_id = v_item_id;
            end if;
            --
        end if;    
    end set_approve;



    -- the status function returns information on the puplish or archive status
    -- it does not make any checks on the order of publish_date and archive_date
    function status (
        publish_date     in cr_revisions.publish_date%TYPE,
        archive_date     in cr_news.archive_date%TYPE
    ) return varchar2
    is
    begin

        if publish_date is not null then
            if publish_date > sysdate  then
                -- to be published (2 cases)
                if archive_date is null then 
                    return 'going_live_no_archive';
                else 
                    return 'going_live_with_archive';
                end if;  
            else
                -- already released or even archived (3 cases)
                if archive_date is null then
                     return 'published_no_archive';
                else
                    if archive_date - sysdate > 0 then
                        return 'published_with_archive';
                    else 
                        return 'archived';
                    end if;
                 end if;
            end if;     
        else 
            return 'unapproved';
        end if;
    end status;


    function name (
	news_id in cr_news.news_id%TYPE
    ) return varchar2
    is
        news_title varchar2(1000);
    begin
        select title 
	into news_title
        from cr_revisions
        where revision_id = news.name.news_id;

        return news_title;
    end name;
    

    -- 
    -- API for Revision management
    -- 
    function revision_new (
        item_id                 in cr_items.item_id%TYPE,       
        --
        publish_date            in cr_revisions.publish_date%TYPE  	default null,
        text                    in varchar2                             default null,
        title                   in cr_revisions.title%TYPE,
        --
        -- here goes the revision log
        description             in cr_revisions.description%TYPE,
        --
        mime_type               in cr_revisions.mime_type%TYPE 		default 'text/plain',
        package_id              in cr_news.package_id%TYPE 		default null,        
        archive_date            in cr_news.archive_date%TYPE 		default null,
        approval_user           in cr_news.approval_user%TYPE 		default null,
        approval_date           in cr_news.approval_date%TYPE 		default null,
        approval_ip             in cr_news.approval_ip%TYPE   		default null,      
        --
        creation_date           in acs_objects.creation_date%TYPE 	default sysdate,
        creation_ip             in acs_objects.creation_ip%TYPE 	default null,           
        creation_user           in acs_objects.creation_user%TYPE 	default null,
        --
        make_active_revision_p  in varchar2 default 'f'
    ) return cr_revisions.revision_id%TYPE
    is  
        v_revision_id    integer;
    begin
        -- create revision
        v_revision_id := content_revision.new(
            title         => title,
            description   => description,
            publish_date  => publish_date,
            mime_type     => mime_type,
            text          => text,
            item_id       => item_id,
            creation_date => creation_date,
            creation_user => creation_user,
            creation_ip   => creation_ip
        );
        -- create new news entry with new revision
        insert into cr_news
            (news_id, 
             package_id,
             archive_date, 
             approval_user, 
             approval_date, 
             approval_ip)
        values
            (v_revision_id, 
             package_id,
             archive_date, 
             approval_user, 
             approval_date,
             approval_ip);
        -- make active revision if indicated
        if make_active_revision_p = 't' then
            news.revision_set_active(v_revision_id);
        end if;
        return v_revision_id;
    end revision_new;



    procedure revision_set_active   (
        revision_id in cr_revisions.revision_id%TYPE
    )
    is
        v_news_item_p char;
        -- could be used to check if really a 'news' item
    begin
        update	
            cr_items
        set
            live_revision = news.revision_set_active.revision_id,
            publish_status = 'ready'
        where
	    item_id = (select
                           item_id
                       from
                           cr_revisions
                       where
                           revision_id = news.revision_set_active.revision_id);
    end revision_set_active; 


    procedure clone   (
        new_package_id    in cr_news.package_id%TYPE    default null,
        old_package_id    in cr_news.package_id%TYPE    default null
    )
    is
      new_news_id integer;
    begin
        for one_news in (select
                            publish_date,
                            content.blob_to_string(cr.content) as text,
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
                            ao.creation_user
                        from 
                            cr_items ci, 
                            cr_revisions cr,
                            cr_news cn,
                            acs_objects ao
                        where
                            (ci.item_id = cr.item_id
                            and ci.live_revision = cr.revision_id 
                            and cr.revision_id = cn.news_id 
                            and cr.revision_id = ao.object_id)
                        or (ci.live_revision is null 
                            and ci.item_id = cr.item_id
                            and cr.revision_id = content_item.get_latest_revision(ci.item_id)
                            and cr.revision_id = cn.news_id
                            and cr.revision_id = ao.object_id))
        loop

            new_news_id := news.new(
                publish_date      => one_news.publish_date,
                text              => one_news.text,
                nls_language      => one_news.nls_language,
                title             => one_news.title,
                mime_type         => one_news.mime_type,
                package_id        => news.clone.new_package_id,
                archive_date      => one_news.archive_date,
                approval_user     => one_news.approval_user,
                approval_date     => one_news.approval_date,
                approval_ip       => one_news.approval_ip,
                creation_date     => one_news.creation_date,
                creation_ip       => one_news.creation_ip,
                creation_user     => one_news.creation_user
            );

        end loop;
    end clone;

    -- currently not used, because we want to audit revisions
    procedure revision_delete (
        revision_id in cr_revisions.revision_id%TYPE
    )
    is
    begin
    -- delete from cr_news table
        delete from cr_news
        where  news_id = news.revision_delete.revision_id;
        -- delete revision
        content_revision.del(
            revision_id => news.revision_delete.revision_id
        );
    end revision_delete;

end news;
/
show errors




--
--  views on 'news' application that pick from cr_news, cr_items, cr_revisions
--  Re-arrange 'joins' for performance tuning
-- 

--  Views on multiple items

-- View on all released news items in its active revision
create or replace view news_items_approved
as
select
    ci.item_id as item_id,
    cn.package_id, 
    cr.title as publish_title,
    content.blob_to_string(cr.content) as publish_body,
    cr.content as content,
    decode(cr.mime_type, 'text/html','t','f') as html_p,
    to_char(cr.publish_date, 'Mon dd, yyyy') as pretty_publish_date,
    cr.publish_date,
    ao.creation_user,
    ps.first_names || ' ' || ps.last_name as item_creator,
    cn.archive_date    
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


-- View of all news items in the system 
create or replace view news_items_live_or_submitted
as 
select
    ci.item_id as item_id,
    cn.news_id,
    cn.package_id,
    cr.publish_date,
    cn.archive_date,
    cr.title as publish_title,
    content.blob_to_string(cr.content) as publish_body,
    decode(cr.mime_type, 'text/html','t','f') as html_p,
    ao.creation_user,
    ps.first_names || ' ' || ps.last_name as item_creator,
    ao.creation_date,
    ci.live_revision,
    news.status(cr.publish_date, cn.archive_date) as status
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
    and cr.revision_id = content_item.get_latest_revision(ci.item_id)
    and cr.revision_id = cn.news_id
    and cr.revision_id = ao.object_id
    and ao.creation_user = ps.person_id);


-- View of unapproved items 
create or replace view news_items_unapproved
as 
select      
    ci.item_id as item_id,
    cr.title as publish_title,
    cn.package_id as package_id,
    ao.creation_date as creation_date,
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
and cr.revision_id = content_item.get_live_revision(ci.item_id)
and cr.revision_id = cn.news_id
and cr.item_id = ci.item_id
and cr.publish_date is null;



-- One News Item Views
--

-- View of all revisions of a news item
create or replace view news_item_revisions
as 
select
    cr.item_id as item_id,
    cr.revision_id,
    ci.live_revision,
    cr.title as publish_title,
    content.blob_to_string(cr.content) as publish_body,
    cr.publish_date,
    cn.archive_date,
    cr.description as log_entry,
    decode(cr.mime_type,'text/html','t','f') as html_p,
    cr.mime_type as mime_type,
    cn.package_id,
    ao.creation_date as creation_date,
    news.status(cr.publish_date, cn.archive_date) as status,
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



-- View of a submitted news item or active revision in unapproved state
create or replace view news_item_unapproved
as 
select
    cr.revision_id,
    ci.name as item_name,
    ps.first_names || ' ' || ps.last_name as item_creator,
    ao.creation_ip as item_creation_ip,
    ao.creation_date
from 
    cr_revisions cr,
    cr_items ci,
    acs_objects ao,
    persons ps    
where 
    ci.item_id = cr.item_id
and cr.revision_id = ao.object_id
and ao.creation_user = ps.person_id;



-- View of a news item as of its active revision
create or replace view news_item_full_active
as 
select
    ci.item_id as item_id,
    cn.package_id as package_id,
    revision_id,        
    cr.title as publish_title,
    content.blob_to_string(cr.content) as publish_body,
    decode(cr.mime_type,'text/html','t','f') as html_p,
    cr.publish_date,
    cn.archive_date,
    news.status(cr.publish_date, cn.archive_date) as status,
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
    and cr.revision_id = content_item.get_latest_revision(ci.item_id)))
and cr.revision_id = cn.news_id
and ci.item_id = ao.object_id
and ao.creation_user = ps.person_id;


-- plsql to create keywords for news items
-- no additional code necessary for news items right now.

-- plsql for searches: will be covered by site-wide search
-- no additional code necessary for news  items right now.
