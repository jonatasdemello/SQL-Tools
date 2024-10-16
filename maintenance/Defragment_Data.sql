/*

http://www.sqlhacks.com/Optimize/Defragment-Data

*/


use Sistema_Prod

SELECT CAST(DB_NAME(database_id) AS VARCHAR(15)) AS 'databasename',
       CAST(OBJECT_NAME([OBJECT_ID]) AS VARCHAR(15)) AS 'tablename',
       CAST(index_type_desc AS VARCHAR(20)) AS index_type_desc,
       avg_fragmentation_in_percent AS '% fragmentation',
       fragment_count '# fragments',
       avg_fragment_size_in_pages 'Avg frag size in pages'
FROM   sys.dm_db_index_physical_stats (DB_ID('Sistema_Prod'),null,null,null,null )
order by 4 desc;

/*****************/

DBCC showcontig('AGAnual') WITH NO_INFOMSGS ;

/*****************/

SELECT a.index_id,
       CAST(name AS VARCHAR(15)) AS 'Index name',
       avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats (DB_ID(), OBJECT_ID('AGAnual'),
     null, null, null) AS a
    join sys.indexes AS b ON a.OBJECT_ID = b.OBJECT_ID and a.index_id = b.index_id;


ALTER INDEX all ON AGAnual rebuild WITH (FILLFACTOR = 80, sort_in_tempdb = ON);
 
SELECT a.index_id,
       CAST(name AS VARCHAR(15)) AS 'Index name',
       avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats (DB_ID(), OBJECT_ID('AGAnual'),
     null, null, null) AS a
    join sys.indexes AS b ON a.OBJECT_ID = b.OBJECT_ID and a.index_id = b.index_id;


DBCC showcontig(AGAnual) WITH no_infomsgs 

/*
If the fragmentation is less than 5%, don't bother defragmenting. You will NOT get any improvement.
If the fragmentation is more than 5%, then you can start thinking about the defragmentation.
*/

/*
Only the enterprise edition can rebuild indexes online. 

On a standard edition, you will get the following message:
ALTER INDEX pk_sales_02 ON sales02 rebuild WITH (online = ON);
 
Msg 1712, LEVEL 16, STATE 1, Line 3
Online INDEX operations can ONLY be performed in Enterprise edition OF SQL Server.

*/

ALTER INDEX all ON sales02 rebuild WITH (FILLFACTOR = 80, sort_in_tempdb = ON);
 
SELECT a.index_id,
       CAST(name AS VARCHAR(15)) AS 'Index name',
       avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats (DB_ID(), OBJECT_ID('sales02'),
     null, null, null) AS a
    join sys.indexes AS b ON a.OBJECT_ID = b.OBJECT_ID and a.index_id = b.index_id;



/************* 2005 *************/

SELECT CAST(DB_NAME(DATABASE_ID) AS VARCHAR(20)) AS 'DatabaseName',
       CAST(OBJECT_NAME([OBJECT_ID]) AS VARCHAR(20)) AS 'TableName',
       CAST(INDEX_TYPE_DESC AS VARCHAR(20)) AS INDEX_TYPE_DESC,
       AVG_FRAGMENTATION_IN_PERCENT
FROM   SYS.DM_DB_INDEX_PHYSICAL_STATS (DB_ID('Sistema_Prod'),NULL,NULL,NULL,NULL )
WHERE AVG_FRAGMENTATION_IN_PERCENT >5
order by 4 desc


DBCC showcontig(Contratos) WITH no_infomsgs 

ALTER INDEX all ON Contratos rebuild WITH (FILLFACTOR = 80, sort_in_tempdb = ON);
