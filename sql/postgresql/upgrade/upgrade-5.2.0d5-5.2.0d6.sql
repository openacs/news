-- 
-- packages/news/sql/postgresql/upgrade/upgrade-5.2.0d5-5.2.0d6.sql
-- 
-- @author Roel Canicula (roel@solutiongrove.com)
-- @creation-date 2006-02-02
-- @cvs-id $Id$
--



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
 one_news		record;	 
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
