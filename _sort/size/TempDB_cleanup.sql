use master

SELECT name, database_id, create_date FROM sys.databases ;  
GO  
EXEC sp_databases

SELECT
'DB_NAME' = db.name,
'FILE_NAME' = mf.name,
'FILE_TYPE' = mf.type_desc,
'FILE_PATH' = mf.physical_name
FROM
sys.databases db INNER JOIN sys.master_files mf ON db.database_id = mf.database_id
WHERE
db.state = 6 -- OFFLINE


select * from sys.databases where state_desc='OFFLINE'



select * from sys.databases;
select * from sys.database_files;

SELECT name, file_id, type_desc, size * 8 / 1024 [TempdbSizeInMB]
FROM tempdb.sys.database_files
ORDER BY type_desc DESC, file_id;

SELECT 
name, file_id, type_desc, size * 8 / 1024 [TempdbSizeInMB]
FROM sys.master_files
WHERE DB_NAME(database_id) = 'tempdb'
ORDER BY type_desc DESC, file_id 
GO

SELECT SUM(size)/128 AS [Total database size (MB)]
FROM tempdb.sys.database_files

use tempdb;

CHECKPOINT;
GO
DBCC DROPCLEANBUFFERS;
GO
DBCC FREEPROCCACHE;
GO

DBCC SHRINKDATABASE(tempdb, 10);

DBCC SHRINKFILE(tempdev, 1);

USE master;
GO
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev, SIZE=100Mb);
GO
ALTER DATABASE tempdb MODIFY FILE (NAME = templog, SIZE=100Mb);
GO

/*
DbId	FileId	CurrentSize	MinimumSize	UsedPages	EstimatedPages
2	1	22713424	1209056	3848	3224
2	2	128	96	128	96
*/
	
SELECT (SUM(unallocated_extent_page_count)*1.0/128) AS TempDB_FreeSpaceAmount_InMB
	FROM sys.dm_db_file_space_usage;
    
SELECT (SUM(version_store_reserved_page_count)*1.0/128) AS TempDB_VersionStoreSpaceAmount_InMB
	FROM sys.dm_db_file_space_usage;
    
SELECT (SUM(internal_object_reserved_page_count)*1.0/128) AS TempDB_InternalObjSpaceAmount_InMB
	FROM sys.dm_db_file_space_usage;
    
SELECT (SUM(user_object_reserved_page_count)*1.0/128) AS TempDB_UserObjSpaceAmount_InMB
	FROM sys.dm_db_file_space_usage;


CHECKPOINT;
GO
DBCC DROPCLEANBUFFERS;
GO
DBCC FREEPROCCACHE;
GO



--First part of the script
SELECT instance_name AS 'Database',
[Data File(s) Size (KB)]/1024 AS [Data file (MB)],
[Log File(s) Size (KB)]/1024 AS [Log file (MB)],
[Log File(s) Used Size (KB)]/1024 AS [Log file space used (MB)]
FROM (SELECT * FROM sys.dm_os_performance_counters
WHERE counter_name IN
('Data File(s) Size (KB)',
'Log File(s) Size (KB)',
'Log File(s) Used Size (KB)')
AND instance_name = 'tempdb') AS A
PIVOT
(MAX(cntr_value) FOR counter_name IN
([Data File(s) Size (KB)],
[LOG File(s) Size (KB)],
[Log File(s) Used Size (KB)])) AS B
GO
--
--Second part of the script
SELECT create_date AS [Creation date],
recovery_model_desc [Recovery model]
FROM sys.databases WHERE name = 'tempdb'
GO

-- To get the total database size without details, use this query:

SELECT SUM(size)/128 AS [Total database size (MB)]
FROM tempdb.sys.database_files

use tempdb;

SELECT 
(SUM(unallocated_extent_page_count)/128) AS [Free space (MB)],
SUM(internal_object_reserved_page_count)*8 AS [Internal objects (KB)],
SUM(user_object_reserved_page_count)*8 AS [User objects (KB)],
SUM(version_store_reserved_page_count)*8 AS [Version store (KB)]
FROM tempdb.sys.dm_db_file_space_usage
--database_id '2' represents tempdb
WHERE database_id = 2


-- find objects
USE <database_name>
SELECT tb.name AS [Temporary table name],
stt.row_count AS [Number of rows], 
stt.used_page_count * 8 AS [Used space (KB)], 
stt.reserved_page_count * 8 AS [Reserved space (KB)] FROM tempdb.sys.partitions AS prt 
INNER JOIN tempdb.sys.dm_db_partition_stats AS stt 
ON prt.partition_id = stt.partition_id 
AND prt.partition_number = stt.partition_number 
INNER JOIN tempdb.sys.tables AS tb 
ON stt.object_id = tb.object_id 
ORDER BY tb.name
