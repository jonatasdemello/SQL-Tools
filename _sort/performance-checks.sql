-- https://www.wardyit.com/blog/5-common-causes-sql-server-performance-problems/

-------------------------------------------------------------------------------------------------------------------------------
-- Check your most expensive queries and stored procedures.

SELECT
	TOP 10 SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
	((CASE qs.statement_end_offset
		WHEN -1 THEN DATALENGTH(qt.TEXT)
		ELSE qs.statement_end_offset
		END - qs.statement_start_offset)/2)+1),
	qs.execution_count,
	qs.total_logical_reads, qs.last_logical_reads,
	qs.total_logical_writes, qs.last_logical_writes,
	qs.total_worker_time,
	qs.last_worker_time,
	qs.total_elapsed_time/1000000 total_elapsed_time_in_S,
	qs.last_elapsed_time/1000000 last_elapsed_time_in_S,
	qs.last_execution_time,
	qp.query_plan
FROM 
	sys.dm_exec_query_stats qs
	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
	CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY
	qs.total_logical_reads DESC -- logical reads
	-- ORDER BY qs.total_logical_writes DESC -- logical writes
	-- ORDER BY qs.total_worker_time DESC -- CPU time

-------------------------------------------------------------------------------------------------------------------------------
--This script will help you identify missing indexes:

SELECT
	migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) AS improvement_measure,
	'CREATE INDEX [missing_index_' + CONVERT (varchar, mig.index_group_handle) + '_' + CONVERT (varchar, mid.index_handle)
	+ '_' + LEFT (PARSENAME(mid.statement, 1), 32) + ']'
	+ ' ON ' + mid.statement
	+ ' (' + ISNULL (mid.equality_columns,'')
    + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END
    + ISNULL (mid.inequality_columns, '')
	+ ')'
	+ ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement,
	migs.*, mid.database_id, mid.[object_id]
FROM
	sys.dm_db_missing_index_groups mig
	INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
	INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
WHERE
	migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) > 10
ORDER BY
	migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) DESC
	
	
--And this script will find poor performing indexes:

/*============================================================================
  File:     Index - Rarely Used Indexes
  Summary:  Sample stored procedure that lists rarely-used indexes. Because the number and type of accesses are 
		tracked in dmvs, this procedure can find indexes that are rarely useful. Because the cost of these indexes 
		is incurred during maintenance (e.g. insert, update, and delete operations), the write costs of rarely-used 
		indexes may outweigh the benefits.
		sp_help tblPasswordHistory
		sp_helptext fnt_currency_user
		select top 10 * from tblPasswordHistory
  
  Date:     2008
  Versions: 2005, 2008, 2012
------------------------------------------------------------------------------
  Written by Ben DeBow, SQLHA
	
  For more scripts and sample code, check out 
    http://www.SQLHA.com
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

/* Create a temporary table to hold our data, since we're going to iterate through databases */
IF OBJECT_ID('tempdb..#Results') IS NOT NULL
    DROP TABLE #Results;
 
CREATE TABLE [dbo].#Results(
	[Server Name] [nvarchar](128) NULL,
	[DB Name] [nvarchar](128) NULL,
	[source] [varchar](10) NOT NULL,
	[objectname] [nvarchar](128) NULL,
	[object_id] [int] NOT NULL,
	[indexname] [sysname] NULL,
	[data_compression] [varchar](24) NOT NULL,
	[index_id] [int] NOT NULL,
	[rowcnt] [bigint] NULL,
	[datapages] [bigint] NULL,
	[is_unique] [bit] NULL,
	[count] [int] NULL,
	[user_seeks] [bigint] NOT NULL,
	[user_scans] [bigint] NOT NULL,
	[user_lookups] [bigint] NOT NULL,
	[user_updates] [bigint] NOT NULL,
	[total_usage] [bigint] NOT NULL,
	[%Reads] [bigint] NULL,
	[%Writes] [bigint] NULL,
	[%Seeks] [bigint] NULL,
	[%Scans] [bigint] NULL,
	[%Lookups] [bigint] NULL,
	[%Updates] [bigint] NULL,
	[last_user_scan] [datetime] NULL,
	[last_user_seek] [datetime] NULL,
	[run_time] [datetime] NOT NULL
) ON [PRIMARY]
EXECUTE sys.sp_MSforeachdb
	'USE [?]; 
	declare @dbid int
	select @dbid = db_id()
