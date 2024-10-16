use master

if 1=0
begin
	select name from sys.databases order by name
	select name from sys.databases where name like 'TEST_%'

	DROP DATABASE IF EXISTS TEST_3d9b398021fc455798e15d6f927c698b
	DROP DATABASE IF EXISTS TEST_a03405a7448442acb3dd99a52ff486cd

end


-- Remove Test_ DBs
SET NOCOUNT ON;
DECLARE @SQL NVARCHAR(255)
DECLARE @DB NVARCHAR(255)

SELECT [name] INTO #MYTEMP FROM sys.databases where name like 'TEST_%'

WHILE EXISTS (SELECT TOP 1 [NAME] FROM #MYTEMP)
BEGIN
	SELECT TOP (1) @DB = [NAME] FROM #MYTEMP;

	SELECT @SQL = 'DROP DATABASE IF EXISTS '+ @DB;

	PRINT @SQL;
	EXEC sp_executesql @sql

	DELETE FROM #MYTEMP WHERE [NAME] = @DB;
END
DROP TABLE #MYTEMP;
GO

