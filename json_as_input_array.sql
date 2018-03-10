drop database if exists json_as_input_array;
create database json_as_input_array;

use json_as_input_array;

create table measure(
  measure_id serial primary key,
  object_id bigint unsigned not null,
  postion_id bigint unsigned not null,
  efficiency_A decimal(5,3) unsigned,
  efficiency_B decimal(5,3) unsigned,
  is_latest bool not null default 1,
  creation datetime(6) default current_timestamp,
  modification datetime(6) default current_timestamp
    on update current_timestamp,
  constraint not_both_null 
    check (not (efficiency_A is null and efficiency_B is null))
);

insert into measure 
  (object_id, postion_id, efficiency_A, efficiency_B) values
  (10, 34, 90.3, null);



delimiter //
create procedure insert_measure(
    in in_object_id bigint unsigned, 
    in in_postion_id bigint unsigned,
    in in_efficiency_A decimal(5,3) unsigned, 
    in in_efficiency_B decimal(5,3) unsigned 
  )
begin
  
  declare exit handler for sqlexception
  begin
    rollback;
    resignal;
  end;

  start transaction;

  update measure set is_latest = 0
  where object_id = in_object_id and
       postion_id = in_postion_id;

  insert into measure set
    object_id  = in_object_id, 
    postion_id = in_postion_id,
    efficiency_A = in_efficiency_A,
    efficiency_B = in_efficiency_B;

  commit;

end;//
delimiter ;

call insert_measure(10, 34, 77.3, null);
call insert_measure(10, 34, 65.7, null);
call insert_measure(10, 35, 64.9, null);
call insert_measure(11, 85, null, 87.7);
call insert_measure(11, 86, null, 86.8);
call insert_measure(11, 87, null, 87.3);

select efficiency_A, efficiency_B, is_latest, creation 
  from measure;
select object_id, postion_id, efficiency_A, efficiency_B, is_latest 
  from measure;

/*
delimiter //
create procedure insert_measure(
    in in_object_id bigint unsigned, 
    in in_postion_id bigint unsigned not null,
    in in_effA_array json, 
    in in_effB_array json 
  )
begin
  
  declare exit handler for sqlexception
  begin
    rollback;
    resignal;
  end;

  start transaction;

  update measure set is_latest = 0
  where object_id = in_object_id and
       postion_id = in_postion_id;

  insert into measure set
    object_id  = in_object_id, 
    postion_id = in_postion_id,
    effA_array = in_effA_array,
    effB_array = in_effB_array;

  commit;

end;//
delimiter ;
*/