INSERT INTO #Results
SELECT @@SERVERNAME AS [Server Name] 
	, db_name() AS [DB Name]
	, ''Usage Data'' ''source''
	, objectname=object_name(s.object_id)
	, s.object_id, indexname=i.name
	, data_compression_desc, i.index_id
	, s2.rowcnt, sa.total_pages, is_unique
	, (select count(*)
		from sys.indexes r 
		where r.object_id = s.object_id) ''count''
	, user_seeks, user_scans, user_lookups, user_updates, user_seeks + user_scans + user_lookups + user_updates AS [total_usage]
	, CAST(CAST(user_seeks + user_scans + user_lookups AS DEC(12,2))/CAST(REPLACE((user_seeks + user_scans + user_lookups + user_updates), 0, 1) AS DEC(12,2)) * 100 AS DEC(5,2)) [%Reads]
	, CAST(CAST(user_updates AS DEC(12,2))/CAST(REPLACE((user_seeks + user_scans + user_lookups + user_updates), 0, 1) AS DEC(12,2)) * 100 AS DEC(5,2)) [%Writes]
	, CAST(CAST(user_seeks AS DEC(12,2))/CAST(REPLACE((user_seeks + user_scans + user_lookups + user_updates), 0, 1) AS DEC(12,2)) * 100 AS DEC(5,2)) [%Seeks]
	, CAST(CAST(user_scans AS DEC(12,2))/CAST(REPLACE((user_seeks + user_scans + user_lookups + user_updates), 0, 1) AS DEC(12,2)) * 100 AS DEC(5,2)) [%Scans]
	, CAST(CAST(user_lookups AS DEC(12,2))/CAST(REPLACE((user_seeks + user_scans + user_lookups + user_updates), 0, 1) AS DEC(12,2)) * 100 AS DEC(5,2)) [%Lookups]
	, CAST(CAST(user_updates AS DEC(12,2))/CAST(REPLACE((user_seeks + user_scans + user_lookups + user_updates), 0, 1) AS DEC(12,2)) * 100 AS DEC(5,2)) [%Updates]
	, last_user_scan
	, last_user_seek
	, getdate() run_time
from sys.dm_db_index_usage_stats s
join sys.indexes i on i.object_id = s.object_id
	and i.index_id = s.index_id
join sysindexes s2 on i.object_id = s2.id
	and i.index_id = s2.indid
join sys.partitions sp on i.object_id = sp.object_id
	and i.index_id = sp.index_id
join sys.allocation_units sa on sa.container_id = sp.hobt_id
where objectproperty(s.object_id, ''IsUserTable'') = 1
and database_id = @dbid'

EXECUTE sys.sp_MSforeachdb
	'USE [?]; 
	declare @dbid int
	
	select @dbid = db_id()
INSERT INTO #Results
SELECT @@SERVERNAME
	, db_name()
	, ''NA''  
	, object_name(i.object_id)
	, o.object_id
	, i.name
	, data_compression_desc
	, i.index_id
	, s2.rowcnt
	, sa.total_pages
	, is_unique
	, (select count(*)
		from sys.indexes r 
		where r.object_id = i.object_id) ''count''
	, 0
	, 0
	, 0
	, 0
	, 0
	, 0
	, 0
	, 0
	, 0
	, 0
	, 0
	, 0
	, 0
	, getdate()
FROM sys.indexes i
JOIN sys.objects o
	ON i.object_id = o.object_id
join sysindexes s2 on i.object_id = s2.id
	and i.index_id = s2.indid
join sys.partitions sp on i.object_id = sp.object_id
	and i.index_id = sp.index_id
join sys.allocation_units sa on sa.container_id = sp.hobt_id
WHERE OBJECTPROPERTY(o.object_id,''IsUserTable'') = 1
    AND i.index_id NOT IN (
	SELECT s.index_id
    FROM sys.dm_db_index_usage_stats s
    WHERE  s.object_id = i.object_id
        AND i.index_id = s.index_id
        AND database_id = @dbid)
