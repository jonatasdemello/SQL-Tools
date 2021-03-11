/*
-- Performance
*/
-- This only return the columns (result structure) no data
SET FMTONLY ON;
SET FMTONLY OFF;

--Clear all buffers and plan cache
GO

BEGIN 
	DBCC FREEPROCCACHE;
	DBCC DROPCLEANBUFFERS;

	SET STATISTICS TIME ON;
	SET STATISTICS IO ON;


	DECLARE @StartTime DATETIME = GETDATE()

	-- ...SQL operations

	PRINT DATEDIFF(ms, @StartTime, GETDATE())
END

/*
------------------
Query > Query Options > Results > Grid > Discard results after execution
------------------
*/


-- Test Routine : ------------------------------------------------------------------------

SET NOCOUNT ON; 
-- change here:
declare @loops INT = 700
declare @ver INT = 0

-- here is OK
declare @count INT, @totalTime INT, @StartTime DateTime2, @sql varchar(3000)
-- init
SELECT @count = 0, @StartTime = SysUTCDateTime()
while @count < @loops
begin
	declare @Filters  FILTERLIST
	exec PCS.GradesWithLessonsGetByInstitutionId_v0  2, @Filters

	set @count = @count + 1
end
-- result 
set @totalTime = DateDiff(millisecond, @StartTime, SysUTCDateTime())
Print '>     script '+cast(@ver as varchar)+' run '+ cast(@count as varchar) +' x times - Time taken was ' + cast(FORMAT(@totalTime, 'N0') as varchar) + ' ms'

go 4

-- Test Routine : ------------------------------------------------------------------------


if not exists(select * from sys.tables where [name] = 'tmpPerformance')
begin
	-- drop table tmpPerformance 
	create table tmpPerformance 
	(
		ScriptId int identity(1,1) primary key not null,
		sVersion Int,
		sName varchar(500),
		sParam varchar(255),
		sFlag varchar(255),
		sLoop int,
		sRunTime int,
	)
end




--------------------------------------------------------------------------

EXEC dbo.ProvisionSproc 'dbo', 'PerformanceTest';
GO

ALTER PROCEDURE dbo.PerformanceTest
(
	@loops INT,
	@ver INT,
	@scriptName varchar(255),
	@param varchar(500),
	@flag varchar(255)
)
AS
BEGIN

SET NOCOUNT ON; 

declare @count INT, @totalTime INT, @StartTime DateTime2, @sql varchar(3000)

SET @sql ='exec '+ @scriptName +' '+ @param 

set @count = 0
set @StartTime = SysUTCDateTime()

while @count < @loops
begin
	EXEC (@SQL)
	set @count = @count + 1
end

set @totalTime = DateDiff(millisecond, @StartTime, SysUTCDateTime())
Print '>     script '+cast(@ver as varchar)+' run '+ cast(@count as varchar) +' x times - Time taken was ' + cast(FORMAT(@totalTime, 'N0') as varchar) + ' ms'
insert into tmpPerformance (sVersion, sName, sParam, sFlag, sLoop, sRunTime)  VALUES (@ver, @scriptName, @param, @flag, @loops, @totalTime)

END
go


-------------------------------------------------------
-- Test starts here
-------------------------------------------------------
declare @loops INT = 100
declare @ver INT = 2

declare @scriptName varchar(255) = 'School.GroupGetByInstitutionId_AllPublic_v'
declare @param varchar(500) = '250711, 466, 1, 1'
declare @flag varchar(255) = 'Discard results'

SET @scriptName = @scriptName + cast(@ver as varchar(10)) 

exec dbo.PerformanceTest @loops, @ver, @scriptName, @param, @flag


--------------------------------------------------------------------------








SELECT msc.name + CONVERT(VARCHAR(10),ROUND(RAND()*1000,0))
FROM msdb.sys.objects mso (NOLOCK)
CROSS JOIN msdb.sys.columns msc (NOLOCK)



declare @count INT = 9
Declare @StartTime DateTime2 = SysUTCDateTime()
Print '> Time start ' + cast(DateDiff(millisecond, @StartTime, SysUTCDateTime()) as varchar) + 'ms'

while @count < 1000
begin
	exec School.GroupGetByInstitutionId_AllPublic  250711, 466, 1, 1
	set @count = @count + 1
end

PRINT DATEDIFF(ms, @StartTime, SysUTCDateTime())

