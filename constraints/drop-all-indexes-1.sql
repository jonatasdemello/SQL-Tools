if 1=0
BEGIN

    declare @qry nvarchar(max);
    select @qry = 
    (SELECT  'DROP INDEX ' + quotename(ix.name) + ' ON ' + quotename(object_schema_name(object_id)) + '.' + quotename(OBJECT_NAME(object_id)) + '; '
    FROM  sys.indexes ix
    WHERE   ix.Name IS NOT null 
        and ix.Name like '%prefix_%'
    for xml path(''));
    exec sp_executesql @qry


    ---------------------------------------------------------------------------------------------------
    SELECT TOP 5 * FROM sysindexes

    SELECT 'DROP INDEX ' + ix.Name + ' ON ' + OBJECT_NAME(ID)  AS QUERYLIST
    FROM  sysindexes ix
    WHERE ix.Name IS NOT null 
    and ix.Name like '%pre_%'


    SELECT TOP (100) * FROM INFORMATION_SCHEMA.TABLES
END

---------------------------------------------------------------------------------------------------
-- drop all columns that match

Declare @TableSchema VarChar(500), @TableName VarChar(500), @ColumnName VarChar(500), @SqlQuery nVarChar(Max)
Declare Cursor1 Cursor Local For 

    SELECT TABLE_SCHEMA, TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES
    ORDER BY TABLE_SCHEMA, TABLE_NAME

    Open Cursor1 Fetch Next From Cursor1 Into @TableSchema, @TableName
        While @@Fetch_Status = 0 Begin
            Set @SqlQuery = 'exec dbo.DropIndexes '''+ @TableSchema +''', '''+ @TableName + ''', ''E'';'
            --Print @SqlQuery
            Execute (@SqlQuery)
            Fetch Next From Cursor1 Into @TableSchema, @TableName
        End
    Close Cursor1;
Deallocate Cursor1;
GO
