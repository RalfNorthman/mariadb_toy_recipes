drop database if exists toy_recipes;
create database toy_recipes;

use toy_recipes;

create or replace table geometry
(
  geometry_id serial primary key,
  name varchar(127),
  creation_time datetime default current_timestamp
);

create or replace table points 
(
  points_id serial primary key,
  geometry_id bigint unsigned,
  point_nr tinyint unsigned not null,
  x tinyint unsigned not null,
  y tinyint unsigned not null,
  creation_time datetime default current_timestamp,
  constraint fk_points_geometry
      foreign key (geometry_id) 
      references geometry (geometry_id)
      on delete restrict
      on update restrict
);

create or replace table optical
(
  optical_id serial primary key,
  a tinyint unsigned not null,
  b tinyint unsigned not null,
  c tinyint unsigned not null,
  creation_time datetime default current_timestamp
);

create or replace table measure 
(
  measure_id serial primary key,
  optical_id bigint unsigned,
  geometry_id bigint unsigned,
  efficiency double unsigned not null,
  creation_time datetime default current_timestamp,
  constraint fk_measure_optical
      foreign key (optical_id) 
      references optical (optical_id)
      on delete restrict
      on update restrict,
  constraint fk_measure_geometry
      foreign key (geometry_id) 
      references geometry (geometry_id)
      on delete restrict
      on update restrict
);
 
/*
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
*/
