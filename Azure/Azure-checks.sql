-- Blocking
--The query below will display the top ten running queries that have the longest total elapsed time and are blocking other queries.

SELECT TOP 10 r.session_id, r.plan_handle, 
     r.sql_handle, r.request_id,
	 r.start_time, r.status,
	 r.command, r.database_id,
	 r.user_id, r.wait_type, 
     r.wait_time, r.last_wait_type,
	 r.wait_resource, r.total_elapsed_time,
	 r.cpu_time, r.transaction_isolation_level,
	 r.row_count, st.text
FROM sys.dm_exec_requests r
	 CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) as st
WHERE r.blocking_session_id = 0
	 and r.session_id in
	 (SELECT distinct(blocking_session_id)
	 FROM sys.dm_exec_requests)
	 GROUP BY r.session_id, r.plan_handle,
	 r.sql_handle, r.request_id,
	 r.start_time, r.status,
	 r.command, r.database_id,
	 r.user_id, r.wait_type,
	 r.wait_time, r.last_wait_type,
	 r.wait_resource, r.total_elapsed_time,
	 r.cpu_time, r.transaction_isolation_level,
	 r.row_count, st.text
	 ORDER BY r.total_elapsed_time desc

--The cause of the blocking can be poor application design, bad query plans, the lack of useful indexes, and so on.

-- This will update all the statistics on all the tables in your database.
-- remove the comments from EXEC sp_executesql in order to have the commands actually update stats, instead of just printing them.

-- Blocking
-- Slow or long-running queries can contribute to excessive resource consumption and be the consequence of blocked queries; in other words poor performance. While the concepts of blocking are the same for SQL Server and Azure SQL Database, the default isolation level is different. READ_COMMITTED_SNAPSHOT is set to on for Azure SQL Databases.

-- Blocking is an unavoidable characteristic of any relational database management system with lock-based concurrency.

-- The query below will display the top ten running queries that have the longest total elapsed time and are blocking other queries:

SELECT TOP 10 
	r.session_id,r.plan_handle,r.sql_handle,r.request_id,r.start_time, r.status,r.command, r.database_id,r.user_id, r.wait_type
	,r.wait_time,r.last_wait_type,r.wait_resource, r.total_elapsed_time,r.cpu_time, r.transaction_isolation_level,r.row_count,st.text 
FROM sys.dm_exec_requests r 
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) as st  
WHERE r.blocking_session_id = 0 and r.session_id in (SELECT distinct(blocking_session_id) FROM sys.dm_exec_requests) 
GROUP BY 
	r.session_id, r.plan_handle,r.sql_handle, r.request_id,r.start_time, r.status,r.command, r.database_id,r.user_id, r.wait_type
	,r.wait_time,r.last_wait_type,r.wait_resource, r.total_elapsed_time,r.cpu_time, r.transaction_isolation_level,r.row_count,st.text  
ORDER BY r.total_elapsed_time desc


-- Deadlock
-- A deadlock occurs when two or more processes are waiting on the same resource and each process is waiting on the other process to complete before moving forward. The query below can help you capture deadlock:

WITH CTE AS (
       SELECT CAST(event_data AS XML)  AS [target_data_XML] 
       FROM sys.fn_xe_telemetry_blob_target_read_file('dl', null, null, null)

)

SELECT 
    target_data_XML.value('(/event/@timestamp)[1]', 'DateTime2') AS Timestamp,
    target_data_XML.query('/event/data[@name=''xml_report'']/value/deadlock') AS deadlock_xml,
    target_data_XML.query('/event/data[@name=''database_name'']/value').value('(/value)[1]', 'nvarchar(100)') AS db_name
FROM CTE


-- To obtain a deadlock graph:

-- Copy the deadlock_xml column results from the previous query and load into a text file. If more than one row is returned, you will want to do each row result separately.
-- Save the file as a '.xdl' extension, (e.g. deadlock.xdl) which can be viewed in tools such as SQL Server Management Studio as a deadlock report/graph
-- If you need to customize the events you capture when a deadlock occurs, you can create your own Extended Events Session with the following events for a deadlock.

-- Lock_Deadlock: Occurs when an attempt to acquire a lock is canceled for the victim of a deadlock
-- Lock_deadlock_chain: Occurs when an attempt to acquire a lock generates a deadlock. This event is raised for each participant in the deadlock.


