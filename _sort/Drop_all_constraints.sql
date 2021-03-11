
-- drop all contraints


-- EXECUTE sp_MSforeachtable 'DBCC CHECKTABLE ([?])';
-- EXECUTE sp_MSforeachtable 'EXECUTE sp_spaceused [?];';


-- Disable all the constraint in database
EXEC sp_msforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT all'

-- Enable all the constraint in database
EXEC sp_msforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all'


-- Script to remove all
--***************************************************************
-- OR:

declare @str varchar(max)
declare cur cursor for

SELECT 'ALTER TABLE ' + '[' + s.[NAME] + '].[' + t.name + '] DROP CONSTRAINT ['+ c.name + ']'
	FROM sys.objects c, sys.objects t, sys.schemas s
	WHERE c.type IN ('C', 'F', 'PK', 'UQ', 'D')
	AND c.parent_object_id=t.object_id and t.type='U' AND t.SCHEMA_ID = s.schema_id
	ORDER BY c.type

open cur
FETCH NEXT FROM cur INTO @str
WHILE (@@fetch_status = 0) BEGIN
 PRINT @str
 EXEC (@str)
 FETCH NEXT FROM cur INTO @str
END

close cur
deallocate cur



-- Script to Create All Foreign Keys
--***************************************************************
-- OR:

DECLARE @schema_name sysname; 
DECLARE @table_name sysname; 
DECLARE @constraint_name sysname; 
DECLARE @constraint_object_id int; 
DECLARE @referenced_object_name sysname; 
DECLARE @is_disabled bit; 
DECLARE @is_not_for_replication bit; 
DECLARE @is_not_trusted bit; 
DECLARE @delete_referential_action tinyint; 
DECLARE @update_referential_action tinyint; 
DECLARE @tsql nvarchar(4000); 
DECLARE @tsql2 nvarchar(4000); 
DECLARE @fkCol sysname; 
DECLARE @pkCol sysname; 
DECLARE @col1 bit; 
DECLARE @action char(6);  
DECLARE @referenced_schema_name sysname;
 
DECLARE FKcursor CURSOR FOR
     select OBJECT_SCHEMA_NAME(parent_object_id)
         , OBJECT_NAME(parent_object_id), name, OBJECT_NAME(referenced_object_id)
         , object_id
         , is_disabled, is_not_for_replication, is_not_trusted
         , delete_referential_action, update_referential_action, OBJECT_SCHEMA_NAME(referenced_object_id)
    from sys.foreign_keys
    order by 1,2;
OPEN FKcursor;
FETCH NEXT FROM FKcursor INTO @schema_name, @table_name, @constraint_name
    , @referenced_object_name, @constraint_object_id
    , @is_disabled, @is_not_for_replication, @is_not_trusted
    , @delete_referential_action, @update_referential_action, @referenced_schema_name;
WHILE @@FETCH_STATUS = 0
BEGIN
 
      IF @action <> 'CREATE'
        SET @tsql = 'ALTER TABLE '
                  + QUOTENAME(@schema_name) + '.' + QUOTENAME(@table_name)
                  + ' DROP CONSTRAINT ' + QUOTENAME(@constraint_name) + ';';
    ELSE
        BEGIN
        SET @tsql = 'ALTER TABLE '
                  + QUOTENAME(@schema_name) + '.' + QUOTENAME(@table_name)
                  + CASE @is_not_trusted
                        WHEN 0 THEN ' WITH CHECK '
                        ELSE ' WITH NOCHECK '
                    END
                  + ' ADD CONSTRAINT ' + QUOTENAME(@constraint_name)
                  + ' FOREIGN KEY (';
        SET @tsql2 = '';
        DECLARE ColumnCursor CURSOR FOR
            select COL_NAME(fk.parent_object_id, fkc.parent_column_id)
                 , COL_NAME(fk.referenced_object_id, fkc.referenced_column_id)
            from sys.foreign_keys fk
            inner join sys.foreign_key_columns fkc
            on fk.object_id = fkc.constraint_object_id
            where fkc.constraint_object_id = @constraint_object_id
            order by fkc.constraint_column_id;
        OPEN ColumnCursor;
        SET @col1 = 1;
        FETCH NEXT FROM ColumnCursor INTO @fkCol, @pkCol;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF (@col1 = 1)
                SET @col1 = 0;
            ELSE
            BEGIN
                SET @tsql = @tsql + ',';
                SET @tsql2 = @tsql2 + ',';
            END;
            SET @tsql = @tsql + QUOTENAME(@fkCol);
            SET @tsql2 = @tsql2 + QUOTENAME(@pkCol);
            FETCH NEXT FROM ColumnCursor INTO @fkCol, @pkCol;
        END;
        CLOSE ColumnCursor;
        DEALLOCATE ColumnCursor;
       SET @tsql = @tsql + ' ) REFERENCES ' + QUOTENAME(@referenced_schema_name) + '.' + QUOTENAME(@referenced_object_name)
                  + ' (' + @tsql2 + ')';
        SET @tsql = @tsql
                  + ' ON UPDATE ' + CASE @update_referential_action
                                        WHEN 0 THEN 'NO ACTION '
                                        WHEN 1 THEN 'CASCADE '
                                        WHEN 2 THEN 'SET NULL '
                                        ELSE 'SET DEFAULT '
                                    END
                  + ' ON DELETE ' + CASE @delete_referential_action
                                        WHEN 0 THEN 'NO ACTION '
                                        WHEN 1 THEN 'CASCADE '
                                        WHEN 2 THEN 'SET NULL '
                                        ELSE 'SET DEFAULT '
                                    END
                  + CASE @is_not_for_replication
                        WHEN 1 THEN ' NOT FOR REPLICATION '
                        ELSE ''
                    END
                  + ';';
        END;
    PRINT @tsql;
    IF @action = 'CREATE'
        BEGIN
        SET @tsql = 'ALTER TABLE '
                  + QUOTENAME(@schema_name) + '.' + QUOTENAME(@table_name)
                  + CASE @is_disabled
                        WHEN 0 THEN ' CHECK '
                        ELSE ' NOCHECK '
                    END
                  + 'CONSTRAINT ' + QUOTENAME(@constraint_name)
                  + ';';
        PRINT @tsql;
        END;
    FETCH NEXT FROM FKcursor INTO @schema_name, @table_name, @constraint_name
        , @referenced_object_name, @constraint_object_id
        , @is_disabled, @is_not_for_replication, @is_not_trusted
        , @delete_referential_action, @update_referential_action, @referenced_schema_name;
