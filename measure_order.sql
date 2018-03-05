drop database if exists measure_order;
create database measure_order;

use measure_order;

create table things(
  thing_nr int unsigned primary key
);

create table circumstances(
  circumstance char(50) primary key
);

create table weigh_ins(
  thing_nr int unsigned not null,
  circumstance char(50) not null, 
  circumstance_time_sek smallint,
  weight_grams decimal(12,3) not null,
  is_latest bool default 1,
  time_of datetime default current_timestamp,
  primary key (thing_nr, circumstance),
  foreign key (thing_nr) references things (thing_nr)
    on delete cascade
    on update cascade,
  foreign key (circumstance) references circumstances (circumstance)
    on delete restrict
    on update cascade
);

delimiter //
create procedure insert_weight (
    in p_thing_nr int,
    in p_circumstance char(50),
    in p_circumstance_time_sek smallint,
    in p_weight_grams decimal(12,3)
  )
begin
  
  declare exit handler for sqlexception
  begin
    rollback;
    resignal;
  end;

  start transaction;

  update weigh_ins set is_latest = 0
  where thing_nr = p_thing_nr;

  insert into weigh_ins set
    thing_nr = p_thing_nr, 
    circumstance = p_circumstance, 
    circumstance_time_sek = p_circumstance_time_sek,
    weight_grams = p_weight_grams;

  commit;

end;//
delimiter ;

create view joined as
  select *
  from things
  inner join weigh_ins using (thing_nr);

insert into things (thing_nr) values
  (14900),
  (12401);

insert into circumstances (circumstance) values
  ('Raw'), ('After holes drilled'), ('After bolts inserted');

call insert_weight(14900, 'Raw', null, 23.6);
call insert_weight(12401, 'Raw', null, 340);
call insert_weight(14900, 'After holes drilled', 520, 21.3);
call insert_weight(14900, 'After bolts inserted', 390, 22.9);

select * from joined;