--AND i.index_id NOT IN (0,1)'

SELECT *
FROM #Results
WHERE [DB Name] NOT IN ('MASTER', 'msdb', 'MODEL', 'TEMPDB')

DROP TABLE #Results;

/*
	declare @dbid int
	select @dbid = db_id()
SELECT @@SERVERNAME AS [Server Name] 
	, db_name() AS [DB Name]
	, 'Usage Data' 'source'
	, objectname=object_name(s.object_id)
	, s.object_id
	, indexname=i.name
	, data_compression_desc
	, i.index_id
	, s2.rowcnt
	, sa.total_pages
	, is_unique
	, (select count(*)
		from sys.indexes r 
		where r.object_id = s.object_id) 'count'
	, user_seeks
	, user_scans
	, user_lookups
	, user_updates
	, user_seeks + user_scans + user_lookups + user_updates AS [total_usage]
	, CAST(CAST(user_seeks AS DEC(12,2))/CAST(REPLACE((user_seeks + user_scans + user_lookups + user_updates), 0, 1) AS DEC(12,2)) * 100 AS DEC(5,2)) [% Seeks]
	, CAST(CAST(user_scans AS DEC(12,2))/CAST(REPLACE((user_seeks + user_scans + user_lookups + user_updates), 0, 1) AS DEC(12,2)) * 100 AS DEC(5,2)) [% Scans]
	, CAST(CAST(user_lookups AS DEC(12,2))/CAST(REPLACE((user_seeks + user_scans + user_lookups + user_updates), 0, 1) AS DEC(12,2)) * 100 AS DEC(5,2)) [% Lookups]
	, CAST(CAST(user_updates AS DEC(12,2))/CAST(REPLACE((user_seeks + user_scans + user_lookups + user_updates), 0, 1) AS DEC(12,2)) * 100 AS DEC(5,2)) [% Updates]
	, last_user_scan
	, last_user_seek
	, getdate() run_time
from sys.dm_db_index_usage_stats s
join sys.indexes i on i.object_id = s.object_id
	and i.index_id = s.index_id
join sysindexes s2 on i.object_id = s2.id
	and i.index_id = s2.indid
join sys.partitions sp on i.object_id = sp.object_id
	and i.index_id = sp.index_id
join sys.allocation_units sa on sa.container_id = sp.hobt_id
where objectproperty(s.object_id, 'IsUserTable') = 1
and database_id = @dbid 
--and 'etblHistory' = object_name(s.object_id)
UNION ALL
SELECT @@SERVERNAME AS [Server Name] 
	, db_name() AS [DB Name]
	, 'NA'  
	, objectname = object_name(o.object_id)
	, o.object_id
	, indexname = i.name
	, i.index_id
	, s2.rowcnt
	, sa.total_pages
	, is_unique
	, data_compression_desc
	, (select count(*)
		from sys.indexes r 
		where r.object_id = i.object_id) 'count'
	, 0
	, 0
	, 0
	, 0
	, 0
	, 0
	, 0
	, 0
	, 0
	, 0
	, 0
	, getdate() run_time
FROM sys.indexes i
JOIN sys.objects o
	ON i.object_id = o.object_id
join sysindexes s2 on i.object_id = s2.id
	and i.index_id = s2.indid
join sys.partitions sp on i.object_id = sp.object_id
	and i.index_id = sp.index_id
join sys.allocation_units sa on sa.container_id = sp.hobt_id
WHERE OBJECTPROPERTY(o.object_id,'IsUserTable') = 1
    AND i.index_id NOT IN (
	SELECT s.index_id
    FROM sys.dm_db_index_usage_stats s
    WHERE  s.object_id = i.object_id
        AND i.index_id = s.index_id
        AND database_id = @dbid)
--AND i.index_id NOT IN (0,1)
order by last_user_scan, last_user_seek
*/

-------------------------------------------------------------------------------------------------------------------------------
	



-------------------------------------------------------------------------------------------------------------------------------

-- Default trace:

-- https://www.red-gate.com/simple-talk/databases/sql-server/performance-sql-server/the-default-trace-in-sql-server-the-power-of-performance-and-security-auditing/

