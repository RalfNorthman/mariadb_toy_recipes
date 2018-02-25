drop database if exists toy_recipes;
create database toy_recipes;

use toy_recipes;

create or replace table measure 
(
  id serial primary key,
  a tinyint unsigned not null,
  b tinyint unsigned not null,
  c tinyint unsigned not null,
  x double unsigned not null,
  creation_time datetime(6) default current_timestamp
);
 
insert into measure (a, b, c, x) 
  values (1, 2, 3, 234.56),
         (1, 2, 4, 32.57);
insert into measure (a, b, c, x) 
  values (1, 2, 3, 438.03);
insert into measure (a, b, c, x) 
  values (1, 2, 3, 1993.2);

select * from measure;

create sql security invoker view only_latest_measure as
  select * from measure
  where id in 
    (select max(id) from measure group by a, b, c);

select * from only_latest_measure;
