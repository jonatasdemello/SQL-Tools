/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (20) [DatabaseName]
      ,[CreationTime]
      ,[LastExecutionTime]
      ,[ExecutionCount]
      ,[TotalExecutionTimeSeconds]
      ,[AvgExecutionTimeSeconds]
      ,[MaxExecutionTimeSeconds]
      ,[TotalCPUTimeSeconds]
      ,[AvgCPUTimeSeconds]
      ,[MaxCPUTimeSeconds]
      ,[TotalMemoryMB]
      ,[AvgMemoryMB]
      ,[MaxMemoryMB]
      ,[TotalReadsExtents]
      ,[AvgReadsExtents]
      ,[MaxReadsExtents]
      ,[TotalWritesExtents]
      ,[AvgWritesExtents]
      ,[MaxWritesExtents]
      ,[SQL]
  FROM [Performance].[dbo].[vwQueryStats]
  where DatabaseName not in ('DataIntegration', 'SISStaging3')
  order by ExecutionCount desc