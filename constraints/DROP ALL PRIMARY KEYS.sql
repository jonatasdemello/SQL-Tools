-- DROP ALL PRIMARY KEYS
DECLARE @schemaName NVARCHAR(128);
DECLARE @tableName NVARCHAR(128);
DECLARE @constraintName NVARCHAR(128);
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
    -- Cursor to iterate through all primary key constraints of the current table
    DECLARE constraintCursor CURSOR FOR
        SELECT CONSTRAINT_NAME
        FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
        WHERE TABLE_SCHEMA = @schemaName AND TABLE_NAME = @tableName 
            AND CONSTRAINT_TYPE = 'PRIMARY KEY';

    OPEN constraintCursor;
    FETCH NEXT FROM constraintCursor INTO @constraintName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Construct the SQL to drop the primary key constraint
        SET @sql = 'ALTER TABLE ' + QUOTENAME(@schemaName) + '.' + QUOTENAME(@tableName) + ' DROP CONSTRAINT IF EXISTS ' + QUOTENAME(@constraintName) +';';
        PRINT @SQL

        EXEC sp_executesql @sql;

        FETCH NEXT FROM constraintCursor INTO @constraintName;
    END

    CLOSE constraintCursor;
    DEALLOCATE constraintCursor;

    FETCH NEXT FROM tableCursor INTO @schemaName, @tableName;
END

CLOSE tableCursor;
DEALLOCATE tableCursor;
