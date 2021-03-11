-- Missing Indexes for current database by Index Advantage  (Query 1) (Missing Indexes)
 
SELECT DISTINCT CONVERT(decimal(18,2), user_seeks * avg_total_user_cost * (avg_user_impact * 0.01)) AS [index_advantage], 
  migs.last_user_seek, mid.[statement] AS [Database.Schema.Table],
  mid.equality_columns, mid.inequality_columns, mid.included_columns,
  migs.unique_compiles, migs.user_seeks, migs.avg_total_user_cost, migs.avg_user_impact,
  OBJECT_NAME(mid.[object_id]) AS [Table Name], p.rows AS [Table Rows]
  FROM sys.dm_db_missing_index_group_stats AS migs WITH (NOLOCK)
  INNER JOIN sys.dm_db_missing_index_groups AS mig WITH (NOLOCK)
  ON migs.group_handle = mig.index_group_handle
  INNER JOIN sys.dm_db_missing_index_details AS mid WITH (NOLOCK)
  ON mig.index_handle = mid.index_handle
  INNER JOIN sys.partitions AS p WITH (NOLOCK)
  ON p.[object_id] = mid.[object_id]
  WHERE mid.database_id = DB_ID()
  AND p.index_id < 2 
  ORDER BY index_advantage DESC OPTION (RECOMPILE);
 
  ------
  -- Look at index advantage, last user seek time, number of user seeks to help determine source and importance
  -- SQL Server is overly eager to add included columns, so beware
  -- Do not just blindly add indexes that show up from this query!!!
 
  -- Find missing index warnings for cached plans in the current database  (Query 2) (Missing Index Warnings)
  -- Note: This query could take some time on a busy instance
 
  SELECT TOP(25) OBJECT_NAME(objectid) AS [ObjectName], 
                 cp.objtype, cp.usecounts, cp.size_in_bytes, query_plan
  FROM sys.dm_exec_cached_plans AS cp WITH (NOLOCK)
  CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
  WHERE CAST(query_plan AS NVARCHAR(MAX)) LIKE N'%MissingIndex%'
  AND dbid = DB_ID()
  ORDER BY cp.usecounts DESC OPTION (RECOMPILE);
 
  ------
  -- Helps you connect missing indexes to specific stored procedures or queries
  -- This can help you decide whether to add them or not
  -- Possible Bad NC Indexes (writes &gt; reads)  (Query 3) (Bad NC Indexes)
 
  SELECT OBJECT_NAME(s.[object_id]) AS [Table Name], i.name AS [Index Name], i.index_id, 
  i.is_disabled, i.is_hypothetical, i.has_filter, i.fill_factor,
  s.user_updates AS [Total Writes], s.user_seeks + s.user_scans + s.user_lookups AS [Total Reads],
  s.user_updates - (s.user_seeks + s.user_scans + s.user_lookups) AS [Difference]
  FROM sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
  INNER JOIN sys.indexes AS i WITH (NOLOCK)
  ON s.[object_id] = i.[object_id]
  AND i.index_id = s.index_id
  WHERE OBJECTPROPERTY(s.[object_id],'IsUserTable') = 1
  AND s.database_id = DB_ID()
  AND s.user_updates > (s.user_seeks + s.user_scans + s.user_lookups)
  AND i.index_id > 1 AND i.[type_desc] = N'NONCLUSTERED'
  AND i.is_primary_key = 0 AND i.is_unique_constraint = 0 AND i.is_unique = 0
  ORDER BY [Difference] DESC, [Total Writes] DESC, [Total Reads] ASC OPTION (RECOMPILE);
 
  ------
  -- Look for indexes with high numbers of writes and zero or very low numbers of reads
  -- Consider your complete workload, and how long your instance has been running
  -- Investigate further before dropping an index!
  -- Breaks down buffers used by current database by object (table, index) in the buffer cache  (Query 4) (Buffer Usage)
  -- Note: This query could take some time on a busy instance
  SELECT OBJECT_NAME(p.[object_id]) AS [Object Name], p.index_id, 
  CAST(COUNT(*)/128.0 AS DECIMAL(10, 2)) AS [Buffer size(MB)],  
  COUNT(*) AS [BufferCount], p.[Rows] AS [Row Count],
  p.data_compression_desc AS [Compression Type]
  FROM sys.allocation_units AS a WITH (NOLOCK)
  INNER JOIN sys.dm_os_buffer_descriptors AS b WITH (NOLOCK)
  ON a.allocation_unit_id = b.allocation_unit_id
  INNER JOIN sys.partitions AS p WITH (NOLOCK)
  ON a.container_id = p.hobt_id
  WHERE b.database_id = CONVERT(int, DB_ID())
  AND p.[object_id] > 100
  AND OBJECT_NAME(p.[object_id]) NOT LIKE N'plan_%'
  AND OBJECT_NAME(p.[object_id]) NOT LIKE N'sys%'
  AND OBJECT_NAME(p.[object_id]) NOT LIKE N'xml_index_nodes%'
  GROUP BY p.[object_id], p.index_id, p.data_compression_desc, p.[Rows]
  ORDER BY [BufferCount] DESC OPTION (RECOMPILE);
 
  ------
  -- Tells you what tables and indexes are using the most memory in the buffer cache
  -- It can help identify possible candidates for data compression