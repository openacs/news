-- news upgrade script
-- @author Vinod Kurup (vinod@kurup.com)
-- @creation-date 2002-10-27

-- new function news__clone

create or replace function news__clone (integer, integer)
returns integer as '
declare
 p_new_package_id   alias for $1;   --default null,
 p_old_package_id   alias for $2;   --default null
 one_news		record;	 
begin
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
                            and cr.revision_id = content_item__get_latest_revision(ci.item_id)
                            and cr.revision_id = cn.news_id
                            and cr.revision_id = ao.object_id)

        loop
            perform news__new(
                				one_news.publish_date,
                				one_news.text,
                				one_news.nls_language,
                				one_news.title,
                				one_news.mime_type,
                				new_package_id,
                				one_news.archive_date,
                				one_news.approval_user,
                				one_news.approval_date,
                				one_news.approval_ip,
                				one_news.creation_date,
                				one_news.creation_ip,
                				one_news.creation_user
            );

        end loop;
 return 0;
end;
' language 'plpgsql';

-- added for openacs.org

create or replace function news__status (integer)
returns varchar as '
declare
    p_news_id alias for $1;
    v_archive_date timestamptz;
    v_publish_date timestamptz;
begin
    -- populate variables
    select archive_date into v_archive_date 
    from   cr_news 
    where  news_id = p_news_id;
    --
    select publish_date into v_publish_date
    from   cr_revisions
    where  revision_id = p_news_id;
    
    -- if publish_date is not null the item is approved, otherwise it is not
    if v_publish_date is not null then
        if v_publish_date > current_timestamp  then
            -- to be published (2 cases)
            -- archive date could be null if it has not been decided when to archive
	    -- RAL: the nasty ''extract'' code below was the only way I could figure
	    -- to get the same result as Oracle (eg, 2.4 days)
            if v_archive_date is null then 
                return ''going live in ''
                || to_char(extract(days from (v_publish_date - current_timestamp))
	    + extract(hours from (v_publish_date - current_timestamp))/24,''999D9'')
	    || '' days'';
            else 
                return ''going live in ''
                || to_char(extract(days from (v_publish_date - current_timestamp))
		+ extract(hours from (v_publish_date - current_timestamp))/24,''999D9'')
		|| '' days'' || '', archived in ''
                || to_char(extract(days from (v_archive_date - current_timestamp))
		+ extract(hours from (v_archive_date - current_timestamp))/24,''999D9'')
                || '' days'';
            end if;  
        else
            -- already released or even archived (3 cases)
            if v_archive_date is null then
                 return ''published, not scheduled for archive'';
            else
                if v_archive_date - current_timestamp > 0 then
                     return ''published, archived in ''
		     || to_char(extract(days from (v_archive_date - current_timestamp))
		     + extract(hours from (v_archive_date - current_timestamp))/24,''999D9'')
		     || '' days'';
                else 
                    return ''archived'';
                end if;
             end if;
        end if;     
    else 
        return ''unapproved'';
    end if;
end;
' language 'plpgsql';


create view news_items_live_or_submitted
as 
select
    ci.item_id as item_id,
    cn.news_id,
    cn.package_id,
    cr.publish_date,
    cn.archive_date,
    cr.title as publish_title,
    cr.content as publish_body,
    (case when cr.mime_type = 'text/html' then 't' else 'f' end) as html_p,
    ao.creation_user,
    ps.first_names || ' ' || ps.last_name as item_creator,
    ao.creation_date::date as creation_date,
    ci.live_revision,
    news__status(cn.news_id) as status
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