END;
CLOSE FKcursor;
DEALLOCATE FKcursor;



-- Script to Create All Foreign Keys
--***************************************************************
-- OR:
/*
The below script can be used to drop and recreate the Foreign Key Constraints on a database.

In this script we are using a temporary tables to select the existing foreign keys 
 and the respective column name and table name.
 Then we determine the primary key table and column name and accordingly 
 drop and recreate them. I am sure there would be many other ways to do this too,
 but this script would do it in one instance.
*/

SET NOCOUNT ON

DECLARE @table TABLE(
RowId INT PRIMARY KEY IDENTITY(1, 1),
ForeignKeyConstraintName NVARCHAR(200),
ForeignKeyConstraintTableSchema NVARCHAR(200),
ForeignKeyConstraintTableName NVARCHAR(200),
ForeignKeyConstraintColumnName NVARCHAR(200),
PrimaryKeyConstraintName NVARCHAR(200),
PrimaryKeyConstraintTableSchema NVARCHAR(200),
PrimaryKeyConstraintTableName NVARCHAR(200),
PrimaryKeyConstraintColumnName NVARCHAR(200)
)

INSERT INTO @table(ForeignKeyConstraintName, ForeignKeyConstraintTableSchema, ForeignKeyConstraintTableName, ForeignKeyConstraintColumnName)
SELECT
U.CONSTRAINT_NAME,
U.TABLE_SCHEMA,
U.TABLE_NAME,
U.COLUMN_NAME
FROM
INFORMATION_SCHEMA.KEY_COLUMN_USAGE U
INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS C ON U.CONSTRAINT_NAME = C.CONSTRAINT_NAME
WHERE
C.CONSTRAINT_TYPE = 'FOREIGN KEY'

UPDATE @table SET
PrimaryKeyConstraintName = UNIQUE_CONSTRAINT_NAME
FROM
@table T
INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS R ON T.ForeignKeyConstraintName = R.CONSTRAINT_NAME

UPDATE @table SET
PrimaryKeyConstraintTableSchema = TABLE_SCHEMA,
PrimaryKeyConstraintTableName = TABLE_NAME
FROM @table T
INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS C
ON T.PrimaryKeyConstraintName = C.CONSTRAINT_NAME

UPDATE @table SET
PrimaryKeyConstraintColumnName = COLUMN_NAME
FROM @table T
INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE U
ON T.PrimaryKeyConstraintName = U.CONSTRAINT_NAME

SELECT * FROM @table

--DROP CONSTRAINT:
SELECT
'
ALTER TABLE [' + ForeignKeyConstraintTableSchema + '].[' + ForeignKeyConstraintTableName + ']
DROP CONSTRAINT ' + ForeignKeyConstraintName + '

GO'
FROM
@table

--ADD CONSTRAINT:
SELECT
'
ALTER TABLE [' + ForeignKeyConstraintTableSchema + '].[' + ForeignKeyConstraintTableName + ']
ADD CONSTRAINT ' + ForeignKeyConstraintName + ' FOREIGN KEY(' + ForeignKeyConstraintColumnName + ') REFERENCES [' + PrimaryKeyConstraintTableSchema + '].[' + PrimaryKeyConstraintTableName + '](‘ + PrimaryKeyConstraintColumnName + ‘)

GO'
FROM
@table

GO