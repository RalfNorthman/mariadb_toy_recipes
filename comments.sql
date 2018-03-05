drop database if exists comments_test;
create database comments_test;

use comments_test;

create table things(
  thing_nr int unsigned primary key,
  weight_grams decimal(12,3) not null,
  creation_time datetime default current_timestamp
);

create table comment_types(
  comment_type char(20) primary key
);

create table comments(
  comment_id serial primary key,
  thing_nr int unsigned not null,
  comment_type char(20) not null,
  content tinytext not null,
  foreign key (thing_nr) references things (thing_nr)
    on delete cascade
    on update cascade,
  foreign key (comment_type) references comment_types (comment_type)
    on delete restrict
    on update cascade
);

create view joined as
  select *
  from things
  inner join comments using (thing_nr);

insert into things (thing_nr, weight_grams) values
  (14900, 23.234),
  (12401, 0.3);

insert into comment_types (comment_type) values
  ('Estetic'), ('Philosophical'), ('Factual');

insert into comments (thing_nr, comment_type, content) values
  (14900, 'Estetic', 'Painted a beautiful and rich blue.'),
  (14900, 'Factual', 'Handle made of over 80% lead.'),
  (12401, 'Philosophical', 'What would Lincoln think of it?'),
  (12401, 'Factual', '125 cm long');

insert into things set
  thing_nr = 101,
  weight_grams = 32.3;

insert into comment_types set 
  comment_type = 'Bizarre';

insert into comments set
  thing_nr = 101,
  comment_type = 'Bizarre',
  content = 'It\'s aura smells red';

select * from joined;
   
update comment_types set
  comment_type = 'Nonsensical'
  where comment_type = 'Bizarre';

select * from joined;

select comment_type, count(*) as number_of
  from comments
  group by comment_type;

select comment_type, count(*) as number_of
  from comments 
    inner join things using (thing_nr)
  where weight_grams > 1
  group by comment_type;
