SET NOCOUNT ON;

if 1=0 
BEGIN
    -- show all constraints
    Select 
        SCHEMA_NAME(ST.schema_id) as "Schema_Name",
        ST.[name] AS "Table_Name", 
        SD.[name] AS "Constraint_Name"
    FROM sys.tables ST 
        Inner Join sys.syscolumns SC ON ST.[object_id] = SC.[id] 
        Inner Join sys.default_constraints SD ON ST.[object_id] = SD.[parent_object_id] And SC.colid = SD.parent_column_id 
    ORDER BY ST.[name], SC.colid
END
GO

---------------------------------------------------------------------------------------------------
-- drop all constraints

Declare @TableSchema VarChar(500), @TableName VarChar(500), @ConstraintName VarChar(500), @SqlQuery nVarChar(Max)
Declare Cursor1 Cursor Local For 

    Select 
        SCHEMA_NAME(ST.schema_id) as "Schema_Name",
        ST.[name] AS "Table_Name", 
        SD.[name] AS "Constraint_Name"
        -- SD.type_desc = (DEFAULT_CONSTRAINT)
    FROM sys.tables ST 
        Inner Join sys.syscolumns SC ON ST.[object_id] = SC.[id] 
        Inner Join sys.default_constraints SD ON ST.[object_id] = SD.[parent_object_id] And SC.colid = SD.parent_column_id 
    WHERE
        SD.type_desc = 'DEFAULT_CONSTRAINT'
    ORDER BY ST.[name], SC.colid

    Open Cursor1 Fetch Next From Cursor1 Into @TableSchema, @TableName, @ConstraintName
        While @@Fetch_Status = 0 Begin
            Set @SqlQuery = 'ALTER TABLE '+ QUOTENAME(@TableSchema) +'.'+ QUOTENAME(@TableName) + ' DROP CONSTRAINT IF EXISTS ' + QUOTENAME(@ConstraintName) +';';
            Print @SqlQuery

            Execute (@SqlQuery)
            Fetch Next From Cursor1 Into @TableSchema, @TableName, @ConstraintName
        End
    Close Cursor1;
Deallocate Cursor1;
GO
