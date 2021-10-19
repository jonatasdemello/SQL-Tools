
USE [master]
GO
-- Method 1: I use this method
EXEC sp_attach_single_file_db @dbname='TestDb',
	@physname=N'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\TestDb.mdf'
GO
-- Method 2:
CREATE DATABASE TestDb ON
(FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\TestDb.mdf')
FOR ATTACH_REBUILD_LOG
GO
-- Method 3:
CREATE DATABASE TestDb ON
( FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\TestDb.mdf')
FOR ATTACH
GO




CREATE DATABASE AdventureWorksLT2012 
ON (FILENAME = '{drive}:\{file path}\AdventureWorksLT2012_Data.mdf') 
FOR ATTACH_REBUILD_LOG;


