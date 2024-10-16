use rh_senarpr
drop procedure sp_defragment_indexes

-- verify 
	DBCC SHOWCONTIG()
	
-- run
 sp_defragment_indexes 95.00




CREATE PROCEDURE sp_defragment_indexes @maxfrag DECIMAL

AS

/* T.Pullen

This stored procedure checks index fragmentation in a database and defragments
indexes whose scan densities fall below a specified threshold, @magfrag, which
is passed to the SP. This SP was initially based on a code sample in SQL Server 2000
Books Online.

Must be run in the database to be defragmented.

*/


-- Declare variables

SET NOCOUNT ON
DECLARE @tablename VARCHAR (128)
DECLARE @execstr VARCHAR (255)
DECLARE @objectid INT
DECLARE @objectowner VARCHAR(255)
DECLARE @indexid INT
DECLARE @frag DECIMAL
DECLARE @indexname CHAR(255)
DECLARE @dbname sysname
DECLARE @tableid INT
DECLARE @tableidchar VARCHAR(255)

--check this is being run in a user database
SELECT @dbname = db_name()
IF @dbname IN ('master', 'msdb', 'model', 'tempdb')
BEGIN
PRINT 'This procedure should not be run in system databases.'
RETURN
END

--begin Stage 1: checking fragmentation
-- Declare cursor
DECLARE tables CURSOR FOR
SELECT convert(varchar,so.id)
FROM sysobjects so
JOIN sysindexes si
ON so.id = si.id
WHERE so.type ='U'
AND si.indid < 2
AND si.rows > 0

-- Create the temporary table to hold fragmentation information
CREATE TABLE #fraglist (
ObjectName CHAR (255),
ObjectId INT,
IndexName CHAR (255),
IndexId INT,
Lvl INT,
CountPages INT,
CountRows INT,
MinRecSize INT,
MaxRecSize INT,
AvgRecSize INT,
ForRecCount INT,
Extents INT,
ExtentSwitches INT,
AvgFreeBytes INT,
AvgPageDensity INT,
ScanDensity DECIMAL,
BestCount INT,
ActualCount INT,
LogicalFrag DECIMAL,
ExtentFrag DECIMAL)

-- Open the cursor
OPEN tables

-- Loop through all the tables in the database running dbcc showcontig on each one
FETCH NEXT
FROM tables
INTO @tableidchar

WHILE @@FETCH_STATUS = 0
BEGIN
-- Do the showcontig of all indexes of the table
INSERT INTO #fraglist
EXEC ('DBCC SHOWCONTIG (' + @tableidchar + ') WITH FAST, TABLERESULTS, ALL_INDEXES, NO_INFOMSGS')
FETCH NEXT
FROM tables
INTO @tableidchar
END

-- Close and deallocate the cursor
CLOSE tables
DEALLOCATE tables

-- Report the ouput of showcontig for results checking
SELECT * FROM #fraglist

-- Begin Stage 2: (defrag) declare cursor for list of indexes to be defragged
DECLARE indexes CURSOR FOR
SELECT ObjectName, ObjectOwner = user_name(so.uid), ObjectId, IndexName, ScanDensity
FROM #fraglist f
JOIN sysobjects so ON f.ObjectId=so.id
WHERE ScanDensity <= @maxfrag
AND INDEXPROPERTY (ObjectId, IndexName, 'IndexDepth') > 0

-- Write to output start time for information purposes
SELECT 'Started defragmenting indexes at ' + CONVERT(VARCHAR,GETDATE())

-- Open the cursor
OPEN indexes

-- Loop through the indexes
FETCH NEXT
FROM indexes
INTO @tablename, @objectowner, @objectid, @indexname, @frag

WHILE @@FETCH_STATUS = 0
BEGIN
SET QUOTED_IDENTIFIER ON

SELECT @execstr = 'DBCC DBREINDEX (' + '''' +RTRIM(@objectowner) + '.' + RTRIM(@tablename) + '''' +', ' + RTRIM(@indexname) + ') WITH NO_INFOMSGS'
SELECT 'Now executing: '
SELECT(@execstr)
EXEC (@execstr)

SET QUOTED_IDENTIFIER OFF

FETCH NEXT
FROM indexes
INTO @tablename, @objectowner, @objectid, @indexname, @frag
END

-- Close and deallocate the cursor
CLOSE indexes
DEALLOCATE indexes

-- Report on finish time for information purposes
SELECT 'Finished defragmenting indexes at ' + CONVERT(VARCHAR,GETDATE())

-- Delete the temporary table
DROP TABLE #fraglist
GO