-- creating schema 
create schema library2o24;

-- creating tables 
create table library2o24.publisher (
    [name] varchar(500),
    city varchar(500),
    [address] varchar(500),
    constraint publisher_pk primary key ([name])
);

create table library2o24.publication (
    isbn varchar(500),
    publisher_name varchar(500) not null,
    title varchar(500),
    pub_year varchar(500),
    edition varchar(500),
    genre varchar(500),
    card_catalog_num varchar(500),
    constraint publication_pk primary key (isbn),
    constraint publication_fk foreign key (publisher_name) references library2o24.publisher([name])
);

create table library2o24.author (
    name varchar(500),
    constraint author_pk primary key (name)
);

create table library2o24.written_by (
    isbn varchar(500),
    name varchar(500),
    constraint written_by_pk primary key (isbn, name),
    constraint written_by_fk1 foreign key (isbn) references library2o24.publication(isbn),
    constraint written_by_fk2 foreign key (name) references library2o24.author(name)
);

create table library2o24.branch (
    branch_id int not null,
    name varchar(500),
    [address] varchar(500),
    constraint branch_pk primary key (branch_id)
);

create table library2o24.borrower (
    borrower_id int,
    branch_id int not null,
    first_name varchar(500),
    last_name varchar(500),
    [address] varchar(500),
    phone_num varchar(500),
    account_balance varchar(500),
    constraint borrower_pk primary key (borrower_id),
    constraint borrower_home_branch_fk foreign key (branch_id) references library2o24.branch(branch_id)
);

create table library2o24.copy (
    copy_num int,
    isbn varchar(500),
    branch_id int not null,
    replace_cost_cents varchar(500),
    is_lost bit default 0,
    replacement_cost_cents int, -- extra/error
    constraint copy_pk primary key (copy_num, isbn),
    constraint copy_fk_1 foreign key (isbn) references library2o24.publication(isbn),
    constraint copy_fk_2 foreign key (branch_id) references library2o24.branch(branch_id)
);

create table library2o24.reserves (
    isbn varchar(500),
    borrower_id int,
    datetime_reserved date,
    constraint reserves_pk primary key (isbn, borrower_id),
    constraint reserves_fk_1 foreign key (isbn) references library2o24.publication(isbn),
    constraint reserves_fk_2 foreign key (borrower_id) references library2o24.borrower(borrower_id)
);

create table library2o24.loaned_to (
    copy_num int,
    isbn varchar(500),
    borrower_id int,
    borrow_date date,
    due_date date,
    return_date date,
    constraint loaned_to_pk primary key (copy_num, isbn, borrower_id, borrow_date),
    constraint loaned_to_fk foreign key (copy_num, isbn) references library2o24.copy(copy_num, isbn),
    constraint loaned_to_fk_2 foreign key (borrower_id) references library2o24.borrower(borrower_id)
);

-- inserting data into the tables
insert into library2o24.author (name)
values ('dj');

insert into library2o24.branch (branch_id, name, [address])
values ('2', 'Branch1', 'road1');

insert into library2o24.publisher ([name], city, [address])
values ('pj', 'hicksville', '1 street');

insert into library2o24.publication (isbn, publisher_name, title, pub_year, edition, genre, card_catalog_num)
values ('999999', 'pj', 'sql', '1999', '1st edition', 'comedy', '1');

insert into library2o24.written_by (isbn, name)
values ('999999', 'dj');

insert into library2o24.borrower (borrower_id, branch_id, first_name, last_name, [address], phone_num, account_balance)
values ('4', '4', 'pj', 'jp', '1place', '123321', 'shr');

insert into library2o24.copy (copy_num, isbn, branch_id, replace_cost_cents, is_lost)
values ('6', '999999', '3', '2', '0');

insert into library2o24.reserves (isbn, borrower_id, datetime_reserved)
values ('999999', '4', '1111-01-01');

