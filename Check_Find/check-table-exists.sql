CREATE DATABASE SqlHintsDemoDB
GO
USE SqlHintsDemoDB
GO
CREATE TABLE dbo.Customers (CustId INT, Name NVARCHAR(50))


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = N'Customers')
BEGIN
  PRINT 'Table Exists'
END


IF EXISTS (SELECT * 
    FROM SqlHintsDemoDB.INFORMATION_SCHEMA.TABLES   
    WHERE TABLE_SCHEMA = N'dbo'  AND TABLE_NAME = N'Customers')
BEGIN
  PRINT 'Table Exists'
END


IF OBJECT_ID(N'dbo.Customers', N'U') IS NOT NULL
BEGIN
  PRINT 'Table Exists'
END


USE MASTER
GO
IF OBJECT_ID(N'SqlHintsDemoDB.dbo.Customers', N'U') IS NOT NULL
BEGIN
  PRINT 'Table Exists'
END


CREATE TABLE #TempTable(ID INT)
GO
IF OBJECT_ID(N'TempDB.dbo.#TempTable', N'U') IS NOT NULL
BEGIN
  PRINT 'Table Exists'
END
GO



IF EXISTS(SELECT 1 FROM sys.Objects 
    WHERE  Object_id = OBJECT_ID(N'dbo.Customers') 
               AND Type = N'U')
BEGIN
  PRINT 'Table Exists'
END



IF EXISTS(SELECT 1 FROM sys.Tables 
          WHERE  Name = N'Customers' AND Type = N'U')
BEGIN
  PRINT 'Table Exists'
END

We should avoid using sys.sysobjects System Table directly, direct access to it will be deprecated in some future versions of the Sql Server. As per Microsoft BOL link, Microsoft is suggesting to use the catalog views sys.objects/sys.tables instead of sys.sysobjects system table directly.

IF EXISTS(SELECT name FROM sys.sysobjects  
          WHERE Name = N'Customers' AND xtype = N'U')
BEGIN
  PRINT 'Table Exists'
END

