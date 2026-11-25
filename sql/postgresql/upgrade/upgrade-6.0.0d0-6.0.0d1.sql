-- Add names only to signatures verified against the current install SQL.
-- Prefix names to avoid collisions with the aliases in legacy bodies.
do $$
declare
    target record;
    definition text;
begin
    for target in
        with expected(function_name, input_types, input_names) as (
            values
            ('news__clone', 'integer,integer', 'old_package_id,new_package_id'),
            ('news__delete', 'integer', 'item_id'),
            ('news__make_permanent', 'integer', 'item_id'),
            ('news__name', 'integer', 'news_id'),
            ('news__revision_delete', 'integer', 'revision_id'),
            ('news__revision_set_active', 'integer', 'revision_id'),
            ('news__set_approve', 'integer,varchar,timestamptz,timestamptz,integer,timestamptz,varchar,boolean', 'revision_id,approve_p,publish_date,archive_date,approval_user,approval_date,approval_ip,live_revision_p'),
            ('news__status', 'timestamptz,timestamptz', 'publish_date,archive_date')
        )
        select p.oid, n.nspname, p.proname, arguments.signature
          from expected e
          join pg_proc p on p.oid = to_regprocedure(
              format('%I.%I(%s)', current_schema(), e.function_name, e.input_types))
          join pg_namespace n on n.oid = p.pronamespace
          cross join lateral (
              select string_agg(
                         format('%I %s', 'arg_' || a.arg_name, format_type(a.type_oid, null)),
                         ', ' order by a.position) as signature
                from unnest(p.proargtypes::oid[], string_to_array(e.input_names, ','))
                     with ordinality as a(type_oid, arg_name, position)
          ) arguments
         where p.prokind = 'f'
           and p.proargnames is null
           and p.proargmodes is null
           and p.pronargdefaults = 0
           and p.pronargs = cardinality(string_to_array(e.input_names, ','))
           and p.pronargs = (
               select count(*) from acs_function_args a
                where a.function = upper(e.function_name)
           )
           and not exists (
               select 1 from acs_function_args a
                where a.function = upper(e.function_name)
                  and (a.arg_seq < 1 or a.arg_seq > p.pronargs)
           )
           and e.input_names = (
               select string_agg(lower(a.arg_name), ',' order by a.arg_seq)
                 from acs_function_args a
                where a.function = upper(e.function_name)
           )
           and not exists (
               select 1 from pg_proc other
                where other.proname = p.proname
                  and other.pronargs = p.pronargs
                  and other.oid <> p.oid
           )
    loop
        definition := pg_get_functiondef(target.oid);
        execute format('CREATE OR REPLACE FUNCTION %I.%I(%s)',
                       target.nspname, target.proname, target.signature)
                || substr(definition, strpos(definition, chr(10)));
    end loop;
end;
$$;