insert into library2o24.loaned_to (copy_num, isbn, borrower_id, borrow_date, due_date, return_date)
values ('6', '999999', '4', '2024-04-19', '2025-09-16', '2024-05-25');

-- viewing tables 
select * from library2o24.publisher; -- select * from publisher (if there was no schema)
select * from library2o24.publication;
select * from library2o24.author;
select * from library2o24.borrower;
select * from library2o24.copy;
select * from library2o24.reserves;
select * from library2o24.loaned_to;



/* Inserting a excel dataset */



-- inserting flat_library data into tables
insert into library2o24.publisher
([name], city, [address])
select distinct publisher, publisher_city, publisher_address
from library2o24.flat_library;
insert into library2o24.publication
(isbn, publisher_name, title, pub_year, edition, genre, card_catalog_num)
select distinct isbn, publisher, title, publication_year, edition, null, card_catalog_number
from library2o24.flat_library;
insert into library2o24.author
([name])
select distinct author
from library2o24.flat_library;
insert into library2o24.written_by
(isbn, name)
select distinct isbn, publisher
from library2o24.flat_library;
insert into library2o24.branch (branch_id, name, [address])
select distinct branch_located_at, location_branch_name, location_branch_address
from library2o24.flat_library
where branch_located_at not in (select branch_id from library2o24.branch);
insert into library2o24.borrower (borrower_id, branch_id, first_name, last_name, [address], phone_num, account_balance)
select distinct fl.borrower_id, b.branch_id, fl.first_name, fl.last_name, fl.borrower_address, null, null
from library2o24.flat_library fl
inner join library2o24.branch b on fl.borrower_home_branch_id = b.branch_id;
insert into library2o24.copy (copy_num, isbn, branch_id, replace_cost_cents, is_lost)
select distinct copy_number, isbn, branch_located_at, replacement_cost_cents, null
from library2o24.flat_library;
insert into library2o24.reserves (isbn, borrower_id, datetime_reserved)
select distinct isbn, borrower_id, null
from library2o24.flat_library;
insert into library2o24.loaned_to(copy_num, isbn, borrower_id, borrow_date, due_date, return_date)
select distinct copy_number, isbn, borrower_id, borrow_date, due_date, return_date
from library2o24.flat_library;

-- creating view
create view library2o24.all_loans as
select
    lt.copy_num,
    lt.isbn,
    lt.borrower_id,
    lt.borrow_date,
    lt.due_date,
    lt.return_date,
    c.replace_cost_cents,
    c.is_lost,
    b.first_name as borrower_first_name,
    b.last_name as borrower_last_name,
    b.[address] as borrower_address,
    b.phone_num as borrower_phone_num,
    p.title as publication_title,
    p.genre as publication_genre,
    pb.[name] as publisher_name
from
    library2o24.loaned_to lt
inner join
    library2o24.copy c on lt.copy_num = c.copy_num and lt.isbn = c.isbn
inner join
    library2o24.borrower b on lt.borrower_id = b.borrower_id
inner join
    library2o24.publication p on lt.isbn = p.isbn
inner join
    library2o24.publisher pb on p.publisher_name = pb.[name];

-- printing flat_library and view
select * from library2o24.flat_library;
select * from library2o24.all_loans;

-- printing tables
select * from library2o24.publisher;
select * from library2o24.publication;
select * from library2o24.author;
select * from library2o24.borrower;
select * from library2o24.copy;
select * from library2o24.reserves;
select * from library2o24.loaned_to;
select * from library2o24.branch;
select * from library2o24.written_by;

-- deletes
-- drop view if exists library2o24.all_loans;
-- drop table if exists library2o24.publisher;
-- drop table if exists library2o24.publication;
-- drop table if exists library2o24.copy;
-- drop table if exists library2o24.author;
-- drop table if exists library2o24.branch;
-- drop table if exists library2o24.borrower;
-- drop table if exists library2o24.written_by;
-- drop table if exists library2o24.reserves;
-- drop table if exists library2o24.loaned_to;



