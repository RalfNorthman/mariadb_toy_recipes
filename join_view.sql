drop database if exists toy_recipes;
create database toy_recipes;

use toy_recipes;

create or replace table geometry
(
  geometry_id serial primary key,
  name varchar(127) not null,
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
      on update restrict,
  constraint unique_coordinates 
      unique unique_coords_index (geometry_id, x, y),
  constraint unique_point_nrs 
      unique unique_nrs_index (geometry_id, point_nr)
);

create or replace table optical
(
  optical_id serial primary key,
  wavelength smallint unsigned not null,
  diffraction_order tinyint not null,
  deviation tinyint unsigned not null,
  polarisation enum('TE', 'TM') not null,
  creation_time datetime default current_timestamp,
  constraint unique_optical_properties 
      unique unique_optical_properties_index
      (wavelength, diffraction_order, deviation, polarisation),
  constraint check_diff_order
      check (diffraction_order between -3 and 3)
);

create or replace table measure 
(
  measure_id serial primary key,
  grating_nr mediumint unsigned,
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
insert into geometry (name) 
  values ("Small 2x2"), ("Big 3x3");
insert into points (geometry_id, point_nr, x, y) 
  values (1, 1, 1, 2);
  values (1, 2, 2, 2);
  values (1, 3, 2, 1);
  values (1, 4, 1, 1);
  values (2, 1, 2, 6);
  values (2, 2, 4, 6);
  values (2, 3, 6, 6);
  values (2, 4, 6, 4);
  values (2, 5, 4, 4);
  values (2, 6, 2, 4);
  values (2, 7, 2, 2);
  values (2, 8, 4, 2);
  values (2, 9, 6, 2);
insert into measure (a, b, c, x) 
  values (1, 2, 3, 1993.2);

select * from measure;

create sql security invoker view only_latest_measure as
  select * from measure
  where id in 
    (select max(id) from measure group by a, b, c);

select * from only_latest_measure;
*/
