select t.name, i.name,*
FROM sys.tables t
    INNER JOIN sys.indexes i ON t.object_id = i.object_id
    WHERE i.type NOT IN (0, 1, 5)
        AND SCHEMA_NAME(T.schema_id) not IN ('INFORMATION_SCHEMA', 'sys')  AND T.schema_id < 1600
        and t.name = 'Note'


-- AdvisementNotes.[Note] => t.object_id = 1086626914
select SCHEMA_NAME(T.schema_id) ,* FROM sys.tables t where t.name = 'Note'


-- show all indexes
SELECT i.name AS index_name
    ,COL_NAME(ic.object_id, ic.column_id) AS column_name
    ,ic.index_column_id
    ,ic.key_ordinal
    ,ic.is_included_column
FROM sys.indexes AS i
INNER JOIN sys.index_columns AS ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE i.object_id = OBJECT_ID('AdvisementNotes.Note');



-- ok 3 rows
select top 20 * from sys.indexes idx where idx.object_id = 1086626914
-- ok 11 rows
select top 20 COL_NAME(ic.object_id, ic.column_id) AS column_name, * from sys.index_columns ic where ic.index_id = 3 and ic.object_id = 1086626914
-- ok 14 rows
select top 20 * from sys.columns col  where col.object_id = 1086626914


select top 20 * from sys.indexes idx 
    INNER join sys.index_columns idxCol on idx.index_id = idxCol.index_id and idx.object_id = idxCol.object_id
where idx.object_id = 1086626914


    select top 20 * from sys.indexes idx where idx.object_id = 1086626914
    select top 20 * from sys.index_columns idxCol where idxCol.index_id = 3 and idxCol.object_id = 1086626914    --on idx.index_id = idxCol.index_id  and idx.object_id = idxCol.object_id
    select top 20 * from sys.columns col where col.object_id = 1086626914 -- on idxCol.column_id = col.column_id

select top 10 * from sys.tables tbl -- on idx.object_id = tbl.object_id 

select top 20 * from sys.indexes idx 
    inner join sys.tables tbl on idx.object_id = tbl.object_id 
    inner join sys.index_columns idxCol on idx.index_id = idxCol.index_id  and idx.object_id = idxCol.object_id
    --inner join sys.columns col on idxCol.column_id = col.column_id
    where idx.object_id = 1086626914



select top 10
    idx.name as index_name, idx.[type], idx.type_desc, 
    SCHEMA_NAME(tbl.schema_id) as schema_name,
    tbl.name as table_name, 
    col.name as column_name
from sys.indexes idx 
inner join sys.tables tbl on idx.object_id = tbl.object_id 
inner join sys.index_columns idxCol on idx.index_id = idxCol.index_id 
inner join sys.columns col on idxCol.column_id = col.column_id
where idx.type <> 0
and tbl.name = 'Note'
--group by idx.name, tbl.name
order by idx.name desc
/*
declare @sqlDropIndex NVARCHAR(1000)

select @sqlDropIndex = 'DROP INDEX ' + idx.name + ' ON ' + tbl.name
from sys.indexes idx inner join 
sys.tables tbl on idx.object_id = tbl.object_id inner join
sys.index_columns idxCol on idx.index_id = idxCol.index_id inner join
sys.columns col on idxCol.column_id = col.column_id
where idx.type <> 0 and
--tbl.name = 'MyTableName' and col.name = 'MyColumnName'
col.name like '%CreatedDate%'
group by idx.name, tbl.name
order by idx.name desc

print @sqlDropIndex
--exec sp_executeSql @sqlDropIndex
go
*/