IF EXISTS ( SELECT  * FROM    sys.objects WHERE   object_id = OBJECT_ID(N'myproc') AND type IN ( N'P', N'PC' ) ) 
begin
	print('ok')
end
	
-- Example of how to do it when including the schema:

IF EXISTS ( SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id(N'[dbo].[MyProc]') 
                   and OBJECTPROPERTY(id, N'IsProcedure') = 1 )
BEGIN
    DROP PROCEDURE [dbo].[MyProc]
END

--In the example above, dbo is the schema.
-- In SQL Server 2016+, you can just do

CREATE OR ALTER PROCEDURE dbo.MyProc


USE SqlHintsDemoDB
GO
IF EXISTS(SELECT 1 FROM sys.procedures WHERE Name = 'GetCustomers')
BEGIN
    PRINT 'Stored Procedure Exists'
END



USE SqlHintsDemoDB
GO
IF EXISTS(SELECT 1 FROM sys.procedures 
          WHERE object_id = OBJECT_ID(N'dbo.GetCustomers'))
BEGIN
    PRINT 'Stored Procedure Exists'
END


USE MASTER
GO
IF EXISTS(SELECT 1 FROM SqlHintsDemoDB.sys.procedures
 WHERE object_id=OBJECT_ID(N'SqlHintsDemoDB.dbo.GetCustomers'))
BEGIN
    PRINT 'Stored Procedure Exists'
END

Note: sys.procedures catalog view contains a row for each object of the below type:

Type	Description
P	SQL Stored Procedure
PC	Assembly (CLR) stored-procedure
RF	Replication-filter-procedure
X	Extended stored procedure



IF EXISTS (SELECT * FROM sys.objects
            WHERE object_id = OBJECT_ID(N'dbo.GetCustomers')
                    AND type IN ( N'P', N'PC',N'X',N'RF')) 
BEGIN
    PRINT 'Stored Procedure Exists'
END


USE master
GO
IF EXISTS (SELECT * FROM SqlHintsDemoDB.sys.objects
 WHERE object_id=OBJECT_ID(N'SqlHintsDemoDB.dbo.GetCustomers')
      AND type IN ( N'P', N'PC',N'X',N'RF')) 
BEGIN
    PRINT 'Stored Procedure Exists'
END



USE SqlHintsDemoDB
GO
IF EXISTS (SELECT 1 FROM sys.sql_modules
   WHERE object_id =  OBJECT_ID(N'dbo.GetCustomers') 
   AND OBJECTPROPERTY(object_id, N'IsProcedure') = 1) 
BEGIN
    PRINT 'Stored Procedure Exists'
END



USE SqlHintsDemoDB
GO
IF OBJECT_ID(N'dbo.GetCustomers', N'P') IS NOT NULL
BEGIN
    PRINT 'Stored Procedure Exists'
END



USE MASTER
GO
IF OBJECT_ID(N'SqlHintsDemoDB.dbo.GetCustomers', N'P')
     IS NOT NULL
BEGIN
    PRINT 'Stored Procedure Exists'
END


USE SqlHintsDemoDB
GO
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROUTINES 
  WHERE ROUTINE_NAME = 'GetCustomers'
        AND ROUTINE_TYPE = 'PROCEDURE') 
BEGIN
    PRINT 'Stored Procedure Exists'
END


We should avoid using sys.sysobjects System Table directly, direct access to it will be deprecated in some future versions of the Sql Server. As per Microsoft BOL link, Microsoft is suggesting to use the catalog views sys.objects/sys.procedures/sys.sql_modules instead of sys.sysobjects system table directly to check the existence of the stored procedure.

USE SqlHintsDemoDB
GO
IF EXISTS(SELECT 1 FROM sys.sysobjects  
     WHERE id = OBJECT_ID(N'dbo.GetCustomers') AND xtype=N'P' )
BEGIN
    PRINT 'Stored Procedure Exists'
END