/*
Error 10928: Resource ID : 1: The worker limit for the database has been reached

Sessions refer to the number of concurrent connections allowed to a SQL database at a time. Workers can be thought of as the processes in the SQL database that are processing queries. The maximum number of workers allowed depends on your databases' service tier.

Azure SQL Managed Instance limits the number of concurrent workers allowed to the database.

Max concurrent workers (requests) allowed

General Purpose	Business Critical
Gen4: 210 * number of vCores + 800	Gen4: 210 * vCore count + 800
Gen5: 105 * number of vCores + 800	Gen5: 105 * vCore count + 800
You can use the sys.dm_db_resource_stats, to quickly check Maximum concurrent workers (requests) as a percentage of the limit of the database's service tier. When the worker limit is reached, clients will receive an error message (Error 10928: Resource ID : 1) and will be unable to query your database.

Recommended Steps
For an immediate solution, scale your database to a larger service tier sufficient to handle the workload.

Longer-term, you should:

	Optimize queries to reduce the resource utilization of each query if the cause of increased worker utilization is due to contention for compute resources. For more information, see Query Tuning/Hinting.
	Reduce the MAXDOP (maximum degree of parallelism) setting
	Optimize query workload to reduce number of occurrences and duration of query blocking
*/

-- Poor performance in Azure SQL Managed Instance is most often either related to excessive CPU utilization or a query waiting on a resource. There are various performance monitoring tools available for Azure SQL Databases. For analyzing High CPU usage we recommend the following:

-- TSQL
-- If the high CPU usage is happening right now:

-- Many individual queries that cumulatively consume high CPU:

PRINT '-- top 10 Active CPU Consuming Queries (aggregated)--';
SELECT TOP 10 GETDATE() runtime, *
FROM (SELECT query_stats.query_hash, SUM(query_stats.cpu_time) 'Total_Request_Cpu_Time_Ms', SUM(logical_reads) 'Total_Request_Logical_Reads', MIN(start_time) 'Earliest_Request_start_Time', COUNT(*) 'Number_Of_Requests', SUBSTRING(REPLACE(REPLACE(MIN(query_stats.statement_text), CHAR(10), ' '), CHAR(13), ' '), 1, 256) AS "Statement_Text"
    FROM (SELECT req.*, SUBSTRING(ST.text, (req.statement_start_offset / 2)+1, ((CASE statement_end_offset WHEN -1 THEN DATALENGTH(ST.text)ELSE req.statement_end_offset END-req.statement_start_offset)/ 2)+1) AS statement_text
          FROM sys.dm_exec_requests AS req
                CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) AS ST ) AS query_stats
    GROUP BY query_hash) AS t
ORDER BY Total_Request_Cpu_Time_Ms DESC;

-- Long running queries that consume CPU are still running:

PRINT '--top 10 Active CPU Consuming Queries by sessions--';
SELECT TOP 10 req.session_id, req.start_time, cpu_time 'cpu_time_ms', OBJECT_NAME(ST.objectid, ST.dbid) 'ObjectName', SUBSTRING(REPLACE(REPLACE(SUBSTRING(ST.text, (req.statement_start_offset / 2)+1, ((CASE statement_end_offset WHEN -1 THEN DATALENGTH(ST.text)ELSE req.statement_end_offset END-req.statement_start_offset)/ 2)+1), CHAR(10), ' '), CHAR(13), ' '), 1, 512) AS statement_text
FROM sys.dm_exec_requests AS req
    CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) AS ST
ORDER BY cpu_time DESC;
GO

-- If The CPU issue occurred in the past:

-- Top 15 CPU consuming queries by query hash
-- note that a query  hash can have many query id if not parameterized or not parameterized properly
-- it grabs a sample query text by min

WITH AggregatedCPU AS (SELECT q.query_hash, SUM(count_executions * avg_cpu_time / 1000.0) AS total_cpu_millisec, SUM(count_executions * avg_cpu_time / 1000.0)/ SUM(count_executions) AS avg_cpu_millisec, MAX(rs.max_cpu_time / 1000.00) AS max_cpu_millisec, MAX(max_logical_io_reads) max_logical_reads, COUNT(DISTINCT p.plan_id) AS number_of_distinct_plans, COUNT(DISTINCT p.query_id) AS number_of_distinct_query_ids, SUM(CASE WHEN rs.execution_type_desc='Aborted' THEN count_executions ELSE 0 END) AS Aborted_Execution_Count, SUM(CASE WHEN rs.execution_type_desc='Regular' THEN count_executions ELSE 0 END) AS Regular_Execution_Count, SUM(CASE WHEN rs.execution_type_desc='Exception' THEN count_executions ELSE 0 END) AS Exception_Execution_Count, SUM(count_executions) AS total_executions, MIN(qt.query_sql_text) AS sampled_query_text
                       FROM sys.query_store_query_text AS qt
                            JOIN sys.query_store_query AS q ON qt.query_text_id=q.query_text_id
                            JOIN sys.query_store_plan AS p ON q.query_id=p.query_id
                            JOIN sys.query_store_runtime_stats AS rs ON rs.plan_id=p.plan_id
                            JOIN sys.query_store_runtime_stats_interval AS rsi ON rsi.runtime_stats_interval_id=rs.runtime_stats_interval_id
                       WHERE rs.execution_type_desc IN ('Regular', 'Aborted', 'Exception')AND rsi.start_time>=DATEADD(HOUR, -2, GETUTCDATE())
                       GROUP BY q.query_hash), OrderedCPU AS (SELECT query_hash, total_cpu_millisec, avg_cpu_millisec, max_cpu_millisec, max_logical_reads, number_of_distinct_plans, number_of_distinct_query_ids, total_executions, Aborted_Execution_Count, Regular_Execution_Count, Exception_Execution_Count, sampled_query_text, ROW_NUMBER() OVER (ORDER BY total_cpu_millisec DESC, query_hash ASC) AS RN
                                                              FROM AggregatedCPU)
