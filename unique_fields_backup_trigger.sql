drop database if exists toy_recipes;
create database toy_recipes;

use toy_recipes;

create or replace table measure 
(
  measure_id serial primary key,
  a tinyint unsigned not null,
  b tinyint unsigned not null,
  c tinyint unsigned not null,
  x double unsigned not null,
  time_first_measurement datetime(6) default current_timestamp,
  time_latest_measurement datetime(6) default current_timestamp
    on update current_timestamp,
  constraint unique_abc unique unique_abc_index (a, b, c)
);

create or replace table overwritten
(
  overwritten_id serial primary key,
  measure_id bigint unsigned,
  x double unsigned not null,
  time_measurement datetime(6),
  time_overwrite datetime(6),
  constraint fk_overwritten_measure
      foreign key (measure_id) references measure (measure_id)
      on delete cascade
      on update cascade
);

delimiter //
create or replace trigger measure_backup after update on measure
for each row begin  
    insert into overwritten 
      (measure_id, x, time_measurement, time_overwrite)
    select measure_id, old.x, 
      old.time_latest_measurement, new.time_latest_measurement
    from measure 
    where measure_id = old.measure_id;
end;//
delimiter ;
 
insert into measure (a, b, c, x) values (1, 2, 3, 234.56);

insert into measure (a, b, c, x) values (1, 2, 3, 438.03)
  on duplicate key update x = values(x);
insert into measure (a, b, c, x) values (1, 2, 3, 1993.2)
  on duplicate key update x = values(x);
insert into measure (a, b, c, x) values (1, 2, 4, 32.57)
  on duplicate key update x = values(x);

select * from measure;
select * from overwritten;