-- How do we know that the default trace is running? We can run the following script in order to find out if the default trace is running:

	
SELECT* FROM sys.configurations WHERE configuration_id = 1568

-- If it is not enabled, how do we enable it? We can run this script in order to enable the default trace:
	
sp_configure 'show advanced options', 1;
GO
RECONFIGURE; 
GO
sp_configure 'default trace enabled', 1;
GO
RECONFIGURE;
GO

-- -- Here is a script which will list the data file growths and shrinkages:
SELECT TE.name AS [EventName]
	,T.DatabaseName
	,t.DatabaseID
	,t.NTDomainName
	,t.ApplicationName
	,t.LoginName
	,t.SPID
	,t.Duration
	,t.StartTime
	,t.EndTime
FROM sys.fn_trace_gettable(CONVERT(VARCHAR(150), (
				SELECT TOP 1 f.[value]
				FROM sys.fn_trace_getinfo(NULL) f
				WHERE f.property = 2
				)), DEFAULT) T
JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
WHERE te.name = 'Data File Auto Grow'
	OR te.name = 'Data File Auto Shrink'
ORDER BY t.StartTime;


-- -- Here is another query which will return the log growths and log shrinking.

SELECT TE.name AS [EventName]
	,T.DatabaseName
	,t.DatabaseID
	,t.NTDomainName
	,t.ApplicationName
	,t.LoginName
	,t.SPID
	,t.Duration
	,t.StartTime
	,t.EndTime
FROM sys.fn_trace_gettable(CONVERT(VARCHAR(150), (
				SELECT TOP 1 f.[value]
				FROM sys.fn_trace_getinfo(NULL) f
				WHERE f.property = 2
				)), DEFAULT) T
JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
WHERE te.name = 'Log File Auto Grow'
	OR te.name = 'Log File Auto Shrink'
ORDER BY t.StartTime;




SELECT TE.name AS [EventName]
	,T.DatabaseName
	,t.DatabaseID
	,t.NTDomainName
	,t.ApplicationName
	,t.LoginName
	,t.SPID
	,t.StartTime
	,t.TextData
	,t.Severity
	,t.Error
FROM sys.fn_trace_gettable(CONVERT(VARCHAR(150), (
				SELECT TOP 1 f.[value]
				FROM sys.fn_trace_getinfo(NULL) f
				WHERE f.property = 2
				)), DEFAULT) T
JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
WHERE te.name = 'ErrorLog'



---- Here is another script which will outline the sort and hash warnings:

	
SELECT  TE.name AS [EventName] ,
        v.subclass_name ,
        T.DatabaseName ,
        t.DatabaseID ,
        t.NTDomainName ,
        t.ApplicationName ,
        t.LoginName ,
        t.SPID ,
        t.StartTime
FROM    sys.fn_trace_gettable(CONVERT(VARCHAR(150), ( SELECT TOP 1
                                                              f.[value]
                                                      FROM    sys.fn_trace_getinfo(NULL) f
                                                      WHERE   f.property = 2
                                                    )), DEFAULT) T
        JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
        JOIN sys.trace_subclass_values v ON v.trace_event_id = TE.trace_event_id
                                            AND v.subclass_value = t.EventSubClass
WHERE   te.name = 'Hash Warning'
        OR te.name = 'Sort Warnings'

--... and finally, one more script which outlines the missing statistics and join predicates.

SELECT  TE.name AS [EventName] ,
        T.DatabaseName ,
        t.DatabaseID ,
        t.NTDomainName ,
        t.ApplicationName ,
        t.LoginName ,
        t.SPID ,
        t.StartTime
FROM    sys.fn_trace_gettable(CONVERT(VARCHAR(150), ( SELECT TOP 1
                                                              f.[value]
                                                      FROM    sys.fn_trace_getinfo(NULL) f
                                                      WHERE   f.property = 2
                                                    )), DEFAULT) T
        JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
WHERE   te.name = 'Missing Column Statistics'
        OR te.name = 'Missing Join Predicate'
		
		
