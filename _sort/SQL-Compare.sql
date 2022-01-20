/*
SQL Compare:
	https://www.mssqltips.com/sql-server-tool-category/27/comparison-data/


Aqua Data Studio (AquaFold)	https://www.aquafold.com/
SQL Comparison Toolset (IDERA)	https://www.aquafold.com/aquadatastudio/schema_sql_compare/?utm_source=mssqltips
DB Change Manager (IDERA)
Compare SQL Databases (SQL Delta )	https://www.sqldelta.com/
Data Comparer for SQL Server (EMS Database Management Solutions)	https://www.sqlmanager.net/
DB Ghost Data Compare  (Innovartis)	http://www.innovartis.co.uk/home.aspx
dbForge Data Compare for SQL Server (Devart)	https://www.devart.com/dbforge/sql/datacompare/
MS SQL Data Sync (SQL Maestro Group)	https://www.sqlmaestro.com/products/mssql/datasync/
Omega Sync (Spectral Core)	https://www.spectralcore.com/replicator
SQL Data Compare  (Red Gate Software)	https://www.red-gate.com/products/sql-development/sql-data-compare/
SQL Data Examiner (TulaSoft)	http://www.sqlaccessories.com/sql-data-examiner/
xSQL Bundle (xSQL Software)	https://www.xsql.com/

SqlDiffFramework (SqlDiffFramework) 	https://github.com/msorens/SqlDiffFramework



Diff:
https://docs.microsoft.com/en-us/sql/tools/tablediff-utility?redirectedfrom=MSDN&view=sql-server-ver15

https://www.mssqltips.com/sqlservertip/1073/sql-server-tablediff-command-line-utility/


From this basic command we can see there are differences, but it is not very helpful as to what the problem is, so to make this more useful we can use the "-et" argument to see the differences in a table.  The "et" parameter will create a table, in our case called "Difference", so we can see the differences in a table.
"C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver server1  -sourcedatabase test -sourcetable table1 -destinationserver server1  -destinationdatabase test -destinationtable table2 -et Difference


Another option is to use the "-f" argument that will create a T-SQL script to synchronize the two tables.
"C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver server1  -sourcedatabase test -sourcetable table1 -destinationserver server1 -destinationdatabase test -destinationtable table2 -et Difference -f c:\table1_differences.sql

*/

-- https://codingsight.com/different-ways-to-compare-sql-server-tables-schema-and-data/

CREATE DATABASE TESTDB
CREATE DATABASE TESTDB2
CREATE TABLE TESTDB.dbo.FirstComTable
( ID INT IDENTITY (1,1) PRIMARY KEY,
  FirstName VARCHAR (50),
  LastName VARCHAR (50),
  Address VARCHAR (500)
)
GO
CREATE TABLE TESTDB2.dbo.FirstComTable
( ID INT IDENTITY (1,1) PRIMARY KEY,
  FirstName VARCHAR (50),
  LastName VARCHAR (50),
  Address NVARCHAR (400)
)
GO

INSERT INTO TESTDB.dbo.FirstComTable VALUES ('AAA','BBB','CCC')
GO 5
INSERT INTO TESTDB2.dbo.FirstComTable VALUES ('AAA','BBB','CCC')
GO 5
INSERT INTO TESTDB.dbo.FirstComTable VALUES ('DDD','EEE','FFF')
GO

-- Compare Tables Data Using a LEFT JOIN
SELECT *
FROM TESTDB.dbo.FirstComTable F
LEFT JOIN TESTDB2.dbo.FirstComTable S
ON F.ID = S.ID

-- Compare Tables Data Using EXCEPT Clause
SELECT * FROM TESTDB.dbo.FirstComTable F
EXCEPT 
SELECT * FROM TESTDB2.dbo. FirstComTable S

The result of the previous query will be the row that is available in the first table and not available in the second one, as shown below:


SELECT FirstName, LastName, Address FROM TESTDB.dbo. FirstComTable F
EXCEPT 
SELECT FirstName, LastName, Address FROM TESTDB2.dbo. FirstComTable S

The result will show that only the new records are returned, and the updated ones will not be listed

-- Compare Tables Data Using a UNION ALL … GROUP BY
SELECT DISTINCT * 
  FROM
  (
  SELECT * FROM 
  ( SELECT * FROM TESTDB.dbo. FirstComTable      
  UNION ALL
    SELECT * FROM TESTDB2.dbo. FirstComTable) Tbls
    GROUP BY ID,FirstName, LastName, Address
    HAVING COUNT(*)<2) Diff
	



-- Servers:
192.168.11.118
192.168.11.119
192.168.11.135
192.168.11.16
192.168.11.40
192.168.11.49
192.168.11.5 

-- is configured as a linked server. Check its security configuration to make sure it isn't connecting with SA 
-- or some other bone-headed administrative login, because any user who queries it might get admin-level permissions.

	
--List all SQL Traces 
SELECT * FROM sys.traces

EXEC sp_trace_setstatus 2,0

-- The first parameter being passed (2 in the above example) represents the trace ID. 
-- The second parameter being passed (0 in the above example) corresponds to the action that should be taken.

-- 0 = Stop Trace
-- 1 = Start Trace
-- 2 = Close/Delete Trace


SELECT * FROM fn_trace_gettable ('C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Log\log_4349.trc', default);  
GO  

-- When set to 1, the default trace enabled option enables Default Trace. 
-- The default setting for this option is 1 (ON). A value of 0 turns off the trace.
-- The default trace enabled option is an advanced option. 
-- If you are using the sp_configure system stored procedure to change the setting, 
-- you can change the default trace enabled option only when show advanced options is set to 1. 
-- The setting takes effect immediately without a server restart.

RECONFIGURE;  
-- List all available configuration settings
EXEC sp_configure;  

USE master;  
GO  
EXEC sp_configure 'show advanced options', '1';  


How do we know that the default trace is running? We can run the following script in order to find out if the default trace is running:

	
SELECT* FROM sys.configurations WHERE configuration_id = 1568

If it is not enabled, how do we enable it? We can run this script in order to enable the default trace:

	
sp_configure 'show advanced options', 1;
GO
RECONFIGURE; 
GO
sp_configure 'default trace enabled', 1;
GO
RECONFIGURE;
GO
