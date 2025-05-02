SET NOCOUNT ON;

if 1=0 
BEGIN
--index simplified
    SELECT 
        i.name as index_name, --i.type_desc, i.object_id,
        t.name as table_name, --t.object_id, t.schema_id, 
        SCHEMA_NAME(T.schema_id) as schema_name,
        t.type, t.type_desc
    FROM sys.indexes i
        inner join sys.tables t ON t.object_id = i.object_id
        WHERE i.type_desc != 'HEAP'
END

---------------------------------------------------------------------------------------------------
-- drop all indexes
Declare @TableSchema VarChar(500), @TableName VarChar(500), @ColumnName VarChar(500), @SqlQuery nVarChar(Max)
Declare Cursor1 Cursor Local For 

    SELECT 
        SCHEMA_NAME(T.schema_id) as schema_name,
        t.name as table_name,
        i.name as index_name
    FROM sys.indexes i
        inner join sys.tables t ON t.object_id = i.object_id
        WHERE i.type_desc != 'HEAP'

    Open Cursor1 Fetch Next From Cursor1 Into @TableSchema, @TableName, @ColumnName
        While @@Fetch_Status = 0 Begin
            SET @SqlQuery = 'DROP INDEX IF EXISTS ' + QUOTENAME(@ColumnName) + ' ON ' + QUOTENAME(@TableSchema) + '.' + QUOTENAME(@TableName) +';';
            Print @SqlQuery
            Execute (@SqlQuery)
            Fetch Next From Cursor1 Into @TableSchema, @TableName, @ColumnName
        End
    Close Cursor1;
Deallocate Cursor1;
GO