declare @totalTime INT
set @totalTime = DateDiff(millisecond, @StartTime, SysUTCDateTime())
Print '> Time taken was ' + cast(FORMAT(@totalTime, 'N0') as varchar) + ' ms'






UPDATE Table1 SET (...) WHERE Column1='SomeValue'
IF @@ROWCOUNT=0
    INSERT INTO Table1 VALUES (...)
	

GO

	SELECT 1
	WHILE @@ROWCOUNT > 0
	BEGIN
	DELETE TOP (1000)
	FROM LargeTable
	END
	
	
	DELETE FROM 
		Student.Canvas 
	WHERE 
		PortfolioId = @PortfolioId
		AND CanvasId IN  
		(
			SELECT S.CanvasId
			FROM Spark.Storyboard S
			WHERE S.StoryboardId = @StoryboardId AND
				S.PortfolioId = @PortfolioId 
		)

--	vs

	Delete t1
	From table1 t1 
	Inner Join table2 t2 on t1.col1=t2.col2

/*
https://blog.sqlauthority.com/2010/06/05/sql-server-convert-in-to-exists-performance-talk/
https://blog.sqlauthority.com/2010/06/06/sql-server-subquery-or-join-various-options-sql-server-engine-knows-the-best/

*/
	USE AdventureWorks
	GO
	-- use of =
	SELECT *
	FROM HumanResources.Employee E
	WHERE E.EmployeeID = ( SELECT EA.EmployeeID FROM HumanResources.EmployeeAddress EA WHERE EA.EmployeeID = E.EmployeeID)
	GO
	-- use of exists
	SELECT *
	FROM HumanResources.Employee E
	WHERE EXISTS ( SELECT EA.EmployeeID FROM HumanResources.EmployeeAddress EA WHERE EA.EmployeeID = E.EmployeeID)
	GO


	USE AdventureWorks
	GO
	-- use of =
	SELECT *
	FROM HumanResources.Employee E
	WHERE E.EmployeeID = ( SELECT EA.EmployeeID FROM HumanResources.EmployeeAddress EA WHERE EA.EmployeeID = E.EmployeeID)
	GO
	-- use of in
	SELECT *
	FROM HumanResources.Employee E
	WHERE E.EmployeeID IN ( SELECT EA.EmployeeID FROM HumanResources.EmployeeAddress EA WHERE EA.EmployeeID = E.EmployeeID)
	GO
	-- use of exists
	SELECT *
	FROM HumanResources.Employee E
	WHERE EXISTS ( SELECT EA.EmployeeID FROM HumanResources.EmployeeAddress EA WHERE EA.EmployeeID = E.EmployeeID)
	GO
	-- Use of Join
	SELECT *
	FROM HumanResources.Employee E INNER JOIN HumanResources.EmployeeAddress EA ON E.EmployeeID = EA.EmployeeID
	GO


-- SQL: Fastest way to insert new records where one doesn’t already exist
-- http://cc.davelozinski.com/sql/fastest-way-to-insert-new-records-where-one-doesnt-already-exist
/*
# Records:                     50,000      500,000     5,000,000     50,000,000    500,000,000
1: Insert Where Not Exists     	165.0       1020.7       16283.0       170016.3       350977.7
2: Merge                       	236.3       2453.0       24807.7       255099.7       493763.0
3: Insert Except               	172.0        848.7        16173.3     [107066.3]     [222039.7]
4: Left Join                   [138.7]      [734.0]      [15426.0]     165738.7       334107.3
*/

--1) Insert Where Not Exists	
	INSERT INTO #table1 (Id, guidd, TimeAdded, ExtraData)
	SELECT Id, guidd, TimeAdded, ExtraData
	FROM #table2
	WHERE NOT EXISTS (Select Id, guidd From #table1 WHERE #table1.id = #table2.id)


-- 2) Merge	
	MERGE #table1 as [Target]
	USING  (select Id, guidd, TimeAdded, ExtraData from #table2) as [Source]
	(id, guidd, TimeAdded, ExtraData)
		on [Target].id =[Source].id
	WHEN NOT MATCHED THEN
		INSERT (id, guidd, TimeAdded, ExtraData)
		VALUES ([Source].id, [Source].guidd, [Source].TimeAdded, [Source].ExtraData);

-- 3) Insert Except	
	INSERT INTO #table1 (id, guidd, TimeAdded, ExtraData)
	SELECT id, guidd, TimeAdded, ExtraData from #table2
	EXCEPT
	SELECT id, guidd, TimeAdded, ExtraData from #table1
	
