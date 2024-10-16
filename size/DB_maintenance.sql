-- Show DB sizes:

SELECT DB_NAME(database_id) AS database_name, 
    type_desc, 
    name AS FileName, 
	size/128.0 as size,
    FORMAT(size/128.0, 'N2') AS CurrentSizeMB
FROM sys.master_files
WHERE database_id > 6 AND type IN (0,1)

order by 4 desc

-------------------------------------------------

use master ;
go
CHECKPOINT;
GO
DBCC DROPCLEANBUFFERS;
GO
-- Execute the DBCC FREEPROCCACHE command to clear the procedural cache
DBCC FREEPROCCACHE;
GO


-- use the proper DB
USE tempdb;
GO
-- sync
CHECKPOINT; 
GO
-- drop buffers
DBCC DROPCLEANBUFFERS; 
DBCC FREEPROCCACHE;
DBCC FREESYSTEMCACHE('ALL');
DBCC FREESESSIONCACHE;
GO
--shrink db (file_name, size_in_MB)
DBCC SHRINKFILE (TEMPDEV, 1024);
GO


use tempdb
go
select size, (size*8) as FileSizeKB from sys.database_files


-- Execute the DBCC DROPCLEANBUFFERS command to flush cached indexes and data pages
CHECKPOINT;
GO
DBCC DROPCLEANBUFFERS;
GO
-- Execute the DBCC FREEPROCCACHE command to clear the procedural cache
DBCC FREEPROCCACHE;
GO


DBCC SHRINKFILE (AdventureWorks2012_log, 1)

--Replace AdventureWorks2012_log with the logical name of the log file you need shrunk 
--and change 1 to the number of MB you want the log file shrunk to.

--If the database is in FULL recovery model you could set it to SIMPLE, 
-- run DBCC SHRINKFILE, and set back to FULL if you don’t care about losing the data in the log.

        ALTER DATABASE AdventureWorks2012 SET RECOVERY SIMPLE
        GO
        DBCC SHRINKFILE (AdventureWorks2012_log, 1)
        GO
        ALTER DATABASE AdventureWorks2012 SET RECOVERY FULL
        
--**You can find the logical name of the log file by using the following query:

        SELECT name FROM sys.master_files WHERE type_desc = 'LOG'
        
--Another option to shrink the log using the FULL recovery model is to backup the log for your database 
--using the BACKUP LOG statement and then issue the SHRINKFILE command to shrink the transaction log:

        BACKUP LOG AdventureWorks2012 TO BackupDevice


-----------------------------------
-- Tables Per Database


CREATE TABLE #SpaceUsed (
	 TableName sysname
	,NumRows BIGINT
	,ReservedSpace VARCHAR(50)
	,DataSpace VARCHAR(50)
	,IndexSize VARCHAR(50)
	,UnusedSpace VARCHAR(50)
	) 

DECLARE @str VARCHAR(500)
SET @str =  'exec sp_spaceused ''?'''
INSERT INTO #SpaceUsed 
EXEC sp_msforeachtable @command1=@str

SELECT * FROM #SpaceUsed ORDER BY TableName

SELECT * FROM #SpaceUsed ORDER BY ReservedSpace desc

SELECT TableName, NumRows, 
CONVERT(numeric(18,0),REPLACE(ReservedSpace,' KB','')) / 1024 as ReservedSpace_MB,
CONVERT(numeric(18,0),REPLACE(DataSpace,' KB','')) / 1024 as DataSpace_MB,
CONVERT(numeric(18,0),REPLACE(IndexSize,' KB','')) / 1024 as IndexSpace_MB,
CONVERT(numeric(18,0),REPLACE(UnusedSpace,' KB','')) / 1024 as UnusedSpace_MB
FROM #SpaceUsed
ORDER BY ReservedSpace_MB desc

drop table #SpaceUsed


-----------------------------------

go


IF OBJECT_ID('tempdb..#SpaceUsed') IS NOT NULL
	DROP TABLE #SpaceUsed

CREATE TABLE #SpaceUsed (
	 TableName sysname
	,NumRows BIGINT
	,ReservedSpace VARCHAR(50)
	,DataSpace VARCHAR(50)
	,IndexSize VARCHAR(50)
	,UnusedSpace VARCHAR(50)
	) 

DECLARE @str VARCHAR(500)
SET @str =  'exec sp_spaceused ''?'''
INSERT INTO #SpaceUsed 
EXEC sp_msforeachtable @command1=@str

SELECT TableName, NumRows, 
CONVERT(numeric(18,0),REPLACE(ReservedSpace,' KB','')) / 1024 as ReservedSpace_MB,
CONVERT(numeric(18,0),REPLACE(DataSpace,' KB','')) / 1024 as DataSpace_MB,
CONVERT(numeric(18,0),REPLACE(IndexSize,' KB','')) / 1024 as IndexSpace_MB,
CONVERT(numeric(18,0),REPLACE(UnusedSpace,' KB','')) / 1024 as UnusedSpace_MB
FROM #SpaceUsed
ORDER BY ReservedSpace_MB desc



