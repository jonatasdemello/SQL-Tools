USE [Performance]
GO

/****** Object:  View [dbo].[vwQueryStats]    Script Date: 2021-02-08 8:49:24 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vwQueryStats]
AS

WITH CTE_QueryStats AS
(
	SELECT CASE WHEN st.[text] LIKE '%StudentCoursesStage%' OR st.[text] LIKE '%CourseMasterStage%' OR st.[text] LIKE '%StudentStage%' THEN 'SISStaging3' ELSE ISNULL(DB_NAME(st.dbid), 'cc3') END AS [DatabaseName],
		   SWITCHOFFSET(creation_time, DATEDIFF( MINUTE, GETDATE() AT TIME ZONE 'Eastern Standard Time', GETDATE())) AS CreationTime,
		   SWITCHOFFSET(last_execution_time, DATEDIFF( MINUTE, GETDATE() AT TIME ZONE 'Eastern Standard Time', GETDATE())) AS LastExecutionTime,
		   
		   execution_count AS ExecutionCount,

		   -- Elapsed Time
		   (total_elapsed_time+0.0) * 0.000001 AS [TotalExecutionTimeSeconds],
		   (total_elapsed_time+0.0) / (execution_count) * 0.000001 AS [AvgExecutionTimeSeconds], 
		   (max_elapsed_time+0.0) * 0.000001 AS [MaxExecutionTimeSeconds],
		   (((total_elapsed_time+0.0) / (execution_count) * 0.000001) * 0.4) + -- AvgExecutionTimeSeconds
				(((max_elapsed_time+0.0) * 0.000001) * 0.4) +   -- MaxExecutionTime
				(execution_count * 0.2) AS [ExecutionTimeCost],  -- Times executed

		   -- CPU
		   (total_worker_time+0.0) * 0.000001  AS TotalCPUTimeSeconds,
		   (total_worker_time+0.0) / (execution_count) * 0.000001 AS [AvgCPUTimeSeconds], 
		   (max_worker_time+0.0) * 0.000001 AS [MaxCPUTimeSeconds],
		   
		   -- Memory
		   (total_ideal_grant_kb+0.0) * 0.001 AS TotalMemoryMB,
		   (total_ideal_grant_kb+0.0) / (execution_count) * 0.001 AS AvgMemoryMB,
		   (max_ideal_grant_kb+0.0) * 0.001 AS MaxMemoryMB,

		   -- Read IO
		   (total_physical_reads + total_logical_reads) AS TotalReadsExtents,
		   (total_physical_reads + total_logical_reads + 0.0) / (execution_count) AS AvgReadsExtents,
		   (max_physical_reads + max_logical_reads + 0.0) AS MaxReadsExtents,		   

		   -- Write IO
		   total_logical_writes AS TotalWritesExtents,
		   (total_logical_writes + 0.0) / execution_count AS AvgWritesExtents,
		   (max_logical_writes) AS MaxWritesExtents,

		   REPLACE(REPLACE(REPLACE(CASE WHEN st.[text] LIKE '%CREATE PROCEDURE%' THEN TRIM(SUBSTRING(st.[text], CHARINDEX('CREATE PROCEDURE', st.[text]) + LEN('CREATE PROCEDURE'), 10000))
			  WHEN st.[text] LIKE '%CREATE FUNCTION%' THEN TRIM(SUBSTRING(st.[text], CHARINDEX('CREATE FUNCTION', st.[text]) + LEN('CREATE FUNCTION'), 10000))
			  ELSE 'T-SQL: ' + LTRIM(RTRIM(SUBSTRING(st.[text], 1, 500)))
		   END, '(', ' ('), '[', ''), ']', '') AS SQL,
		   CASE WHEN st.[text] LIKE '%CREATE PROCEDURE%' THEN 'Procedure'
			  WHEN st.[text] LIKE '%CREATE FUNCTION%' THEN 'Function'
			  ELSE 'Other'
		   END AS [Type]
	FROM sys.dm_exec_query_stats qs
	CROSS APPLY sys.dm_exec_sql_text(sql_handle) st
	WHERE total_worker_time > 0 AND st.[text] NOT LIKE '%msparam%' AND st.[text] NOT LIKE '%sys.sp_table%' AND st.[text] NOT LIKE '%sp_sqlagent%' AND st.[text] NOT LIKE '%sp_columns%' and st.[text] NOT LIKE '%tbl_fedauth%' AND
		st.[text] NOT LIKE '%Tbl1%' AND st.[text] NOT LIKE '%Col1%' AND st.[text] NOT LIKE '%SCHEMA_NAME%' AND st.[text] NOT LIKE '%tempdb.dbo%' AND st.[text] NOT LIKE '%COL_VAL(object%' AND
		st.[text] NOT LIKE '%vwQueryStats%' AND st.[text] NOT LIKE '%size_in_mb%' AND st.[text] NOT LIKE '%threshold_time%' AND st.[text] NOT LIKE '%@csn bigint%' AND
		st.[text] NOT LIKE '%msdb.%' AND st.[text] NOT LIKE '%Cloud Lifter%'
)
SELECT DatabaseName,
	   MIN(CreationTime) AS CreationTime, 
	   MAX(LastExecutionTime) AS LastExecutionTime, 
	   SUM(ExecutionCount) AS ExecutionCount,

	   SUM(TotalExecutionTimeSeconds) AS TotalExecutionTimeSeconds,
	   SUM(TotalExecutionTimeSeconds) / SUM(ExecutionCount) AS AvgExecutionTimeSeconds,
	   MAX(MaxExecutionTimeSeconds) AS MaxExecutionTimeSeconds,
	   SUM(ExecutionTimeCost) AS ExecutionTimeCost,

	   SUM(TotalCPUTimeSeconds) AS TotalCPUTimeSeconds,
	   SUM(TotalCPUTimeSeconds) / SUM(ExecutionCount) AS AvgCPUTimeSeconds,
	   MAX(MaxCPUTimeSeconds) AS MaxCPUTimeSeconds,

	   SUM(TotalMemoryMB) AS TotalMemoryMB,
	   SUM(TotalMemoryMB) / SUM(ExecutionCount) AS AvgMemoryMB,
	   MAX(MaxMemoryMB) AS MaxMemoryMB,

	   SUM(TotalReadsExtents) AS TotalReadsExtents,
	   SUM(TotalReadsExtents) / SUM(ExecutionCount) AS AvgReadsExtents,
	   MAX(MaxReadsExtents) AS MaxReadsExtents,

	   SUM(TotalWritesExtents) AS TotalWritesExtents,
	   SUM(TotalWritesExtents) / SUM(ExecutionCount) AS AvgWritesExtents,
	   MAX(MaxWritesExtents) AS MaxWritesExtents,

       TRIM(CASE WHEN [Type] != 'Other' THEN SUBSTRING([SQL], 1, CHARINDEX(' ', [SQL])) ELSE [SQL] END) AS [SQL]
FROM CTE_QueryStats 
GROUP BY DatabaseName, TRIM(CASE WHEN [Type] != 'Other' THEN SUBSTRING([SQL], 1, CHARINDEX(' ', [SQL])) ELSE [SQL] END)

GO


