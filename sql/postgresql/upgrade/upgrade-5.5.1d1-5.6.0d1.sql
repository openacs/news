drop view news_items_approved;
create or replace view news_items_approved
as
select
    ci.item_id as item_id,
    cn.package_id, 
    cr.title as publish_title,
    cn.lead as publish_lead,
    cr.content as publish_body,
    cr.mime_type as publish_format,
    to_char(cr.publish_date, 'Mon dd, yyyy') as pretty_publish_date,
    cr.publish_date,
    ao.creation_user,
    ps.first_names || ' ' || ps.last_name as item_creator,
    cn.archive_date::date as archive_date    
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
-- RAL: for now, changed:
-- content.blob_to_string(cr.content) as publish_body,
-- to
-- cr.content as publish_body
--
drop view news_items_live_or_submitted;
create or replace view news_items_live_or_submitted
as 
select
    ci.item_id as item_id,
    cn.news_id,
    cn.package_id,
    cr.publish_date,
    cn.archive_date,
    cr.title as publish_title,
    cn.lead as publish_lead,
    cr.content as publish_body,
    cr.mime_type as publish_format,
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


-- View of unapproved items 
drop view news_items_unapproved;
create or replace view news_items_unapproved
as 
select      
    ci.item_id as item_id,
    cr.title as publish_title,
    cn.lead as publish_lead,
    cn.package_id as package_id,
    ao.creation_date::date as creation_date,
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
and cr.revision_id = content_item__get_live_revision(ci.item_id)
and cr.revision_id = cn.news_id
and cr.item_id = ci.item_id
and cr.publish_date is null;


-- One News Item Views
--
-- View of all revisions of a news item
-- RAL: for now, changed:
-- content.blob_to_string(cr.content) as publish_body,
-- to
-- cr.content as publish_body
--
drop view news_item_revisions;
create or replace view news_item_revisions
as 
select
    cr.item_id as item_id,
    cr.revision_id,
    ci.live_revision,
    cr.title as publish_title,
    cn.lead as publish_lead,
    cr.content as publish_body,
    cr.publish_date,
    cn.archive_date,
    cr.description as log_entry,
    cr.mime_type as publish_format,
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


-- View of a submitted news item or active revision in unapproved state
drop view news_item_unapproved;
create or replace view news_item_unapproved
as 
select
    cr.revision_id,
    ci.name as item_name,
    ps.first_names || ' ' || ps.last_name as item_creator,
    ao.creation_ip as item_creation_ip,
    ao.creation_date::date as creation_date
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
-- RAL: for now, changed:
-- content.blob_to_string(cr.content) as publish_body,
-- to
-- cr.content as publish_body
--
drop view news_item_full_active;
create or replace view news_item_full_active
as 
select
    ci.item_id as item_id,
    cn.package_id as package_id,
    revision_id,        
    cr.title as publish_title,
    cn.lead as publish_lead,
    cr.content as publish_body,
    cr.mime_type as publish_format,
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
