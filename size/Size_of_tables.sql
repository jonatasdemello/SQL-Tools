SET NOCOUNT ON 
DBCC UPDATEUSAGE(0)

-- DB size.
EXEC sp_spaceused

-- Table row counts and sizes.
CREATE TABLE #t (
	[name] NVARCHAR(128),
	[rows] VARCHAR(11),
	[reserved] VARCHAR(18),
	[data] VARCHAR(18),
	[index_size] VARCHAR(18),
	[unused] VARCHAR(18)
)

EXEC sp_msForEachTable 'print ''?'' '

-- get space used
INSERT #t EXEC sp_msForEachTable 'EXEC sp_spaceused ''?''' 

-- now can add column:
alter TABLE #t add [total] int

SELECT top 20 * FROM #t

-- # of rows.
-- SELECT SUM(CAST([rows] AS int)) AS [rows] FROM #t 

-- select [data], REPLACE([data],' KB','') from #t order by 2

update #t 
set total = CAST( REPLACE([data],' KB','') as INT), [rows] = RTRIM([Rows])


SELECT * FROM #t order by [total] DESC


DROP TABLE #t

