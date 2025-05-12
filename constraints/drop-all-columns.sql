SET NOCOUNT ON;

if 1=0 
BEGIN
    SELECT TOP 5  'alter table ['+ table_schema +'].['+ table_name +'] drop column ['+ COLUMN_NAME +']'
    FROM INFORMATION_SCHEMA.COLUMNS 
    where COLUMN_NAME like '%CreatedDate%'

    SELECT TOP (10) * FROM sys.tables
    SELECT TOP (10) * FROM sys.syscolumns

    Select 
        SCHEMA_NAME(ST.schema_id) as "Schema_Name",
        ST.[name] AS "Table_Name", 
        SC.[name] AS "Column_Name"
    FROM sys.tables ST 
        Inner Join sys.syscolumns SC ON ST.[object_id] = SC.[id] 
    WHERE SC.[name] like '%CreatedDate%'
END

---------------------------------------------------------------------------------------------------
-- drop all columns that match

Declare @TableSchema VarChar(500), @TableName VarChar(500), @ColumnName VarChar(500), @SqlQuery nVarChar(Max)
Declare Cursor1 Cursor Local For 

    Select
        SCHEMA_NAME(ST.schema_id) as "Schema_Name",
        ST.[name] AS "Table_Name", 
        SC.[name] AS "Column_Name"
    FROM sys.tables ST 
        Inner Join sys.syscolumns SC ON ST.[object_id] = SC.[id] 
    WHERE (SC.[name] like '%CreatedDate%' OR SC.[name] like '%ModifiedDate%')
    ORDER BY ST.[name]

    Open Cursor1 Fetch Next From Cursor1 Into @TableSchema, @TableName, @ColumnName
        While @@Fetch_Status = 0 Begin
            Set @SqlQuery = 'ALTER TABLE '+ QUOTENAME(@TableSchema) +'.'+ QUOTENAME(@TableName) + ' DROP COLUMN IF EXISTS ' + QUOTENAME(@ColumnName) +';';
            Print @SqlQuery
            
            --Execute (@SqlQuery)
            Fetch Next From Cursor1 Into @TableSchema, @TableName, @ColumnName
        End
    Close Cursor1;
Deallocate Cursor1;
GO