---- Here is a script which will return the Full text events:

	
SELECT  TE.name AS [EventName] ,
        DB_NAME(t.DatabaseID) AS DatabaseName ,
        t.DatabaseID ,
        t.NTDomainName ,
        t.ApplicationName ,
        t.LoginName ,
        t.SPID ,
        t.StartTime ,
        t.IsSystem
FROM    sys.fn_trace_gettable(CONVERT(VARCHAR(150), ( SELECT TOP 1
                                                              f.[value]
                                                      FROM    sys.fn_trace_getinfo(NULL) f
                                                      WHERE   f.property = 2
                                                    )), DEFAULT) T
        JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
WHERE   te.name = 'FT:Crawl Started'
        OR te.name = 'FT:Crawl Aborted'
        OR te.name = 'FT:Crawl Stopped'
		
		
-- Here is a script which will give you the most recently manipulated objects in your databases.

	
SELECT  TE.name ,
        v.subclass_name ,
        DB_NAME(t.DatabaseId) AS DBName ,
        T.NTDomainName ,
        t.NTUserName ,
        t.HostName ,
        t.ApplicationName ,
        t.LoginName ,
        t.Duration ,
        t.StartTime ,
        t.ObjectName ,
        CASE t.ObjectType
          WHEN 8259 THEN 'Check Constraint'
          WHEN 8260 THEN 'Default (constraint or standalone)'
          WHEN 8262 THEN 'Foreign-key Constraint'
          WHEN 8272 THEN 'Stored Procedure'
          WHEN 8274 THEN 'Rule'
          WHEN 8275 THEN 'System Table'
          WHEN 8276 THEN 'Trigger on Server'
          WHEN 8277 THEN '(User-defined) Table'
          WHEN 8278 THEN 'View'
          WHEN 8280 THEN 'Extended Stored Procedure'
          WHEN 16724 THEN 'CLR Trigger'
          WHEN 16964 THEN 'Database'
          WHEN 16975 THEN 'Object'
          WHEN 17222 THEN 'FullText Catalog'
          WHEN 17232 THEN 'CLR Stored Procedure'
          WHEN 17235 THEN 'Schema'
          WHEN 17475 THEN 'Credential'
          WHEN 17491 THEN 'DDL Event'
          WHEN 17741 THEN 'Management Event'
          WHEN 17747 THEN 'Security Event'
          WHEN 17749 THEN 'User Event'
          WHEN 17985 THEN 'CLR Aggregate Function'
          WHEN 17993 THEN 'Inline Table-valued SQL Function'
          WHEN 18000 THEN 'Partition Function'
          WHEN 18002 THEN 'Replication Filter Procedure'
          WHEN 18004 THEN 'Table-valued SQL Function'
          WHEN 18259 THEN 'Server Role'
          WHEN 18263 THEN 'Microsoft Windows Group'
          WHEN 19265 THEN 'Asymmetric Key'
          WHEN 19277 THEN 'Master Key'
          WHEN 19280 THEN 'Primary Key'
          WHEN 19283 THEN 'ObfusKey'
          WHEN 19521 THEN 'Asymmetric Key Login'
          WHEN 19523 THEN 'Certificate Login'
          WHEN 19538 THEN 'Role'
          WHEN 19539 THEN 'SQL Login'
          WHEN 19543 THEN 'Windows Login'
          WHEN 20034 THEN 'Remote Service Binding'
          WHEN 20036 THEN 'Event Notification on Database'
          WHEN 20037 THEN 'Event Notification'
          WHEN 20038 THEN 'Scalar SQL Function'
          WHEN 20047 THEN 'Event Notification on Object'
          WHEN 20051 THEN 'Synonym'
          WHEN 20549 THEN 'End Point'
          WHEN 20801 THEN 'Adhoc Queries which may be cached'
          WHEN 20816 THEN 'Prepared Queries which may be cached'
          WHEN 20819 THEN 'Service Broker Service Queue'
          WHEN 20821 THEN 'Unique Constraint'
          WHEN 21057 THEN 'Application Role'
          WHEN 21059 THEN 'Certificate'
          WHEN 21075 THEN 'Server'
          WHEN 21076 THEN 'Transact-SQL Trigger'
          WHEN 21313 THEN 'Assembly'
          WHEN 21318 THEN 'CLR Scalar Function'
          WHEN 21321 THEN 'Inline scalar SQL Function'
          WHEN 21328 THEN 'Partition Scheme'
          WHEN 21333 THEN 'User'
          WHEN 21571 THEN 'Service Broker Service Contract'
          WHEN 21572 THEN 'Trigger on Database'
          WHEN 21574 THEN 'CLR Table-valued Function'
          WHEN 21577
          THEN 'Internal Table (For example, XML Node Table, Queue Table.)'
          WHEN 21581 THEN 'Service Broker Message Type'
          WHEN 21586 THEN 'Service Broker Route'
          WHEN 21587 THEN 'Statistics'
          WHEN 21825 THEN 'User'
          WHEN 21827 THEN 'User'
          WHEN 21831 THEN 'User'
          WHEN 21843 THEN 'User'
          WHEN 21847 THEN 'User'
          WHEN 22099 THEN 'Service Broker Service'
          WHEN 22601 THEN 'Index'
          WHEN 22604 THEN 'Certificate Login'
          WHEN 22611 THEN 'XMLSchema'
          WHEN 22868 THEN 'Type'
          ELSE 'Hmmm???'
        END AS ObjectType
