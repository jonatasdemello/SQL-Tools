-- DROP ALL INDEXES
DECLARE @schemaName NVARCHAR(128);
DECLARE @tableName NVARCHAR(128);
DECLARE @indexName NVARCHAR(128);
DECLARE @sql NVARCHAR(MAX);

-- Cursor to iterate through all tables
DECLARE tableCursor CURSOR FOR
    SELECT TABLE_SCHEMA, TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_TYPE = 'BASE TABLE';

OPEN tableCursor;
FETCH NEXT FROM tableCursor INTO @schemaName, @tableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Cursor to iterate through all indexes of the current table
    DECLARE indexCursor CURSOR FOR
        -- v1
        -- SELECT name FROM sys.indexes WHERE object_id = OBJECT_ID(@tableName) AND is_primary_key = 0 --AND is_unique_constraint = 0;
        -- v2
        -- SELECT i.name
        -- FROM sys.indexes i
        -- inner join sys.tables t ON t.object_id = i.object_id
        -- WHERE i.type_desc != 'HEAP'
        --     and t.name = @tableName
SELECT
    i.name as index_name,
    t.name as table_name,
    SCHEMA_NAME(T.schema_id) as schema_name
FROM sys.indexes i
    inner join sys.tables t ON t.object_id = i.object_id
    WHERE i.type_desc != 'HEAP'
        --and t.name = @tableName
        --and SCHEMA_NAME(T.schema_id) = @schemaName
    
        

    OPEN indexCursor;
    FETCH NEXT FROM indexCursor INTO @indexName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Construct the SQL to drop the index
        SET @sql = 'DROP INDEX IF EXISTS ' + QUOTENAME(@indexName) + ' ON ' + QUOTENAME(@schemaName) + '.' + QUOTENAME(@tableName) +';';
        PRINT @SQL

        EXEC sp_executesql @sql;

        FETCH NEXT FROM indexCursor INTO @indexName;
    END

    CLOSE indexCursor;
    DEALLOCATE indexCursor;

    FETCH NEXT FROM tableCursor INTO @tableName, @tableName;
END

CLOSE tableCursor;
DEALLOCATE tableCursor;
