
exec sp_spaceused  

SELECT      sys.databases.name,  
            CONVERT(VARCHAR,SUM(size)*8/1024)+' MB' AS [Total disk space]  ,
			SUM(size)*8/1024
FROM        sys.databases   
JOIN        sys.master_files  
ON          sys.databases.database_id=sys.master_files.database_id  
GROUP BY    sys.databases.name  
ORDER BY    3 --, sys.databases.name  


 
SELECT
  s.Name                                       AS SchemaName,
  t.Name                                       AS TableName,
  p.Rows                                       AS RowCounts,
  SUM(a.total_pages) * 8                       AS TotalSpaceKB,
  SUM(a.used_pages) * 8                        AS UsedSpaceKB,
  (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB
FROM
  sys.tables t
  INNER JOIN sys.indexes i ON t.object_id = i.object_id
  INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
  INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
  LEFT OUTER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE
  t.Name NOT LIKE 'dt%'
  AND t.is_ms_shipped = 0
  AND i.object_id > 255
GROUP BY
  t.Name, s.Name, p.Rows
ORDER BY
  --t.Name;
  3 DESC
GO


--Another way is using the stored procedure sp_spaceused which displays the number of rows, 
-- disk space reserved, and disk space used by a table, indexed view, or Service Broker queue in the current database,
-- or displays the disk space reserved and used by the whole database.

-- Display disk space information about a table

USE {database_name};  
GO  
EXEC sp_spaceused N'{dbo}.{table_name}';  
GO  

	
USE {database_name};  
GO  
EXEC sp_spaceused N'{dbo}.{table_name}';  
GO  

-- Display disk space information for all tables at once

USE {database_name};  
GO  
sp_msforeachtable N'EXEC sp_spaceused [?]';  
GO
	
USE {database_name};  
GO  
sp_msforeachtable N'EXEC sp_spaceused [?]';  
GO

--Space used by indexes

--If you want to find how much space is used by indexes on the tables of a database you can use the following query:

SELECT
  OBJECT_NAME(i.object_id) AS TableName,
  i.name                   AS IndexName,
  i.index_id               AS IndexID,
  8 * SUM(a.used_pages)    AS 'Indexsize(KB)'
FROM
  sys.indexes AS i
  JOIN sys.partitions AS p ON p.object_id = i.object_id AND p.index_id = i.index_id
  JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
GROUP BY
  i.OBJECT_ID, i.index_id, i.name
ORDER BY
  OBJECT_NAME(i.object_id),
  i.index_id


	
SELECT
  OBJECT_NAME(i.object_id) AS TableName,
  i.name                   AS IndexName,
  i.index_id               AS IndexID,
  8 * SUM(a.used_pages)    AS 'Indexsize(KB)'
FROM
  sys.indexes AS i
  JOIN sys.partitions AS p ON p.object_id = i.object_id AND p.index_id = i.index_id
  JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
GROUP BY
  i.OBJECT_ID, i.index_id, i.name
ORDER BY
  OBJECT_NAME(i.object_id),
  i.index_id

