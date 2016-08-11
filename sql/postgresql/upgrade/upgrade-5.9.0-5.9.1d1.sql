--
-- Cleanup cr_revisions belonging to the news package, for which there
-- are no news_id in cr_news. These entries were created since ever in
-- the news package. The bug adding spurious revisions was fixed with
-- the OpenACS 5.9.0 release, this upgrade scripts removes leftovers.
--
select revision_id, content_revision__delete(revision_id) from 
  (select revision_id from cr_revisions where item_id in (
     -- return item_ids for news entries
     select distinct item_id
     from cr_revisions cr, acs_objects o
     where o.object_id = cr.revision_id and o.object_type = 'news'
   ) except select news_id from cr_news) dead_revisions;


