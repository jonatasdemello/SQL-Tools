select * from sys.databases where [name] like 'TEST_%' and LEN(name) = 37

/* Delete Database Backup and Restore History from MSDB System Database */

EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'MyTechMantra'
GO

/* Query to Get Exclusive Access of SQL Server Database before Dropping the Database  */

USE [master]
GO
ALTER DATABASE [MyTechMantra] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO

/* Query to Drop Database in SQL Server  */

DROP DATABASE [MyTechMantra]
GO

