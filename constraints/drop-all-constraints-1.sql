
SELECT TOP (100) * FROM  SYS.DEFAULT_CONSTRAINTS
SELECT TOP (100) SCHEMA_NAME(schema_id), * FROM  SYS.tables
---------------------------------------------------------------------------------------------------

DECLARE @ConstraintName nvarchar(200)

SELECT @ConstraintName = Name 
FROM SYS.DEFAULT_CONSTRAINTS
    WHERE PARENT_OBJECT_ID = OBJECT_ID('__TableName__')
    AND PARENT_COLUMN_ID = (SELECT column_id FROM sys.columns
                        WHERE NAME = N'__ColumnName__'
                        AND object_id = OBJECT_ID(N'__TableName__'))
IF @ConstraintName IS NOT NULL
    EXEC('ALTER TABLE __TableName__ DROP CONSTRAINT ' + @ConstraintName)


