select * from sys.change_tracking_databases

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO
SELECT
db.name AS change_tracking_db,
is_auto_cleanup_on,
retention_period,
retention_period_units_desc
FROM sys.change_tracking_databases ct
JOIN sys.databases db on
ct.database_id=db.database_id;
GO


ALTER DATABASE SISStaging3_dev SET CHANGE_TRACKING = OFF  
ALTER DATABASE SISStaging3_test SET CHANGE_TRACKING = OFF  

ALTER TABLE Person.Contact DISABLE CHANGE_TRACKING;  


select * from sys.change_tracking_databases

select * from SISStaging3_dev.sys.change_tracking_tables


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO
SELECT sc.name as tracked_schema_name,
so.name as tracked_table_name,
ctt.is_track_columns_updated_on,
ctt.begin_version /*when CT was enabled, or table was truncated */,
ctt.min_valid_version /*syncing applications should only expect data on or after this version */ ,
ctt.cleanup_version /*cleanup may have removed data up to this version */
FROM sys.change_tracking_tables AS ctt
JOIN sys.objects AS so on
ctt.[object_id]=so.[object_id]
JOIN sys.schemas AS sc on
so.schema_id=sc.schema_id;
GO


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO
SELECT
count(*) AS number_commits,
MIN(commit_time) AS minimum_commit_time,
MAX(commit_time) AS maximum_commit_time
FROM sys.dm_tran_commit_table
GO

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO
SELECT
count(*) AS number_commits,
MIN(commit_time) AS minimum_commit_time,
MAX(commit_time) AS maximum_commit_time
FROM sys.dm_tran_commit_table
GO