-- 4) Left Join 	
	INSERT INTO #table1 (id, guidd, TimeAdded, ExtraData)
	SELECT #table2.id, #table2.guidd, #table2.TimeAdded, #table2.ExtraData
	FROM #table2
	LEFT JOIN #table1 on #table1.id = #table2.id
	WHERE #table1.id is null



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

begin
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

END 






select name, recovery_model_desc from sys.databases

SELECT r.command, query = a.text, start_time, percent_complete,
      eta = dateadd(second,estimated_completion_time/1000, getdate())
FROM sys.dm_exec_requests r
    CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) a
 WHERE r.command IN ('BACKUP DATABASE','BACKUP LOG')
 
 
select name, is_encrypted from sys.databases


select 
	compatibility_level, snapshot_isolation_state_desc, is_read_committed_snapshot_on,
	is_auto_update_stats_on, is_auto_update_stats_async_on, delayed_durability_desc 
from sys.databases;
GO

select * from sys.database_scoped_configurations;
GO

dbcc tracestatus;
GO

select * from sys.configurations;


-- Change authentication mode (T-SQL)
USE [master]
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', 
     N'Software\Microsoft\MSSQLServer\MSSQLServer',
     N'LoginMode', REG_DWORD, 1
GO

https://docs.microsoft.com/en-us/sql/relational-databases/security/authentication-access/create-a-login?redirectedfrom=MSDN&view=sql-server-ver15

https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/change-server-authentication-mode?view=sql-server-ver15&redirectedfrom=MSDN&viewFallbackFrom=sql-server-2014

-- Create a login for SQL Server by specifying a server name and a Windows domain account name.  

CREATE LOGIN [<domainName>\<loginName>] FROM WINDOWS;  
GO  

-- Creates the user "shcooper" for SQL Server using the security credential "RestrictedFaculty"   
-- The user login starts with the password "Baz1nga," but that password must be changed after the first login.  

CREATE LOGIN shcooper   
   WITH PASSWORD = 'Baz1nga' MUST_CHANGE,  
   CREDENTIAL = RestrictedFaculty;  
GO




https://www.brentozar.com/blitz/high-virtual-log-file-vlf-count/

--Check VLFs substitute your database name below
USE <YOUR_DB>
DECLARE @vlf_count INT
DBCC LOGINFO
SET @vlf_count = @@ROWCOUNT
SELECT VLFs = @vlf_count


-- Index fragmentation
SELECT stats.index_id as id, name, avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats (DB_ID(N'[YOUR_DB]'), NULL, NULL, NULL, NULL) AS stats
    JOIN sys.indexes AS indx ON stats.object_id = indx.object_id
      AND stats.index_id = indx.index_id AND name IS NOT NULL;

RESULTS
-------------------------------
Id    name          avg_fragmentation_in_percent
-------------------------------
1 ORDERS_I1 0
2 ORDERS_I2 0
1 ORDER_LINE_I1 0.01
1 PK_STOCK95.5529819557039
1 PK_WAREHOUSE0.8


When your indexes are too fragmented, you can reorganize them with a simple ALTER script. Here is an example script that will print out the ALTER statements you can run for each of your tables’ indexes.

SELECT
'ALTER INDEX ALL ON ' + table_name + ' REORGANIZE;
GO'
FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG = 'YOUR_DB'

Choose the tables from the result set that have the highest fragmentation, and then execute those statements incrementally. Consider scheduling this or a similar script as one of your regular maintenance jobs.


dbcc updateusage (YOUR_DB) GO USE YOUR_DB
GO






Fix: Error 130: Cannot perform an aggregate function on an expression containing an aggregate or a subquery

Following statement will give the following error: “Cannot perform an aggregate function on an expression containing an aggregate or a subquery.” MS SQL Server doesn’t support it.
USE PUBS
GO
SELECT AVG(COUNT(royalty)) RoyaltyAvg
FROM dbo.roysched
GO

You can get around this problem by breaking out the computation of the average in derived tables.
USE PUBS
GO
SELECT AVG(t.RoyaltyCounts)
FROM
(
SELECT COUNT(royalty) AS RoyaltyCounts
FROM dbo.roysched
) T
GO

