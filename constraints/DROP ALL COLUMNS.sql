-- DROP ALL COLUMNS
DECLARE @schemaName NVARCHAR(128);
DECLARE @tableName NVARCHAR(128);
DECLARE @columnName NVARCHAR(128);
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
    -- Cursor to iterate through all columns of the current table
    DECLARE columnCursor CURSOR FOR
        SELECT COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = @schemaName AND TABLE_NAME = @tableName 
        AND (COLUMN_NAME LIKE '%CreatedDate%' OR  COLUMN_NAME LIKE '%ModifiedDate%');

    OPEN columnCursor;
    FETCH NEXT FROM columnCursor INTO @columnName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Construct the SQL to drop the column
        --SET @sql = 'ALTER TABLE ' + @schemaName + '.' + @tableName + ' DROP COLUMN ' + @columnName;
        SET @sql = 'ALTER TABLE ' + QUOTENAME(@schemaName) + '.' + QUOTENAME(@tableName) + ' DROP COLUMN IF EXISTS ' + QUOTENAME(@columnName) +';';
        PRINT @SQL

        EXEC sp_executesql @sql;

        FETCH NEXT FROM columnCursor INTO @columnName;
    END

    CLOSE columnCursor;
    DEALLOCATE columnCursor;

    FETCH NEXT FROM tableCursor INTO @schemaName, @tableName;
END

CLOSE tableCursor;
DEALLOCATE tableCursor;
