------------------------------------------------------------------------------------------------------------------------------

EXEC sys.sp_helpindex @objname = N'User' -- nvarchar(77)

SELECT OBJECT_SCHEMA_NAME(object_id),  OBJECT_NAME(object_id), * FROM sys.indexes WHERE NAME = N'UQ_Users_Email_unique'


EXEC sys.sp_helpindex @objname = N'CMS.Users'

SELECT OBJECT_SCHEMA_NAME(object_id),  OBJECT_NAME(object_id), * FROM sys.indexes WHERE NAME = N'UQ_Users_Email_unique'

SELECT * FROM sys.indexes WHERE NAME like  N'%Users%'


-- There are two "sys" catalog views you can consult: sys.indexes and sys.index_columns.

-- Those will give you just about any info you could possibly want about indices and their columns.

-- EDIT: This query's getting pretty close to what you're looking for:

SELECT 
     TableName = t.name,
     IndexName = ind.name,
     IndexId = ind.index_id,
     ColumnId = ic.index_column_id,
     ColumnName = col.name,
     ind.*,
     ic.*,
     col.* 
FROM 
     sys.indexes ind 
INNER JOIN 
     sys.index_columns ic ON  ind.object_id = ic.object_id and ind.index_id = ic.index_id 
INNER JOIN 
     sys.columns col ON ic.object_id = col.object_id and ic.column_id = col.column_id 
INNER JOIN 
     sys.tables t ON ind.object_id = t.object_id 
WHERE 
     ind.is_primary_key = 0 
     AND ind.is_unique = 0 
     AND ind.is_unique_constraint = 0 
     AND t.is_ms_shipped = 0 
ORDER BY 
     t.name, ind.name, ind.index_id, ic.is_included_column, ic.key_ordinal;



