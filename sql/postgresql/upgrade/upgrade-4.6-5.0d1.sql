-- Internationalization of publication and archive status. Code to generate
-- a human readable publish status has been moved from the news__status plsql
-- function to a Tcl proc.
--
-- @author Peter Marklund

--- **** Recreate function. This will drop the views as well.
drop function news__status (integer) cascade;
create function news__status (timestamptz, timestamptz)
returns varchar as '
declare
    p_publish_date alias for $1;
    p_archive_date alias for $2;
begin
    if p_publish_date is not null then
        if p_publish_date > current_timestamp then
            -- Publishing in the future
            if p_archive_date is null then 
                return ''going_live_no_archive'';
            else 
                return ''going_live_with_archive'';
            end if;  
        else
            -- Published in the past
            if p_archive_date is null then
                 return ''published_no_archive'';
            else
                if p_archive_date > current_timestamp then
                     return ''published_with_archive'';
                else 
                    return ''archived'';
                end if;
            end if;
        end if;
    else
        -- publish_date null
        return ''unapproved'';
    end if;
end;
' language 'plpgsql';

-- **** Recreate views with calls to new status function
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
    news__status(cr.publish_date, cn.archive_date) as status
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

create view news_item_revisions
as 
select
    cr.item_id as item_id,
    cr.revision_id,
    ci.live_revision,
    cr.title as publish_title,
    cr.content as publish_body,
    cr.publish_date,
    cn.archive_date,
    cr.description as log_entry,
    (case when cr.mime_type = 'text/html' then 't' else 'f' end) as html_p,
    cr.mime_type as mime_type,
    cn.package_id,
    ao.creation_date::date as creation_date,
    news__status(cr.publish_date, cn.archive_date) as status,
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

create view news_item_full_active
as 
select
    ci.item_id as item_id,
    cn.package_id as package_id,
    revision_id,        
    title as publish_title,
    cr.content as publish_body,
    (case when cr.mime_type = 'text/html' then 't' else 'f' end) as html_p,
    cr.publish_date,
    cn.archive_date,
    news__status(cr.publish_date, cn.archive_date) as status,
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
    and cr.revision_id = content_item__get_latest_revision(ci.item_id)))
and cr.revision_id = cn.news_id
and ci.item_id = ao.object_id
and ao.creation_user = ps.person_id;
