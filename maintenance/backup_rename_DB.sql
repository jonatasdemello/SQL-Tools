
/*
Problem

One of the Junior SQL Server Database Administrator in my company approached me yesterday with a dilemma. 
He was assigned a task to rename few of the databases in Beta and Production environments; 
the reason being the database name was based on some other project that is no longer relevant 
to the data which is presently stored within the database. At first I started to tell him, 
but figured it would be smarter to document the same and share the information.

Solution
Database Administrators usually use the sp_renamedb system stored procedure to 
quickly rename a SQL Server Database. However, the drawback of using sp_renamedb 
is that it doesn’t rename the Logical and Physical names of the underlying database files.

It’s a best practice to make sure the Logical Name and Physical File Name of the database 
is also renamed to reflect the actual name of the database to avoid any confusion with backup, 
restore or detach/attach operations.

In this tip, you will see the steps which you need to follow to rename a SQL Server Database u
sing the ALTER DATABASE command.

*/
--------------------------------------------------------------------------------

--Creating a Sample Database Namely CoreDB

--Let's first create a new database named CoreDB using the T-SQL below:

USE master
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'CoreDB')
DROP DATABASE CoreDB
GO
USE master
GO
CREATE DATABASE [CoreDB] 
ON PRIMARY 
( 
NAME = N'CoreDB', 
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10.SQL2008\MSSQL\DATA\CoreDB.mdf' , 
SIZE = 2048KB , 
FILEGROWTH = 1024KB 
)
LOG ON 
( 
NAME = N'CoreDB_log', 
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10.SQL2008\MSSQL\DATA\CoreDB_log.ldf' , 
SIZE = 1024KB , 
FILEGROWTH = 10%
)
GO
Rename CoreDB Database Using sp_renamedb System Stored Procedure

--Now let's rename the CoreDB database to ProductsDB by executing the below T-SQL code.

USE master
GO
ALTER DATABASE CoreDB 
SET SINGLE_USER 
WITH ROLLBACK IMMEDIATE
GO
EXEC master..sp_renamedb 'CoreDB','ProductsDB'
GO
ALTER DATABASE ProductsDB 
SET MULTI_USER 
GO

--Once the above T-SQL has executed successfully the database name will change however the Logical Name 
-- and File Name will not change. You can verify this by executing the T-SQL below:

USE master
GO
/* Identify Database File Names */
SELECT 
name AS [Logical Name], 
physical_name AS [DB File Path],
type_desc AS [File Type],
state_desc AS [State] 
FROM sys.master_files
WHERE database_id = DB_ID(N'ProductsDB')
GOYour output should look something like this from the above query.


--SELECT * FROM sys.master_files

/*
You can see in the above snippet that the Logical Name and File Name in the DB File Path column 
for ProductsDB are still reflecting the old name of CoreDB. 
This is not a good practice to follow in a Production Environment. 
Below you will see the steps which a DBA can follow to rename the database and its respective files.
*/

--------------------------------------------------------------------------------

--Steps to Rename a SQL Server Database

/* DBAs should follow the below steps which will not only rename the database, 
but at the same time will also rename the Logical Name and File Name of the database.

This first set of commands put the database in single user mode and also modifies the logical names.
*/

/* Set Database as a Single User */
ALTER DATABASE CoreDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE
/* Change Logical File Name */
ALTER DATABASE [CoreDB] MODIFY FILE (NAME=N'CoreDB', NEWNAME=N'ProductsDB')
GO
ALTER DATABASE [CoreDB] MODIFY FILE (NAME=N'CoreDB_log', NEWNAME=N'ProductsDB_log')
GO

--This is the output from the above code.

/*
Now we need to detach the database, so we can rename the physical files.  
If the database files are open you will not be able to rename the files.
*/

/* Detach Current Database */
USE [master]
GO
EXEC master.dbo.sp_detach_db @dbname = N'CoreDB'
GO

/*
Once the CoreDB database is detached successfully then the next step will be to rename the Physical Files. 
This can be done either manually or by using the xp_cmdshell system stored procedure. 
You can enable xp_cmdshell feature using the sp_configure system stored procedure.
*/

USE master
GO
sp_configure 'show advanced options'
GO
/* 0 = Disabled , 1 = Enabled */
sp_configure 'xp_cmdshell', 1
GO
RECONFIGURE WITH OVERRIDE
GO

--Once xp_cmdshell is enabled you can use the below script to rename the physical files of the database.

/* Rename Physical Files */
USE [master]
GO
EXEC xp_cmdshell 'RENAME "C:\Program Files\Microsoft SQL ServerMSSQL10.SQL2008\MSSQL\DATA\CoreDB.mdf", "ProductsDB.mdf"'
GO
EXEC xp_cmdshell 'RENAME "C:\Program Files\Microsoft SQL ServerMSSQL10.SQL2008\MSSQL\DATA\CoreDB_log.ldf", "ProductsDB_log.ldf"'
GO

--Once the above step has successfully executed then the next step will be to attach the database, 
--this can be done by executing the T-SQL below:

/* Attach Renamed ProductsDB Database Online */
USE [master]
GO
CREATE DATABASE ProductsDB ON 
( FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10.SQL2008\MSSQL\DATA\ProductsDB.mdf' ),
( FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10.SQL2008\MSSQL\DATA\ProductsDB_log.ldf' )
FOR ATTACH
GO

--Once the above step has successfully executed then the final step will be to allow multi user access 
--for the user database by executing the below T-SQL:

/* Set Database to Multi User*/
ALTER DATABASE ProductsDB SET MULTI_USER 
GO

--You can verify the Logical and File Names for the ProductsDB database by executing the T-SQL below:

USE master
GO
/* Identify Database File Names */
SELECT 
name AS [Logical Name], 
physical_name AS [DB File Path],
type_desc AS [File Type],
state_desc AS [State] 
FROM sys.master_files
WHERE database_id = DB_ID(N'ProductsDB')
GO

--You can see in the above snippet that the Logical Name and File Name for ProductsDB are now correct.

/*
Next Steps

Once the database name is changed successfully then you need to make sure your application code 
is referring to the new database name. 
The steps to rename a SQL Server Database mentioned in this tip are applicable for both 
SQL Server 2005 and SQL Server 2008. 
*/


