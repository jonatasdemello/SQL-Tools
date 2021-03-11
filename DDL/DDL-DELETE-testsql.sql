/*
SELECT
https://docs.microsoft.com/en-us/sql/t-sql/queries/select-examples-transact-sql?view=sql-server-ver15

DELETE
https://docs.microsoft.com/en-us/sql/t-sql/statements/delete-transact-sql?view=sql-server-ver15

EXISTS
https://docs.microsoft.com/en-us/sql/t-sql/language-elements/exists-transact-sql?view=sql-server-ver15

*/

-- arrange
CREATE TABLE dbo.Table1
    (ColA int PRIMARY KEY NOT NULL, ColB decimal(10,3) NOT NULL);
GO

CREATE TABLE dbo.Table2
    (ColA int PRIMARY KEY NOT NULL, ColB decimal(10,3) NOT NULL);
GO

INSERT INTO dbo.Table1 VALUES (1, 10.0);
INSERT INTO dbo.Table1 VALUES (2, 20.0);

INSERT INTO dbo.Table2 VALUES (2, 3.0);
INSERT INTO dbo.Table2 VALUES (3, 5.0);
GO

-- truncate table dbo.Table1
-- truncate table dbo.Table2

select * from dbo.Table1
select * from dbo.Table2

-- act

-- delete from Table2, records that exist in Table1
DELETE dbo.Table2
FROM dbo.Table2
    INNER JOIN dbo.Table1 ON (dbo.Table2.ColA = dbo.Table1.ColA)
    WHERE dbo.Table2.ColA = 2;

select * from dbo.Table1
select * from dbo.Table2

-- should return only row 2
select * from dbo.Table2
WHERE EXISTS ( SELECT TOP 1 1 FROM dbo.Table1 tb WHERE tb.colA = dbo.Table2.colA )

DELETE dbo.Table2
WHERE EXISTS ( SELECT TOP 1 1 FROM dbo.Table1 tb WHERE tb.colA = dbo.Table2.colA )

select * from dbo.Table1
select * from dbo.Table2


