
-- using Cursor
begin
	DECLARE @Sql NVARCHAR(500) DECLARE @Cursor CURSOR

	SET @Cursor = CURSOR FAST_FORWARD FOR
	SELECT DISTINCT sql = 'ALTER TABLE [' + tc2.TABLE_SCHEMA + '].[' +  tc2.TABLE_NAME + '] DROP [' + rc1.CONSTRAINT_NAME + '];'
	FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc1
	LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc2 ON tc2.CONSTRAINT_NAME =rc1.CONSTRAINT_NAME

	OPEN @Cursor FETCH NEXT FROM @Cursor INTO @Sql

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
	Exec sp_executesql @Sql
	FETCH NEXT FROM @Cursor INTO @Sql
	END

	CLOSE @Cursor DEALLOCATE @Cursor
end
go


-- using sp_MSforeachtable 
begin

	-- We can easily find out the parameters for the sp_MSforeachtable stored procedure by searching for it in the SQL Server Management Studio (SSMS). 
	-- In SSMS, drill down to 'Databases / System Databases / master / Programmability / Stored Procedures / System Stored Procedures'
	--  and look for sys.sp_MSforeachtable’s parameters: 

	--@command1, @command2, @command3
	--sp_MSforeachtable stored procedure requires at least one command to be executed (@command1) but it allows up to 3 commands to be executed. Note that it will start to execute first the @command1 and then @command2 and @command3 by the last and this for each table.

	--@precommand
	--Use this parameter to provide a command to be executed before the @command1. It is useful to set variable environments or perform any kind of initialization.

	--@postcommand
	--Use this parameter to provide a command to be executed after all the commands being executed successfully. It is useful for control and cleanup processes.
	--@replacechar
	--By default, a table is represented by the question mark (?) character. This parameter allows you to change this character.

	--@whereand
	--By default, sp_MSforeachtable is applied to all user tables in the database. Use this parameter to filter the tables that you want to work with. On the next section, I will explain how you can filter the tables. 

	EXEC sp_MSforeachtable 'DROP TABLE ?'

	-- perform an unconditional reindex over all tables in the database:
	  EXEC sp_MSforeachtable 'DBCC DBREINDEX(''?'')'

	-- truncate all tables in the database:
	  EXEC sp_MSforeachtable 'TRUNCATE TABLE ?'

	-- get the information about the number of records from all tables in the database:
	  EXEC sp_MSforeachtable 'SELECT ''?'' TableName, Count(1) NumRecords FROM ?'

	  	  EXEC sp_msforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT all'
	
	EXEC sp_MSforeachtable 'TRUNCATE TABLE ?' 

end
GO


SELECT 'DROP TABLE [' + SCHEMA_NAME(schema_id) + '].[' + name + ']' FROM sys.tables


SELECT 'TRUNCATE TABLE [' + SCHEMA_NAME(schema_id) + '].[' + name + ']; ' FROM sys.tables order by create_date desc




select * from sys.tables order by create_date

select * from INFORMATION_SCHEMA.TABLES




-- Disable all table constraints
ALTER TABLE YourTableName NOCHECK CONSTRAINT ALL
-- Enable all table constraints
ALTER TABLE YourTableName CHECK CONSTRAINT ALL
-- ----------
-- Disable single constraint
ALTER TABLE YourTableName NOCHECK CONSTRAINT YourConstraint
-- Enable single constraint
ALTER TABLE YourTableName CHECK CONSTRAINT YourConstraint
-- ----------
-- Disable all constraints for database
EXEC sp_msforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT all'
-- Enable all constraints for database
EXEC sp_msforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all'



-- Disable all the constraint in database
EXEC sp_msforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT all'

EXEC sp_msforeachtable 'ALTER TABLE ? WITH NOCHECK CONSTRAINT all'

-- Enable all the constraint in database
EXEC sp_msforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all'

EXEC sp_MSforeachtable 'TRUNCATE TABLE ?' 




-- disable all constraints
EXEC sp_MSForEachTable 'ALTER TABLE ? NOCHECK CONSTRAINT all'

-- delete data in all tables
EXEC sp_MSForEachTable 'DELETE FROM ?'

-- enable all constraints
exec sp_MSForEachTable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all'

EXEC sp_MSForEachTable 'DBCC CHECKIDENT ( '?', RESEED, 0)'


-- wipe all tables

SET QUOTED_IDENTIFIER ON;
EXEC sp_MSforeachtable 'SET QUOTED_IDENTIFIER ON; ALTER TABLE ? NOCHECK CONSTRAINT ALL'  
EXEC sp_MSforeachtable 'SET QUOTED_IDENTIFIER ON; ALTER TABLE ? DISABLE TRIGGER ALL'  
EXEC sp_MSforeachtable 'SET QUOTED_IDENTIFIER ON; DELETE FROM ?'  
EXEC sp_MSforeachtable 'SET QUOTED_IDENTIFIER ON; ALTER TABLE ? CHECK CONSTRAINT ALL'  
EXEC sp_MSforeachtable 'SET QUOTED_IDENTIFIER ON; ALTER TABLE ? ENABLE TRIGGER ALL' 
EXEC sp_MSforeachtable 'SET QUOTED_IDENTIFIER ON';

