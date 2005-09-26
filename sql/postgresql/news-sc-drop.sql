-- /packages/news/sql/news-sc-drop.sql
--
-- @author Robert Locke (rlocke@infiniteinfo.com)
-- @created 2001-10-23
-- @cvs-id $Id$
--
-- Removes search support from news module.
--

select acs_sc_impl__delete(
	   'FtsContentProvider',		-- impl_contract_name
           'news'				-- impl_name
);