-----------------------------------
go


	
SELECT DB_NAME(database_id) AS database_name, 
    type_desc, 
    name AS FileName, 
    FORMAT(size/128.0, 'N2') AS CurrentSizeMB,
	size
FROM sys.master_files
WHERE database_id > 6 AND type IN (0,1)
order by 4 desc

	
SELECT DB_NAME() AS DbName, 
    name AS FileName, 
    type_desc,
    FORMAT(size/128.0, 'N2') AS CurrentSizeMB,  
    size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0 AS FreeSpaceMB
FROM sys.database_files
WHERE type IN (0,1);



CREATE TABLE #FileSize
(dbName NVARCHAR(128), 
    FileName NVARCHAR(128), 
    type_desc NVARCHAR(128),
    CurrentSizeMB DECIMAL(10,2), 
    FreeSpaceMB DECIMAL(10,2)
);
    
INSERT INTO #FileSize(dbName, FileName, type_desc, CurrentSizeMB, FreeSpaceMB)
exec sp_msforeachdb 
'use [?]; 
 SELECT DB_NAME() AS DbName, 
        name AS FileName, 
        type_desc,
        FORMAT(size/128.0, 'N2') AS CurrentSizeMB,  
        size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0 AS FreeSpaceMB
FROM sys.database_files
WHERE type IN (0,1);';
    
SELECT * 
FROM #FileSize 
WHERE dbName NOT IN ('distribution', 'master', 'model', 'msdb')
--AND FreeSpaceMB > ?;
    
DROP TABLE #FileSize;




-----------------------------------

SELECT name AS [Database Name], recovery_model_desc AS [Recovery Model] FROM sys.databases
GO


SELECT 'ADVENTUREWORKS' AS [Database Name], DATABASEPROPERTYEX('ADVENTUREWORKS', 'RECOVERY') AS [Recovery Model]
GO



-- How to change the recovery model of entire databases of SQL Server instance?

-- one DB only:
SELECT 'BOG' AS [Database Name], DATABASEPROPERTYEX('BOG', 'RECOVERY') AS [Recovery Model]
GO

-- all dbs
SELECT name AS [Database Name], recovery_model_desc AS [Recovery Model] 
FROM sys.databases
order by 2
GO

SELECT name, recovery_model,recovery_model_desc FROM sys.databases  
GO 

USE master
GO
ALTER DATABASE MODEL SET RECOVERY SIMPLE ;  
SELECT name, recovery_model,recovery_model_desc FROM sys.databases  where name='model'

-- How to change the recovery model of entire databases of SQL Server instance?
-- The undocumented stored procedure, sp sp_msforeachdb, 
-- is used to iterate through every database and execute the alter database command.
	
EXEC sp_msforeachdb "
IF '?' not in ('tempdb')
begin
    exec ('ALTER DATABASE [?] SET RECOVERY FULL;')
    print '?'
end
"
 
SELECT name, recovery_model,recovery_model_desc FROM sys.databases

-------------------------------------------------


select * FROM sys.databases
select [name] FROM sys.databases where is_auto_shrink_on = 0


	--Enable Auto Shrink for the database AdventureWorks
	ALTER DATABASE AdventureWorks SET AUTO_SHRINK ON
	GO
	--Disable Auto Shrink for the database AdventureWorks
	ALTER DATABASE AdventureWorks SET AUTO_SHRINK OFF
	GO

--This query will return a listing of all files in all databases on a SQL instance:

EXEC sp_MSforeachdb 'ALTER DATABASE ? SET AUTO_SHRINK ON'
EXEC sp_MSforeachdb 'USE ? CHECKPOINT; DBCC DROPCLEANBUFFERS; DBCC FREEPROCCACHE; '


SELECT DB_NAME() AS DbName, 
name AS FileName, 
FORMAT(size/128.0, 'N2') AS CurrentSizeMB,  
size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0 AS FreeSpaceMB 
FROM sys.database_files; 


DBCC SHRINKFILE(file_name, 5120);
GO


--This query will return a listing of all tables in all databases on a SQL instance: 
DECLARE @command varchar(1000) 
SELECT @command = 'USE ? SELECT name FROM sysobjects WHERE xtype = ''U'' ORDER BY name' 
EXEC sp_MSforeachdb @command 

--This query will return a listing of all tables in all databases on a SQL instance: 
EXEC sp_MSforeachdb 'USE ? SELECT name FROM sysobjects WHERE xtype = ''U'' ORDER BY name' 

