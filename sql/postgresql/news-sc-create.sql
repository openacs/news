-- /packages/news/sql/news-sc-create.sql
--
-- @author Robert Locke (rlocke@infiniteinfo.com)
-- @created 2001-10-23
-- @cvs-id $Id$
--
-- Adds search support to news module.
--

select acs_sc_impl__new(
	   'FtsContentProvider',		-- impl_contract_name
           'news',				-- impl_name
	   'news'				-- impl_owner_name
);

select acs_sc_impl_alias__new(
           'FtsContentProvider',		-- impl_contract_name
           'news',           			-- impl_name
	   'datasource',			-- impl_operation_name
	   'news__datasource',			-- impl_alias
	   'TCL'				-- impl_pl
);

select acs_sc_impl_alias__new(
           'FtsContentProvider',		-- impl_contract_name
           'news',           			-- impl_name
	   'url',				-- impl_operation_name
	   'news__url',				-- impl_alias
	   'TCL'				-- impl_pl
);