SELECT OD.query_hash, OD.total_cpu_millisec, OD.avg_cpu_millisec, OD.max_cpu_millisec, OD.max_logical_reads, OD.number_of_distinct_plans, OD.number_of_distinct_query_ids, OD.total_executions, OD.Aborted_Execution_Count, OD.Regular_Execution_Count, OD.Exception_Execution_Count, OD.sampled_query_text, OD.RN
FROM OrderedCPU AS OD
WHERE OD.RN<=15
ORDER BY total_cpu_millisec DESC;


-- Query Store
-- The SQL Server Query Store feature provides you with insight on query plan choice and performance. It simplifies performance troubleshooting by helping you quickly find performance differences caused by query plan changes. Query Store automatically captures a history of queries, plans, and runtime statistics, and retains these for your review.

-- You can fetch the query IDs for TOP CPU Consuming (CPU TIME ms) queries by selecting the particular metric under the regressed queries section of the Query store.

-- Up-to-date index statistics are crucial for the SQL DB query optimizer to generate optimal execution plans. Better execution plans use the right amount of resources and thus help reduce IO usage. See Maintain Azure SQL Indexes and Statistics for more information on updating statistics.

-- IO Usage is split into two types: Data IO and Log IO. You can quickly identify the IO usage using the query below:

SELECT end_time, avg_data_io_percent, avg_log_write_percent
FROM sys.dm_db_resource_stats
ORDER BY end_time DESC;
If the IO usage is above 80%, you have two options:

-- Option 1: Upgrade the compute size or service tier
-- Option 2: Identify and tune the queries consuming the most IO
-- How To identify the top IO consuming queries
-- When identifying IO performance issues, the top wait types associated with IO issues are:

-- PAGEIOLATCH_: For data file IO issues (including PAGEIOLATCH_SH, PAGEIOLATCH_EX, PAGEIOLATCH_UP). If the wait type name has IO in it, it points to an IO issue. If there is no IO in the page latch wait name, it points to a different type of problem (for example, tempdb contention).
-- WRITE_LOG: For transaction log IO issues
-- Use the sys.dm_exec_requests or sys.dm_os_waiting_tasks to see the wait_type and wait_time.

-- To identify the queries follow IO Issues.

-- Query Store
-- The SQL Server Query Store feature provides you with insight on query plan choice and performance. It simplifies performance troubleshooting by helping you quickly find performance differences caused by query plan changes. Query Store automatically captures a history of queries, plans, and runtime statistics, and retains these for your review.

-- You can fetch the query IDs for TOP IO Consuming (Logical and physical reads) queries by selecting the particular metric under the regressed queries section of the Query store.


-- Up-to-date index statistics are crucial for the SQL DB query optimizer to generate optimal execution plans. Better execution plans use the right amount of resources and improve's performance , thus the first place to start is by updating statistics.

-- Updating statistics
-- SQL Server automatically updates statistics on tables with more than 500 records, and that have over 20% of the rows modified. When the amount of change does not cross this 20% threshold the statistics are outdated, leading to bad cardinality estimation and bad query execution plans. You can update statistics using the query below:

-- This will update all the statistics on all the tables in your database.
-- remove the comments from EXEC sp_executesql in order to have the commands actually update stats, instead of just printing them.

SET NOCOUNT ON
GO

DECLARE updatestats CURSOR FOR
SELECT table_schema, table_name 
FROM information_schema.tables
where TABLE_TYPE = 'BASE TABLE'
OPEN updatestats

DECLARE @tableSchema NVARCHAR(128)
DECLARE @tableName NVARCHAR(128)
DECLARE @Statement NVARCHAR(300)

FETCH NEXT FROM updatestats INTO @tableSchema, @tableName
WHILE (@@FETCH_STATUS = 0)
BEGIN
SET @Statement = 'UPDATE STATISTICS '  + '[' + @tableSchema + ']' + '.' + '[' + @tableName + ']' + '  WITH FULLSCAN'
PRINT @Statement -- comment this print statement to prevent it from printing whenever you are ready to execute the command below.