FROM    [fn_trace_gettable](CONVERT(VARCHAR(150), ( SELECT TOP 1
                                                            value
                                                    FROM    [fn_trace_getinfo](NULL)
                                                    WHERE   [property] = 2
                                                  )), DEFAULT) T
        JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
        JOIN sys.trace_subclass_values v ON v.trace_event_id = TE.trace_event_id
                                            AND v.subclass_value = t.EventSubClass
WHERE   TE.name IN ( 'Object:Created', 'Object:Deleted', 'Object:Altered' )
                -- filter statistics created by SQL server                                         
        AND t.ObjectType NOT IN ( 21587 )
                -- filter tempdb objects
        AND DatabaseID <> 2
                -- get only events in the past 24 hours
        AND StartTime > DATEADD(HH, -24, GETDATE())
ORDER BY t.StartTime DESC ;


--By running the following query we will be able to track what users have been created on our SQL Server instance:

	
SELECT  TE.name AS [EventName] ,
        v.subclass_name ,
        T.DatabaseName ,
        t.DatabaseID ,
        t.NTDomainName ,
        t.ApplicationName ,
        t.LoginName ,
        t.SPID ,
        t.StartTime ,
        t.RoleName ,
        t.TargetUserName ,
        t.TargetLoginName ,
        t.SessionLoginName
FROM    sys.fn_trace_gettable(CONVERT(VARCHAR(150), ( SELECT TOP 1
                                                              f.[value]
                                                      FROM    sys.fn_trace_getinfo(NULL) f
                                                      WHERE   f.property = 2
                                                    )), DEFAULT) T
        JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
        JOIN sys.trace_subclass_values v ON v.trace_event_id = TE.trace_event_id
                                            AND v.subclass_value = t.EventSubClass
WHERE   te.name IN ( 'Audit Addlogin Event', 'Audit Add DB User Event',
                     'Audit Add Member to DB Role Event' )
        AND v.subclass_name IN ( 'add', 'Grant database access' )
		
--Now let’s audit the dropped users and logins by running the following query:

	
SELECT  TE.name AS [EventName] ,
        v.subclass_name ,
        T.DatabaseName ,
        t.DatabaseID ,
        t.NTDomainName ,
        t.ApplicationName ,
        t.LoginName ,
        t.SPID ,
        t.StartTime ,
        t.RoleName ,
        t.TargetUserName ,
        t.TargetLoginName ,
        t.SessionLoginName
FROM    sys.fn_trace_gettable(CONVERT(VARCHAR(150), ( SELECT TOP 1
                                                              f.[value]
                                                      FROM    sys.fn_trace_getinfo(NULL) f
                                                      WHERE   f.property = 2
                                                    )), DEFAULT) T
        JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
        JOIN sys.trace_subclass_values v ON v.trace_event_id = TE.trace_event_id
                                            AND v.subclass_value = t.EventSubClass