IF NOT EXISTS (
    SELECT *
    FROM SYS.IDENTITY_COLUMNS
        JOIN SYS.TABLES ON SYS.IDENTITY_COLUMNS.Object_ID = SYS.TABLES.Object_ID
    WHERE  SYS.TABLES.Object_ID = OBJECT_ID('?') AND SYS.IDENTITY_COLUMNS.Last_Value IS NULL
	)
AND OBJECTPROPERTY( OBJECT_ID('?'), 'TableHasIdentity' ) = 1

DBCC CHECKIDENT ('?', RESEED, 0) WITH NO_INFOMSGS;

go






SELECT top 10 * FROM sysobjects WHERE [type] = 'U' AND category = 0 ORDER BY [name]
SELECT TOP 10 * FROM INFORMATION_SCHEMA.TABLES
SELECT TOP 10 * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME

--SELECT @TABLE = (SELECT TOP 1 [name] FROM sysobjects WHERE [type] = 'U' AND category = 0 ORDER BY [name])


-- Drop all VIEWS
DECLARE @TABLE VARCHAR(128)
DECLARE @SQL VARCHAR(254)

SELECT @TABLE = (SELECT TOP 1 TABLE_SCHEMA+'.'+TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='VIEW')

WHILE @TABLE IS NOT NULL
BEGIN
    SELECT @SQL = 'DROP VIEW ' + RTRIM(@TABLE) 
    PRINT @SQL
	EXEC (@SQL)
    PRINT 'Dropped Table: ' + @TABLE
    SELECT @TABLE = (SELECT TOP 1 TABLE_SCHEMA+'.'+TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='VIEW')
END
GO

-- Drop all TABLES
DECLARE @TABLE VARCHAR(128)
DECLARE @SQL VARCHAR(254)

SELECT @TABLE = (SELECT TOP 1 TABLE_SCHEMA+'.'+TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME)

WHILE @TABLE IS NOT NULL
BEGIN
    SELECT @SQL = 'DROP TABLE ' + RTRIM(@TABLE) 
    PRINT @SQL
	EXEC (@SQL)
    PRINT 'Dropped Table: ' + @TABLE
    SELECT @TABLE = (SELECT TOP 1 TABLE_SCHEMA+'.'+TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='VIEW')
END
GO



-- TRUNCATE all TABLES
DECLARE @TABLE VARCHAR(128)
DECLARE @SQL VARCHAR(254)

SELECT @TABLE = (SELECT TOP 1 TABLE_SCHEMA+'.'+TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME)

WHILE @TABLE IS NOT NULL
BEGIN
    SELECT @SQL = 'TRUNCATE TABLE ' + RTRIM(@TABLE) 
    PRINT @SQL
	EXEC (@SQL)
    PRINT 'Dropped Table: ' + @TABLE
    SELECT @TABLE = (SELECT TOP 1 TABLE_SCHEMA+'.'+TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='VIEW')
END
GO



-- Drop all TABLES
DECLARE @TABLE VARCHAR(128)
DECLARE @SQL VARCHAR(254)

SELECT @TABLE = (SELECT TOP 1 TABLE_SCHEMA+'.'+TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME)
SELECT @TABLE = (SELECT TOP 1 CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'FOREIGN KEY' ORDER BY CONSTRAINT_NAME)

WHILE @TABLE IS NOT NULL
BEGIN
    SELECT @SQL = 'DROP TABLE ' + RTRIM(@TABLE) 
    PRINT @SQL
	EXEC (@SQL)
    PRINT 'Dropped Table: ' + @TABLE
    SELECT @TABLE = (SELECT TOP 1 TABLE_SCHEMA+'.'+TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='VIEW')
END
GO



SELECT TOP 20 * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'PRIMARY KEY' ORDER BY TABLE_NAME


-- Drop all Primary Key constraints
DECLARE @SQL VARCHAR(254)
SELECT @SQL = (SELECT TOP 1 ' alter table [' + schema_name(Schema_id)+'].['+ object_name(parent_object_id)+']  DROP CONSTRAINT [' +  name from sys.foreign_keys f1)+']'

WHILE @SQL IS NOT NULL
BEGIN
    PRINT @SQL
	EXEC (@SQL)
    SELECT @SQL = (SELECT TOP 1 ' alter table [' + schema_name(Schema_id)+'].['+ object_name(parent_object_id)+']  DROP CONSTRAINT [' +  name from sys.foreign_keys f1)+']'
