select 'drop database', name from sys.databases where name like 'test_%'

drop database	TEST_4342d205d5fd41808005337c29b96c46
drop database	TEST_9bdd37ad46334f47b2c66dae19e9a7d4
drop database	TEST_9c7f2d54195b44bdb7230596bb9f1dd0




-- Remove Test_ DBs
SET NOCOUNT ON;
DECLARE @SQL NVARCHAR(255)
DECLARE @DB NVARCHAR(255)

SELECT [name] INTO #MYTEMP FROM sys.databases where name like 'TEST_%'

WHILE EXISTS (SELECT TOP 1 [NAME] FROM #MYTEMP)
BEGIN
	SELECT TOP (1) @DB = [NAME] FROM #MYTEMP;

	SELECT @SQL = 'DROP DATABASE '+ @DB;

	PRINT @SQL;
	EXEC sp_executesql @sql

	DELETE FROM #MYTEMP WHERE [NAME] = @DB;
END
DROP TABLE #MYTEMP;
GO