WHERE   te.name IN ( 'Audit Addlogin Event', 'Audit Add DB User Event',
                     'Audit Add Member to DB Role Event' )
        AND v.subclass_name IN ( 'Drop', 'Revoke database access' )


--The following query will give us all the failed logins contained in our default trace file:

	
SELECT  TE.name AS [EventName] ,
        v.subclass_name ,
        T.DatabaseName ,
        t.DatabaseID ,
        t.NTDomainName ,
        t.ApplicationName ,
        t.LoginName ,
        t.SPID ,
        t.StartTime ,
        t.SessionLoginName
FROM    sys.fn_trace_gettable(CONVERT(VARCHAR(150), ( SELECT TOP 1
                                                              f.[value]
                                                      FROM    sys.fn_trace_getinfo(NULL) f
                                                      WHERE   f.property = 2                   )), DEFAULT) T
        JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
        JOIN sys.trace_subclass_values v ON v.trace_event_id = TE.trace_event_id
                                            AND v.subclass_value = t.EventSubClass
WHERE   te.name IN ( 'Audit Login Failed' )
	
	
--The following query will give you only the server start event:

	
SELECT  TE.name AS [EventName] ,
        v.subclass_name ,
        T.DatabaseName ,
        t.DatabaseID ,
        t.NTDomainName ,
        t.ApplicationName ,
        t.LoginName ,
        t.SPID ,
        t.StartTime ,
        t.SessionLoginName
FROM    sys.fn_trace_gettable(CONVERT(VARCHAR(150), ( SELECT TOP 1
                                                              f.[value]
                                                      FROM    sys.fn_trace_getinfo(NULL) f
                                                      WHERE   f.property = 2
                                                    )), DEFAULT) T
        JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
        JOIN sys.trace_subclass_values v ON v.trace_event_id = TE.trace_event_id
                                            AND v.subclass_value = t.EventSubClass
WHERE   te.name IN ( 'Audit Server Starts and Stops' )

-- Yes, you read it correctly: the above query will return only the Server Start event, and never the Server Stop event. -- Here is the explanation: as I mentioned earlier, SQL Server’s default trace consists of five trace files in total, which are 20 MB each. These five trace files are rotated (‘refurbrished’ or ‘recycled’, if you like) upon several conditions: when the instance starts or when the file size reaches 20 MB. Now, let’s think about this for a second: the queries I have listed so far in this article are returning the results only from the current trace file, i.e. the most recent one. Further, since the default trace file is rolled over every time the instance starts, this means that the event indicating the Server Stop will remain in the previous default trace file. Put simply, after the SQL Service restarts, our current default trace file will have the Server Start event as a first row. If you really wish to know when your SQL Server instance was stopped, you will need to include at least the contents of the previous file, but in fact we can include the contents of the other four default trace files to our result set. We can do this by changing the way we call sys.fn_trace_gettable so that it appends all default trace files. This function accepts 2 parameters – file location and name and number of files; if we pass as the first parameter the file location and the name of the oldest default trace file, then the sysfn_trace_gettable will append the newest ones, as long as we specify the appropriate value for the second parameter (the number of files). If we specify the newest file as a parameter to the function (as it is the case in all scripts in this article) then the older files will not be appended. As the filename contains the index of the file and they increment as each new file is created, it is easy to calculate the name of the oldest file.

-- To find the exact file location of the default trace files, you just need to execute the following query:

	
SELECT  REVERSE(SUBSTRING(REVERSE(path), CHARINDEX('\', REVERSE(path)), 256)) AS DefaultTraceLocation
FROM    sys.traces
WHERE   is_default = 1

The following query will tell us when the memory use has changed:

	
SELECT  TE.name AS [EventName] ,
        v.subclass_name ,
        t.IsSystem
FROM    sys.fn_trace_gettable(CONVERT(VARCHAR(150), ( SELECT TOP 1
                                                              f.[value]
                                                      FROM    sys.fn_trace_getinfo(NULL) f
                                                      WHERE   f.property = 2
                                                    )), DEFAULT) T
        JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
        JOIN sys.trace_subclass_values v ON v.trace_event_id = TE.trace_event_id
                                            AND v.subclass_value = t.EventSubClass
WHERE   te.name IN ( 'Server Memory Change' )