go
--This statement creates a stored procedure in each user database that will return a listing of all users in a database, sorted by their modification date 
DECLARE @command varchar(1000) 
SELECT @command = 'IF ''?'' NOT IN(''master'', ''model'', ''msdb'', ''tempdb'') BEGIN USE ? 
   EXEC(''CREATE PROCEDURE pNewProcedure1 AS SELECT name, createdate, updatedate FROM sys.sysusers ORDER BY updatedate DESC'') END' 
EXEC sp_MSforeachdb @command 
go



-----------------------------------------------

use master

DBCC SHRINKFILE ( master, 1)
DBCC SHRINKFILE ( mastlog, 1)
DBCC SHRINKFILE ( model, 1)
DBCC SHRINKFILE ( modellog, 1)
DBCC SHRINKFILE ( tempdb, 1)
DBCC SHRINKFILE ( templog, 1)

DBCC SHRINKFILE ( MSDBData, 1)
DBCC SHRINKFILE ( MSDBLog, 1)
GO

DBCC SHRINKFILE (careerdb_log, 1)
DBCC SHRINKFILE (careerdb, 1)

GO

DBCC SHRINKFILE ( BOG, 1)
DBCC SHRINKFILE ( BOG_log, 1)
DBCC SHRINKFILE ( BlueOrGreen_dev, 1)
DBCC SHRINKFILE ( BlueOrGreen_dev_log, 1)
DBCC SHRINKFILE ( DataIntegration, 1)
DBCC SHRINKFILE ( DataIntegration_log, 1)
DBCC SHRINKFILE ( Logging, 1)
DBCC SHRINKFILE ( Logging_log, 1)

GO



/*
Method 2: Use the DBCC SHRINKDATABASE command
	Use the DBCC SHRINKDATABASE command to shrink the tempdb database. 
	DBCC SHRINKDATABASE receives the parameter target_percent. 
	This is the desired percentage of free space left in the database file after the database is shrunk. 
	If you use DBCC SHRINKDATABASE, you may have to restart SQL Server.

    Determine the space that is currently used in tempdb by using the sp_spaceused stored procedure. 
	Then, calculate the percentage of free space that is left for use as a parameter to DBCC SHRINKDATABASE. 
	This calculation is based on the desired database size.
    Note In some cases, you may have to execute sp_spaceused @updateusage=true 
	to recalculate the space that is used and to obtain an updated report. 
	Refer to SQL Server Books Online for more information about the sp_spaceused stored procedure.

	sp_spaceused

    Consider the following example:
    Assume that tempdb has two files: 
		the primary data file (Tempdb.mdf) that is 100 MB 
		and the log file (Tempdb.ldf) that is 30 MB. 
	
	Assume that sp_spaceused reports that the primary data file contains 60 MB of data. 
	Also, assume that you want to shrink the primary data file to 80 MB. 
	Calculate the desired percentage of free space left after the shrink: 80 MB - 60 MB = 20 MB. 
	Now, divide 20 MB by 80 MB = 25 percent, and that is yourtarget_percent. 
	
	The transaction log file is shrunk accordingly, leaving 25 percent or 20 MB of space free after the database is shrunk.
    
	Connect to SQL Server by using Query Analyzer, and then run the following Transact-SQL commands:

       dbcc shrinkdatabase (tempdb, 'target percent') 
       -- This command shrinks the tempdb database

	There are limitations for use of the DBCC SHRINKDATABASE command on the tempdb database. 
	The target size for data and log files cannot be smaller than the size that is specified 
	when the database was created or smaller than the last size that was explicitly set by using a
	file-size-changing operation such as ALTER DATABASE that uses the MODIFY FILE option or the command.
	Another limitation of BCC SHRINKDATABASE is the calculation of the target_percentage parameter 
	and its dependency on the current space that is used.

Method 3: Use the DBCC SHRINKFILE command
	Use the DBCC SHRINKFILE command to shrink the individual tempdb files. 
	DBCC SHRINKFILE provides more flexibility than DBCC SHRINKDATABASE because you can use it 
	on a single database file without affecting other files that belong to the same database. 
	DBCC SHRINKFILE receives the target size parameter. This is the desired final size for the database file.

    Determine the desired size for the primary data file (tempdb.mdf), the log file (templog.ldf),
	and additional files that are added to tempdb. Make sure that the space that is used in the files 
	is less than or equal to the desired target size.
    Connect to SQL Server by using Query Analyzer, and then run the following Transact-SQL commands 
	for the specific database files that you want to shrink:

       use tempdb
       go

       dbcc shrinkfile (tempdev, 'target size in MB')
       go
       -- this command shrinks the primary data file

       dbcc shrinkfile (templog, 'target size in MB')
       go
       -- this command shrinks the log file, examine the last paragraph.

	An advantage of DBCC SHRINKFILE is that it can reduce the size of a file to a size that	is smaller than its original size. 
	You can issue DBCC SHRINKFILE on any of the data or log files. 
	A limitation of DBCC SHRINKFILE is that you cannot make the database smaller than the size of the model database. 

*/
 

