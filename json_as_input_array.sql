drop database if exists json_as_input_array;
create database json_as_input_array;

use json_as_input_array;

create table measure(
  measure_id serial primary key,
  object_id bigint unsigned not null,
  position_id bigint unsigned not null,
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
  (object_id, position_id, efficiency_A, efficiency_B) values
  (10, 34, 90.3, null);



delimiter //
create procedure insert_measure(
    in in_object_id bigint unsigned, 
    in in_position_id bigint unsigned,
    in in_efficiency_A decimal(5,3) unsigned, 
    in in_efficiency_B decimal(5,3) unsigned 
  )
sql security invoker

begin

  update measure set is_latest = 0
  where object_id = in_object_id and
       position_id = in_position_id;

  insert into measure set
    object_id  = in_object_id, 
    position_id = in_position_id,
    efficiency_A = in_efficiency_A,
    efficiency_B = in_efficiency_B;

end;//
delimiter ;



delimiter //
create procedure array_insert(
    in in_object_id bigint unsigned, 
    in in_position_id bigint unsigned,
    in in_effA_array json, 
    in in_effB_array json 
  )
begin

  declare effA_left json default in_effA_array;
  declare effB_left json default in_effB_array;
  declare effA, effB decimal(5,3) unsigned;
  declare pos_id bigint unsigned default in_position_id;
  declare A_length smallint unsigned default json_length(in_effA_array);
  declare B_length smallint unsigned default json_length(in_effB_array);
  declare array_length smallint unsigned 
    default coalesce(A_length, B_length);
  declare A_is_null bool default in_effA_array is null;
  declare B_is_null bool default in_effB_array is null;

  declare exit handler for sqlexception
  begin
    rollback;
    resignal;
  end;
  
  
  if A_is_null and B_is_null then
    signal sqlstate '45000' set
    message_text = 'Both arrays are null.';
  end if;

  if A_length <> B_length and not (A_is_null or B_is_null) then
    signal sqlstate '45000' set
    message_text = 'Arrays have mismatched lengths.';
  end if;


  start transaction;

  while array_length > 0 do

    set effA = json_extract(effA_left, '$[0]'),
        effB = json_extract(effB_left, '$[0]'),
        effA_left = json_remove(effA_left, '$[0]'),
        effB_left = json_remove(effB_left, '$[0]');

    call insert_measure(in_object_id, pos_id, effA, effB);
    
    set pos_id = pos_id + 1,
        array_length = array_length - 1;

  end while; 

  commit;

end;//
delimiter ;


call array_insert(60, 101, json_array(77.3, 65.7, 74.2), null);
call array_insert(60, 103, json_array(47.3, 45.7, 44.2), null);

select efficiency_A, efficiency_B, is_latest, creation 
  from measure;
select object_id, position_id, efficiency_A, efficiency_B, is_latest 
  from measure;
