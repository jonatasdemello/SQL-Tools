IF NOT EXISTS(SELECT * FROM sys.schemas WHERE [name] = 'ddl')
BEGIN
	EXEC sp_executesql N'CREATE SCHEMA ddl AUTHORIZATION dbo'
END
GO
