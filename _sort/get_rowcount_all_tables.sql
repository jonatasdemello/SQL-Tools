CREATE PROCEDURE [Utility].[GetTableRowCount]
(
	@SchemaName nvarchar(200),
	@TableName nvarchar(200) = ''
)
AS
BEGIN

	SELECT
		  -- QUOTENAME(SCHEMA_NAME(sOBJ.schema_id)) + '.' + QUOTENAME(sOBJ.name) AS [TableName]
		  QUOTENAME(SCHEMA_NAME(sOBJ.schema_id)) AS [SchemaName], 
		  QUOTENAME(sOBJ.name) AS [TableName],
		  SUM(sPTN.Rows) AS [RowCount]
	FROM 
		  sys.objects AS sOBJ
		  INNER JOIN sys.partitions AS sPTN ON sOBJ.object_id = sPTN.object_id
	WHERE
		SCHEMA_NAME(sOBJ.schema_id) = @SchemaName
		AND sOBJ.name like '%'+ @TableName +'%'
		AND sOBJ.type = 'U'
		AND sOBJ.is_ms_shipped = 0x0
		AND index_id < 2 -- 0:Heap, 1:Clustered
	GROUP BY 
		sOBJ.schema_id, sOBJ.name
	ORDER BY 
		[SchemaName],[TableName]

END
GO
-------------------------------------------------------------------------------------------------------------------------------

SELECT SCHEMA_NAME(t.[schema_id]) AS [table_schema]
	  ,OBJECT_NAME(p.[object_id]) AS [table_name]
	  ,SUM(p.[rows]) AS [row_count]
FROM [sys].[partitions] p
INNER JOIN [sys].[tables] t ON p.[object_id] = t.[object_id]
WHERE p.[index_id] < 2
GROUP BY p.[object_id]
	,t.[schema_id]
ORDER BY 1, 2 ASC


SELECT SCHEMA_NAME(t.[schema_id]) AS [table_schema]
      ,t.[name] AS [table_name]
      ,SUM(ps.[row_count]) AS [row_count]
FROM [sys].[tables] t
INNER JOIN [sys].[dm_db_partition_stats] ps
     ON ps.[object_id] = t.[object_id]
WHERE [index_id] < 2
GROUP BY t.[name]
    ,t.[schema_id]
ORDER BY 1, 2 ASC
OPTION (RECOMPILE);


-------------------------------------------------------------------------------------------------------------------------------
SELECT
      QUOTENAME(SCHEMA_NAME(sOBJ.schema_id)) + '.' + QUOTENAME(sOBJ.name) AS [TableName]
      , SUM(sPTN.Rows) AS [RowCount]
FROM 
      sys.objects AS sOBJ
      INNER JOIN sys.partitions AS sPTN ON sOBJ.object_id = sPTN.object_id
WHERE
      sOBJ.type = 'U'
      AND sOBJ.is_ms_shipped = 0x0
      AND index_id < 2 -- 0:Heap, 1:Clustered
GROUP BY 
      sOBJ.schema_id, sOBJ.name
ORDER BY [TableName]
GO
-------------------------------------------------------------------------------------------------------------------------------
SELECT
      QUOTENAME(SCHEMA_NAME(sOBJ.schema_id)) + '.' + QUOTENAME(sOBJ.name) AS [TableName]
      , SUM(sdmvPTNS.row_count) AS [RowCount]
FROM
      sys.objects AS sOBJ
      INNER JOIN sys.dm_db_partition_stats AS sdmvPTNS ON sOBJ.object_id = sdmvPTNS.object_id
WHERE 
      sOBJ.type = 'U' 
      AND sOBJ.is_ms_shipped = 0x0
      AND sdmvPTNS.index_id < 2
GROUP BY
      sOBJ.schema_id, sOBJ.name
ORDER BY [TableName]
GO
-------------------------------------------------------------------------------------------------------------------------------
DECLARE @QueryString NVARCHAR(MAX) ;
SELECT @QueryString = COALESCE(@QueryString + ' UNION ALL ','')
                      + 'SELECT '
                      + '''' + QUOTENAME(SCHEMA_NAME(sOBJ.schema_id))
                      + '.' + QUOTENAME(sOBJ.name) + '''' + ' AS [TableName]
                      , COUNT(*) AS [RowCount] FROM '
                      + QUOTENAME(SCHEMA_NAME(sOBJ.schema_id))
                      + '.' + QUOTENAME(sOBJ.name) + ' WITH (NOLOCK) '
FROM sys.objects AS sOBJ
WHERE
      sOBJ.type = 'U'
      AND sOBJ.is_ms_shipped = 0x0
ORDER BY SCHEMA_NAME(sOBJ.schema_id), sOBJ.name ;
EXEC sp_executesql @QueryString
GO
-------------------------------------------------------------------------------------------------------------------------------
DECLARE @TableRowCounts TABLE ([TableName] VARCHAR(128), [RowCount] INT) ;
INSERT INTO @TableRowCounts ([TableName], [RowCount])
EXEC sp_MSforeachtable 'SELECT ''?'' [TableName], COUNT(*) [RowCount] FROM ?' ;
SELECT [TableName], [RowCount]
FROM @TableRowCounts
ORDER BY [TableName]
GO
-------------------------------------------------------------------------------------------------------------------------------

