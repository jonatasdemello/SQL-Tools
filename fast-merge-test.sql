
-------------------------------------------------------------------------------------------------------------------------------
-- https://cc.davelozinski.com/sql/fastest-way-to-insert-new-records-where-one-doesnt-already-exist
checkpoint
go
DBCC DROPCLEANBUFFERS
go
DBCC FREESESSIONCACHE
go
DBCC FREEPROCCACHE
go
DBCC FREESYSTEMCACHE ('ALL')
go

print '#### Started at: ' +Cast(GETDATE() as varchar)

DECLARE @counter int = 0
DECLARE @max int = 50000000
DECLARE @start datetime
DECLARE @end datetime
DECLARE @unique uniqueidentifier
DECLARE @RandomDate datetime
DECLARE @RandomGuid uniqueidentifier

DECLARE @Results TABLE (
    [Technique] varchar(50)
    ,[TotalRecords] int
    ,[TimeTaken] varchar(50)
)

--create main table
CREATE TABLE [#table1](
    [Id] int NOT NULL
    ,[guidd] uniqueidentifier  not null
    ,[TimeAdded] Datetime  null                 --just to have extra data
    ,[ExtraData] uniqueidentifier  null  --just to have extra data
CONSTRAINT [pk_table1] PRIMARY KEY CLUSTERED 
(
    [Id] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 93) ON [PRIMARY]
) ON [PRIMARY]

--create table we'll be adding data from
CREATE TABLE [#table2](
    [Id] int NOT NULL
    ,[guidd] uniqueidentifier not null
    ,[TimeAdded] datetime  null                 --just to have extra data
    ,[ExtraData] uniqueidentifier  null  --just to have extra data
CONSTRAINT [pk_table2] PRIMARY KEY CLUSTERED 
(
    [Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE= OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 93) ON [PRIMARY]
) ON [PRIMARY]

SET NOCOUNT ON

--populate the tables 
print 'Populating the temp tables: ' + CAST(GETDATE() as varchar)

WHILE (@counter <= @max)
BEGIN
    --get the unique
    SET @unique = (SELECT NEWID())
    SET @RandomDate = (SELECT GETDATE())
    SET @RandomGuid =(SELECT NEWID())
      
    --this table gets every record so we know we'll insert some
    INSERT INTO #table2 (Id, guidd, TimeAdded, ExtraData)
    VALUES (@counter, @unique, @RandomDate, @RandomGuid)

    --this table gets every other record so we know there are some to be inserted
    IF (@counter % 2 = 0)
    BEGIN
    INSERT INTO #table1 (Id, guidd, TimeAdded, ExtraData)
    VALUES (@counter, @unique, @RandomDate, @RandomGuid)
    END

    SET @counter = @counter + 1
END

print 'Finished populating the temp tables: ' + CAST(GETDATE() as varchar)

SET NOCOUNT OFF

--do the inserts to see what's fastest

--insert where not exists
SET @start = (select Getdate())
INSERT INTO #table1 (Id, guidd, TimeAdded, ExtraData)
SELECT Id, guidd, TimeAdded, ExtraData
FROM #table2
WHERE NOT EXISTS (Select Id, guidd from #table1 WHERE #table1.id = #table2.id)

SET NOCOUNT ON

SET @end = (select Getdate())
INSERT INTO @Results VALUES ('Insert Where Not Exists', @max, CAST(DATEDIFF(ms, @start, @end) as varchar))
print CAST(DATEDIFF(ms, @start, @end) as varchar) + ' milliseconds for insert where not exists'

SET NOCOUNT OFF
DELETE FROM #table1 WHERE Id % 2 = 1

--merge 
SET @start = (select Getdate())
MERGE #table1 as [Target]
USING (select Id, guidd, TimeAdded, ExtraData from #table2) as [Source] 
    (id, guidd, TimeAdded, ExtraData)
on [Target].id = [Source].id
WHEN NOT MATCHED THEN
    INSERT (id, guidd, TimeAdded, ExtraData)
    VALUES ([Source].id, [Source].guidd, [Source].TimeAdded, [Source].ExtraData);
SET NOCOUNT ON

SET @end = (select Getdate())
INSERT INTO @Results
VALUES ('Merge', @max, CAST(DATEDIFF(ms, @start, @end) as varchar))
print CAST(DATEDIFF(ms, @start, @end) as varchar) + ' milliseconds for merge'

SET NOCOUNT OFF
DELETE FROM #table1 WHERE Id % 2 = 1

--insert except
SET @start = (select Getdate())
INSERT INTO #table1 (id, guidd, TimeAdded, ExtraData)
SELECT id, guidd, TimeAdded, ExtraData from #table2
EXCEPT
SELECT id, guidd, TimeAdded, ExtraData from #table1
SET NOCOUNT ON

SET @end = (select Getdate())
INSERT INTO @Results 
VALUES ('Insert Except', @max, CAST(DATEDIFF(ms, @start, @end) as varchar))
print CAST(DATEDIFF(ms, @start, @end) as varchar) + ' milliseconds for insert except'

SET NOCOUNT OFF
DELETE FROM #table1 WHERE Id % 2 = 1

--left join
SET @start = (select Getdate())
INSERT INTO #table1 (id, guidd, TimeAdded, ExtraData)
SELECT
    #table2.id,
    #table2.guidd,
    #table2.TimeAdded,
    #table2.ExtraData
FROM #table2
LEFT JOIN #table1 on #table1.id = #table2.id
WHERE #table1.id is null
SET NOCOUNT ON

SET @end = (select Getdate())
INSERT INTO @Results 
VALUES ('Left Join', @max, CAST(DATEDIFF(ms, @start, @end) as varchar))
print CAST(DATEDIFF(ms, @start, @end) as varchar) + ' milliseconds for left join'
SET NOCOUNT OFF

drop table #table1
drop table #table2

print '#### Finished at: ' + Cast(GETDATE() as varchar)

Select * 
From @Results
Order By Technique
-------------------------------------------------------------------------------------------------------------------------------
