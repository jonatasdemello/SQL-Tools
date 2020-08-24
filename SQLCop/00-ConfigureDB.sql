
-- CREATE DATABASE SQLCopTests
-- GO

-- ALTER DATABASE SQLCopTests SET TRUSTWORTHY ON
-- GO


EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'clr enabled', 1;
RECONFIGURE; 

/* With SQLServer 2017 or the current Azure SQL Managed Instance, you also need to set configuration clr strict security to 0 ! */
EXEC sp_configure 'clr strict security', 0;
RECONFIGURE;
GO


DECLARE @cmd NVARCHAR(MAX);
SET @cmd='ALTER DATABASE ' + QUOTENAME(DB_NAME()) + ' SET TRUSTWORTHY ON;';
EXEC(@cmd);
GO