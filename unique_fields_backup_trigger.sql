use toy_recipes;

create or replace table measure 
(
  measure_id serial primary key,
  a tinyint unsigned not null,
  b tinyint unsigned not null,
  c tinyint unsigned not null,
  x double unsigned not null,
  time_created datetime(6) default current_timestamp,
  time_last_modified datetime(6) default current_timestamp
    on update current_timestamp,
  constraint unique_abc unique unique_abc_index (a, b, c)
);

create or replace table overwritten
(
  overwritten_id serial primary key,
  measure_id bigint unsigned,
  a tinyint unsigned not null,
  b tinyint unsigned not null,
  c tinyint unsigned not null,
  x double unsigned not null,
  time_created datetime(6),
  time_last_modified datetime(6),
  constraint fk_overwritten_measure
      foreign_key (measure_id) references measure (measure_id)
      on delete restrict
      on update restrict
);

delimiter //
create or replace trigger measure_backup after update on measure
for each row begin  
    insert into overwritten 
      (measure_id, a, b, c, x, time_created, time_last_modified)
    select measure_id, a, b, c, old.x, time_created, old.time_last_modified
    from measure 
    where measure_id = old.measure_id;
end;//
delimiter ;
 
insert into tinyints (a, b, c, x) values (1, 2, 3, 234.56);

insert into tinyints (a, b, c, x) values (1, 2, 3, 438.03)
  on duplicate key update x = values(x);
insert into tinyints (a, b, c, x) values (1, 2, 3, 1993.2)
  on duplicate key update x = values(x);
insert into tinyints (a, b, c, x) values (1, 2, 4, 32.57)
  on duplicate key update x = values(x);

select * from measure;
select * from overwritten;
