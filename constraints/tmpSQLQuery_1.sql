DROP FUNCTION IF EXISTS [Inspire].[udf_OpportunityRequestGetClusterMatches];

drop view if exists EmailQueue.vwMessages
drop view if exists School.vwStudentProfile
drop view if exists Spark.vwK2Episode
drop view if exists Spark.vwK2Flag
drop view if exists vwStudentLesson


ALTER TABLE [TestScore].[StudentTest] DROP CONSTRAINT IF EXISTS [PK_TestScore_StudentTest_StudentTestId];


---------------------------------------------------------------------------------------------------

-- columns
Select 
    SCHEMA_NAME(SD.schema_id) as "Schema_Name",
    ST.[name] AS "Table_Name", 
    SD.[name] AS "Column_Name"
FROM sys.tables ST 
    Inner Join sys.syscolumns SC ON ST.[object_id] = SC.[id] 
    Inner Join sys.default_constraints SD ON ST.[object_id] = SD.[parent_object_id] And SC.colid = SD.parent_column_id 
ORDER BY ST.[name], SC.colid

--constraints (DEFAULT_CONSTRAINT)
Select 
    SCHEMA_NAME(ST.schema_id) as "Schema_Name",
    ST.[name] AS "Table_Name",
    SD.[name] AS "Constraint_Name",
    sd.type_desc
FROM sys.tables ST 
    Inner Join sys.syscolumns SC ON ST.[object_id] = SC.[id] 
    Inner Join sys.default_constraints SD ON ST.[object_id] = SD.[parent_object_id] And SC.colid = SD.parent_column_id 
ORDER BY ST.[name], SC.colid


--indexes
exec sp_helpindex @objname = 'name'

--indexes
SELECT i.name, *
FROM sys.indexes i
inner join sys.tables t ON t.object_id = i.object_id
WHERE i.type_desc != 'HEAP'

--index simplified
SELECT 
    i.name as index_name, --i.type_desc, i.object_id,
    t.name as table_name, --t.object_id, t.schema_id, 
    SCHEMA_NAME(T.schema_id) as schema_name,
    t.type, t.type_desc
FROM sys.indexes i
    inner join sys.tables t ON t.object_id = i.object_id
    WHERE i.type_desc != 'HEAP'

        -- AND i.name is not null
        -- AND object_id = OBJECT_ID(@tableName) AND is_primary_key = 0 --AND is_unique_constraint = 0;

select * 
FROM sys.tables t
    INNER JOIN sys.indexes i ON t.object_id = i.object_id
    WHERE i.type NOT IN (0, 1, 5)
        AND SCHEMA_NAME(T.schema_id) not IN ('INFORMATION_SCHEMA', 'sys')  AND T.schema_id < 1600

-- IX_HigherEd_Comment_CreatedDateUTC



SELECT * FROM INFORMATION_SCHEMA.TABLES

SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS

SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
    where CONSTRAINT_TYPE not in ('PRIMARY KEY', 'FOREIGN KEY')

SELECT distinct CONSTRAINT_TYPE FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
--('PRIMARY KEY','FOREIGN KEY','CHECK','UNIQUE')

    SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    SELECT * FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS
    SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS

    SELECT * FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
    SELECT * FROM INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE


SELECT * FROM INFORMATION_SCHEMA.COLUMNS  where COLUMN_NAME like '%CreatedDate%'

SELECT * FROM INFORMATION_SCHEMA.COLUMNS  where COLUMN_NAME like '%ModifiedDate%'


    drop view if exists EmailQueue.vwMessages
    drop view if exists School.vwStudentProfile
    drop view if exists School.vwEducatorProfile
    drop view if exists Spark.vwK2Episode
    drop view if exists Spark.vwK2Flag

    drop view if exists vwStudentLesson



SELECT 'alter table ['+ table_schema +'].['+ table_name +'] drop column ['+ COLUMN_NAME +']; go;'
FROM INFORMATION_SCHEMA.COLUMNS 
where COLUMN_NAME like '%CreatedDate%'


SELECT TOP 5 * FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE 





-- Return the name of unique constraint.  
SELECT name  , *
FROM sys.objects  
WHERE type = 'UQ' 
AND OBJECT_NAME(parent_object_id) = N' DocExc';  
GO

-- Delete the unique constraint.  
ALTER TABLE dbo.DocExc   
DROP CONSTRAINT UNQ_ColumnB_DocExc;  
GO

SELECT TOP (100) * FROM sys.schemas

SELECT * from sys.indexes

SELECT * from sys.table_types

SELECT distinct type, type_desc from sys.objects order by 1

select top 10  * from sys.objects

SELECT * FROM sys.objects WHERE type = 'C' 

SELECT * FROM sys.indexes    where name = 'UQ_HigherEd_CalendarEventsEnablementStatus_Name'

SELECT TOP (10) * FROM sys.indexes  WHERE is_primary_key = 1


SELECT TOP (10) * 
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id


SELECT  'ALTER TABLE '+ QUOTENAME(OBJECT_SCHEMA_NAME(OBJECT_ID)) +'.'+ QUOTENAME(OBJECT_NAME(OBJECT_ID)) + ' DROP CONSTRAINT ' + QUOTENAME(name)
FROM sys.indexes WHERE is_primary_key = 1



SELECT 'DROP INDEX ' 
       + QUOTENAME(i.name) 
       + ' ON ' 
       + QUOTENAME(SCHEMA_NAME(t.schema_id)) 
       + '.' 
       + QUOTENAME(t.name)
       + ';'
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
WHERE i.type NOT IN (0, 1, 5)
AND SCHEMA_NAME(t.schema_id) = COALESCE(@SchemaName, SCHEMA_NAME(t.schema_id)) COLLATE DATABASE_DEFAULT
AND t.name = COALESCE(@TableName, t.name) COLLATE DATABASE_DEFAULT

SELECT i.name AS index_name  
    ,i.type_desc  
    ,is_unique  
    ,ds.type_desc AS filegroup_or_partition_scheme  
    ,ds.name AS filegroup_or_partition_scheme_name  
    ,ignore_dup_key  
    ,is_primary_key  
    ,is_unique_constraint  
    ,fill_factor  
    ,is_padded  
    ,is_disabled  
    ,allow_row_locks  
    ,allow_page_locks  
FROM sys.indexes AS i  
INNER JOIN sys.data_spaces AS ds ON i.data_space_id = ds.data_space_id  
WHERE is_hypothetical = 0 AND i.index_id <> 0   
--AND i.object_id = OBJECT_ID('Production.Product');  
GO




declare @table_name nvarchar(256)  
declare @col_name nvarchar(256)  
declare @Command  nvarchar(1000)  

set @table_name = N'users'
set @col_name = N'login'

select @Command = 'ALTER TABLE ' + @table_name + ' drop constraint ' + d.name
    from sys.tables t 
    join sys.indexes d on d.object_id = t.object_id  and d.type=2 and d.is_unique=1
    join sys.index_columns ic on d.index_id=ic.index_id and ic.object_id=t.object_id
    join sys.columns c on ic.column_id = c.column_id  and c.object_id=t.object_id
    where t.name = @table_name and c.name=@col_name

print @Command