END
GO


--DROP ALL FOREIGN KEYS
while(exists(select 1 from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE='FOREIGN KEY'))
begin
	declare @sql nvarchar(2000)
	SELECT TOP 1 @sql=('ALTER TABLE ' + TABLE_SCHEMA + '.[' + TABLE_NAME + '] DROP CONSTRAINT [' + CONSTRAINT_NAME + ']')
	FROM information_schema.table_constraints WHERE CONSTRAINT_TYPE = 'FOREIGN KEY'

	exec (@sql)
end



-- DROP ALL STORES PROC
declare @schemaName varchar(255)
declare @procName varchar(255)
declare cur cursor 

--for select [name] from sys.objects where type = 'p'
	for select SCHEMA_NAME(p.schema_id) AS [schemaName], p.name as [procName] from sys.procedures p where type = 'p'
	open cur
	fetch next from cur into @schemaName, @procName
	while @@fetch_status = 0
	begin
		exec('drop procedure ['+ @schemaName +'].[' + @procName + ']')
		fetch next from cur into @schemaName, @procName
	end
	close cur
	deallocate cur
go

SELECT 'DROP PROCEDURE [' + SCHEMA_NAME(p.schema_id) + '].[' + p.NAME + '];' FROM sys.procedures p


-- *****************************************************************************************************************


while(exists(select 1 from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE='FOREIGN KEY'))
begin
	declare @sql nvarchar(2000)
	SELECT TOP 1 @sql=('ALTER TABLE ' + TABLE_SCHEMA + '.[' + TABLE_NAME + '] DROP CONSTRAINT [' + CONSTRAINT_NAME + ']')
	FROM information_schema.table_constraints WHERE CONSTRAINT_TYPE = 'FOREIGN KEY'

	exec (@sql)
end
go

--  Drop all constraints on a table
-- http://weblogs.asp.net/jgalloway/archive/2006/04/12/442616.aspx

-- t-sql scriptlet to drop all constraints on a table
DECLARE @database nvarchar(50)
DECLARE @table nvarchar(50)

set @database = 'dotnetnuke'
set @table = 'tabs'

DECLARE @sql nvarchar(255)
WHILE EXISTS(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where constraint_catalog = DB_NAME() ) --and table_name = @table)
BEGIN
    select @sql = 'ALTER TABLE ' + @table + ' DROP CONSTRAINT ' + CONSTRAINT_NAME from INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
	Where constraint_catalog = @database and table_name = @table
    
	exec sp_executesql @sql
END


-- Drop all Primary Key constraints
DECLARE @SCHEMA VARCHAR(255)
DECLARE @TABLE VARCHAR(255)
DECLARE @CONSTRAINT VARCHAR(255)
DECLARE @SQL VARCHAR(254)

SELECT TOP 1 @SCHEMA = TABLE_SCHEMA, @TABLE = TABLE_NAME, @CONSTRAINT = CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'PRIMARY KEY' ORDER BY TABLE_NAME

WHILE @TABLE IS NOT NULL
BEGIN
	SELECT @SQL = 'ALTER TABLE '+ RTRIM(@SCHEMA) +'.'+ RTRIM(@TABLE) +' DROP CONSTRAINT ' + RTRIM(@constraint)
    PRINT @SQL
	EXEC (@SQL)
    PRINT 'Dropped Constraint: ' + @CONSTRAINT
    SELECT TOP 1 @SCHEMA = TABLE_SCHEMA, @TABLE = TABLE_NAME, @CONSTRAINT = CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'PRIMARY KEY' ORDER BY TABLE_NAME
END
GO




-- Drop all Primary Key constraints
DECLARE @TABLE VARCHAR(128)
DECLARE @constraint VARCHAR(254)
DECLARE @SQL VARCHAR(254)

SELECT @TABLE = (SELECT TOP 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'PRIMARY KEY' ORDER BY TABLE_NAME)

WHILE @TABLE IS NOT NULL
BEGIN
    SELECT @constraint = (SELECT TOP 1 CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'PRIMARY KEY' AND TABLE_NAME = @TABLE ORDER BY CONSTRAINT_NAME)
    WHILE @constraint is not null
    BEGIN
        SELECT @SQL = 'ALTER TABLE [dbo].[' + RTRIM(@TABLE) +'] DROP CONSTRAINT [' + RTRIM(@constraint)+']'
        print @sql
		EXEC (@SQL)
        PRINT 'Dropped PK Constraint: ' + @constraint + ' on ' + @TABLE
        SELECT @constraint = (SELECT TOP 1 CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'PRIMARY KEY' AND CONSTRAINT_NAME <> @constraint AND TABLE_NAME = @TABLE ORDER BY CONSTRAINT_NAME)
    END
SELECT @TABLE = (SELECT TOP 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'PRIMARY KEY' ORDER BY TABLE_NAME)
END
GO