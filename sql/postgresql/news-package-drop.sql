-- drop package news

drop function news__status (timestamptz, timestamptz) cascade;
select drop_package('news');



