drop database if exists toy_recipes;
create database toy_recipes;

use toy_recipes;

create or replace table geometry
(
  geometry_id serial primary key,
  name varchar(127) not null,
  creation_time datetime default current_timestamp
);

create or replace table point 
(
  point_id serial primary key,
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
  grating_nr mediumint unsigned not null,
  point_id bigint unsigned,
  optical_id bigint unsigned,
  efficiency double unsigned not null,
  creation_time datetime default current_timestamp,
  constraint fk_measure_optical
      foreign key (optical_id) 
      references optical (optical_id)
      on delete restrict
      on update restrict,
  constraint fk_measure_point
      foreign key (point_id) 
      references point (point_id)
      on delete restrict
      on update restrict,
  constraint efficiency_under_100
      check (efficiency < 100)
);
 
insert into geometry (name) 
  values ("Small 2x2"), ("Big 3x3");
insert into point (geometry_id, point_nr, x, y) 
  values (1, 1, 1, 2),
         (1, 2, 2, 2),
         (1, 3, 2, 1),
         (1, 4, 1, 1),
         (2, 1, 2, 6),
         (2, 2, 4, 6),
         (2, 3, 6, 6),
         (2, 4, 6, 4),
         (2, 5, 4, 4),
         (2, 6, 2, 4),
         (2, 7, 2, 2),
         (2, 8, 4, 2),
         (2, 9, 6, 2);
insert into optical 
  (wavelength, diffraction_order, deviation, polarisation) 
  values ( 800, -1, 12, 'TE'),
         (1050, -1, 26, 'TE');
insert into measure (grating_nr, point_id, optical_id, efficiency)
  values (17451,  1, 2, 90.4),
         (17451,  2, 2, 91.5),
         (17451,  3, 2, 92.2),
         (17451,  4, 2, 91.8),
         (17879,  5, 1, 91.8),
         (17879,  6, 1, 92.8),
         (17879,  7, 1, 91.9),
         (17879,  8, 1, 91.3),
         (17879,  9, 1, 91.5),
         (17879, 10, 1, 93.8),
         (17879, 11, 1, 93.1),
         (17879, 12, 1, 92.5),
         (17879, 13, 1, 93.7);

select * from measure;

create sql security invoker view overview as
  select grating_nr, point_nr, x, y, wavelength, diffraction_order,
         deviation, polarisation, efficiency, name as geometry_name
  from measure as m,
       optical as o,
       point as p,
       geometry as g
  where m.point_id = p.point_id and
        m.optical_id = o.optical_id and
        p.geometry_id = g.geometry_id;

select * from overview;
