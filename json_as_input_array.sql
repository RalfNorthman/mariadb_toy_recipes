drop database if exists json_as_input_array;
create database json_as_input_array;

use json_as_input_array;

create table measure(
  measure_id serial primary key,
  object_id bigint unsigned not null,
  postion_id bigint unsigned not null,
  efficiency_A decimal(5,3) unsigned,
  efficiency_B decimal(5,3) unsigned,
  is_latest bool not null,
  creation datetime(6) default current_timestamp,
  modification datetime(6) default current_timestamp
    on update current_timestamp,
  constraint not_both_null 
    check (not (efficiency_A is null and efficiency_B is null))
);

insert into measure 
  (object_id, postion_id, efficiency_A, efficiency_B, is_latest) values
  (10, 34, 90.3, null, 1);

select * from measure;

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
  where thing_nr = p_thing_nr;

  insert into weigh_ins set
    thing_nr = p_thing_nr, 
    circumstance = p_circumstance, 
    circumstance_time_sek = p_circumstance_time_sek,
    weight_grams = p_weight_grams;

  commit;

end;//
delimiter ;
*/