--EXEC sp_executesql @Statement -- remove the comment on the beginning of this line to run the commands

FETCH NEXT FROM updatestats INTO @tableSchema, @tableName
END

CLOSE updatestats
DEALLOCATE updatestats

GO
SET NOCOUNT OFF
GO

-- Using automation
-- You can use Azure Automation to run a scheduled runbook that can do the index and statistics maintenance for you. To configure the same, please follow Automating Azure SQL DB index and statistics maintenance using Azure Automation.

-- Guidelines for creating\updating large indexes
-- If you are creating\updating a large index please follow the following guidelines.



-- Fastest way to mitigate low or no free space available
-- Increase storage, if service tier allows it
-- Upgrade to a service tier that can provide more storage
-- If you are facing issues due to Tempdb being full, you can do a failover to clear tempdb
-- The Failover Rest API can be used to easily failover your Azure SQL Managed Instance to a new node, which clears tempdb. Note that existing connections will be dropped during the failover, so applications should handle the disconnect with appropriate retry logic.

-- Calculating database and objects sizes
-- The following query returns the size of your database (in megabytes):

-- Calculates the size of the database.
SELECT SUM(CAST(FILEPROPERTY(name, 'SpaceUsed') AS bigint) * 8192.) / 1024 / 1024 AS DatabaseSizeInMB
FROM sys.database_files
WHERE type_desc = 'ROWS';
GO

-- The following query returns the size of individual objects (in megabytes) in your database:

-- Calculates the size of individual database objects.
SELECT sys.objects.name, SUM(reserved_page_count) * 8.0 / 1024
FROM sys.dm_db_partition_stats, sys.objects
WHERE sys.dm_db_partition_stats.object_id = sys.objects.object_id
GROUP BY sys.objects.name;
GO


-- TempDB Issues
-- The top wait types associated with tempdb issues are PAGELATCH_* (not PAGEIOLATCH_). However, PAGELATCH_ waits do not always mean you have tempdb contention. This wait may also mean that you have user-object data page contention due to concurrent requests targeting the same data page.

-- To further confirm tempdb contention, use sys.dm_exec_requests to confirm that the wait_resource value begins with 2:x:y where 2 is tempdb database ID, x is the file ID, and y is the page ID.
-- For example: Wait Resource 2:1:3 is
-- DatabaseID: 2 (TempDB)
-- File Number: 1 (The first data file)
-- Page Number: 3 (SGAM Page) )

-- For tempdb contention, a common method is to reduce or re-write application code that relies on tempdb. Common tempdb usage areas include:

-- Temp tables
-- Table variables
-- Table-valued parameters
-- Version store usage (specifically associated with long running transactions)
-- Queries that have query plans that use sorts, hash joins, and spools
-- You can use the following query to identify top queries that use table variables and temporary tables:

SELECT plan_handle, execution_count, query_plan
INTO #tmpPlan
FROM sys.dm_exec_query_stats
     CROSS APPLY sys.dm_exec_query_plan(plan_handle);
GO

WITH XMLNAMESPACES('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS sp)
SELECT plan_handle, stmt.stmt_details.value('@Database', 'varchar(max)') 'Database', stmt.stmt_details.value('@Schema', 'varchar(max)') 'Schema', stmt.stmt_details.value('@Table', 'varchar(max)') 'table'
INTO #tmp2
FROM(SELECT CAST(query_plan AS XML) sqlplan, plan_handle FROM #tmpPlan) AS p
    CROSS APPLY sqlplan.nodes('//sp:Object') AS stmt(stmt_details);
GO

SELECT t.plan_handle, [Database], [Schema], [table], execution_count
FROM(SELECT DISTINCT plan_handle, [Database], [Schema], [table]
     FROM #tmp2
     WHERE [table] LIKE '%@%' OR [table] LIKE '%#%') AS t
    JOIN #tmpPlan AS t2 ON t.plan_handle=t2.plan_handle;
	
	
-- Long term mitigations
-- Analyze if column data types are the right ones for the data they will store
-- Test compressing tables and/or indexes
-- Depending on the workload and service tier, test Columnstore indexes
-- If possible export and remove data that is not needed or move to another database, with lower service tier, if the access pattern is low
-- Compression
-- The data compression feature help's to reduce the size of the database. In addition to saving space, data compression can help improve performance of I/O intensive workloads because the data is stored in fewer pages and queries need to read fewer pages from disk. However, extra CPU resources are required on the database server to compress and decompress the data, while data is exchanged with the application.

-- Alerts
-- Several maintenance and administrative actions performed in a database require some storage for temporary data and for this reason it’s not recommended to allow the storage usage of the database to be very close to the its limits. To prevent your database to be very close to the storage limit is advised to implement alerts or having other ways to monitor the storage usage.
