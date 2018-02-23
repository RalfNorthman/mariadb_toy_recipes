use toy_recipes;

create or replace table tinyints 
(
  id serial primary key,
  a tinyint,
  b tinyint unsigned,
  time_created datetime(6) default current_timestamp,
  time_last_modified datetime(6) default current_timestamp
    on update current_timestamp
);

create or replace table backup 
(
  id serial primary key,
  a tinyint,
  b tinyint unsigned,
  time_created datetime(6),
  time_last_modified datetime(6)
);

delimiter //
create or replace trigger tinyints_backup after update on tinyints
for each row begin  
    insert into backup (a, b, time_created, time_last_modified)
    select old.a, old.b, old.time_created, old.time_last_modified 
    from tinyints 
    where id = old.id;
end;//
delimiter ;
 
insert into tinyints (a, b) values (-5, 5);

update tinyints set b = 10 where id = 1;
update tinyints set b = 15 where id = 1;
update tinyints set b = 20 where id = 1;

select * from tinyints;
select * from backup;
