DROP table if exists tb1
DROP table if exists tb2

create table tb1 (
    Tb1Id INT NOT NULL IDENTITY, --(1,1),
    Tb1Name NVARCHAR(255) NOT NULL
)
INSERT into tb1 (Tb1Name) values ('test1');
INSERT into tb1 (Tb1Name) values ('test2');
INSERT into tb1 (Tb1Name) values ('test2');
INSERT into tb1 (Tb1Name) values ('test3');
INSERT into tb1 (Tb1Name) values ('test4');

select * from tb1

-- set seed to 100
SET IDENTITY_INSERT tb1 ON;
INSERT into tb1 (Tb1id, Tb1Name) values (100, 'test-100');
SET IDENTITY_INSERT tb1 OFF;


select * from tb1
select IDENT_CURRENT('tb1');

INSERT into tb1 (Tb1Name) values ('test-after-100');

select * from tb1
select IDENT_CURRENT('tb1');

-- create a new table:
create table tb2 (
    Tb2Id INT NOT NULL IDENTITY,
    Tb2Name NVARCHAR(255) NOT NULL
)

SET IDENTITY_INSERT tb2 ON;

insert into tb2 (Tb2id, Tb2Name) 
    select Tb1Id, Tb1Name from tb1

SET IDENTITY_INSERT tb2 OFF;

select * from tb2
select IDENT_CURRENT('tb2');
