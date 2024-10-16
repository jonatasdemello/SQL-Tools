-- CHECK IF OBJECT EXISTS

OBJECT_ID ( '[ database_name . [ schema_name ] . | schema_name . ] object_name' [ ,'object_type' ] )

IF OBJECT_ID (N'dbo.AWBuildVersion', N'U') IS NOT NULL
	DROP TABLE dbo.AWBuildVersion;


IF OBJECT_ID('RealGame.ExpenseOption') IS NULL
	print 'not ok'
	ELSE
	print 'ok'

IF (SELECT OBJECT_ID('RealGame.ExpenseCategory')) IS NULL
	print 'not ok'
	ELSE
	print 'ok'


-------------------------------------------------------------------------------------------------------------------------------
-- System Information Schema Views

SELECT TOP (10) * FROM INFORMATION_SCHEMA.COLUMNS
SELECT TOP (10) * FROM INFORMATION_SCHEMA.ROUTINES
SELECT TOP (10) * FROM INFORMATION_SCHEMA.ROUTINE_COLUMNS
SELECT TOP (10) * FROM INFORMATION_SCHEMA.TABLES
SELECT TOP (10) * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
SELECT TOP (10) * FROM INFORMATION_SCHEMA.VIEWS

SELECT TOP (10) * FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS
SELECT TOP (10) * FROM INFORMATION_SCHEMA.COLUMN_DOMAIN_USAGE
SELECT TOP (10) * FROM INFORMATION_SCHEMA.COLUMN_PRIVILEGES
SELECT TOP (10) * FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
SELECT TOP (10) * FROM INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
SELECT TOP (10) * FROM INFORMATION_SCHEMA.DOMAIN_CONSTRAINTS
SELECT TOP (10) * FROM INFORMATION_SCHEMA.DOMAINS
SELECT TOP (10) * FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
SELECT TOP (10) * FROM INFORMATION_SCHEMA.PARAMETERS
SELECT TOP (10) * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
SELECT TOP (10) * FROM INFORMATION_SCHEMA.SCHEMATA
SELECT TOP (10) * FROM INFORMATION_SCHEMA.TABLE_PRIVILEGES
SELECT TOP (10) * FROM INFORMATION_SCHEMA.VIEW_COLUMN_USAGE
SELECT TOP (10) * FROM INFORMATION_SCHEMA.VIEW_TABLE_USAGE


-------------------------------------------------------------------------------------------------------------------------------

EXEC sp_databases

-- Returns a list of stored procedures in the current environment.
EXEC sp_stored_procedures N'uspLogError', N'dbo', N'AdventureWorks2022', 1;

EXEC sp_stored_procedures 
	[ [ @sp_name = ] 'name' ]   
    [ , [ @sp_owner = ] 'schema']   
    [ , [ @sp_qualifier = ] 'qualifier' ]  
    [ , [@fUsePattern = ] 'fUsePattern' ]

EXEC sp_fkeys 
	@pktable_name = N'Department',
	@pktable_owner = N'HumanResources';  
	
EXEC sp_pkeys 
	@table_name = N'Department',
	@table_owner = N'HumanResources';

	
-- Indexes

sp_helpindex [ @objname = ] 'name'


EXEC sp_indexes 
	@table_server = 'Seattle1',
	@table_name = 'Employee',
	@table_schema = 'HumanResources',
	@table_catalog = 'AdventureWorks2022';


EXEC sp_primarykeys 
	@table_server = N'LONDON1',
	@table_name = N'JobCandidate',
	@table_catalog = N'AdventureWorks2022',
	@table_schema = N'HumanResources';


EXEC sp_foreignkeys 
	@table_server = N'Seattle1',   
	@pktab_name = N'Department',   
	@pktab_catalog = N'AdventureWorks2022';

 
EXEC sp_columns
	@table_name = N'Department',  
	@table_owner = N'HumanResources';
   

SELECT TOP (10) * FROM sys.indexes
SELECT TOP (10) * FROM sys.index_columns


SELECT TOP (10) * FROM sys.objects

-- views
    SELECT TOP (10) * FROM sys.tables
    SELECT TOP (10) * FROM sys.views
    SELECT TOP (10) * FROM sys.procedures
	SELECT TOP (10) * FROM sys.synonyms
	
	SELECT TOP (10) * FROM sys.columns


CREATE NONCLUSTERED INDEX IX_Address_PostalCode
	ON Person.Address (PostalCode)
	INCLUDE (AddressLine1, AddressLine2, City, StateProvinceID);

DROP INDEX IX_Address_PostalCode
    ON Person.Address;


-------------------------------------------------------------------------------------------------------------------------------


/*
	type 	char(2)
	Object type:

		AF = Aggregate function (CLR)
		C = CHECK constraint
		D = DEFAULT (constraint or stand-alone)
		F = FOREIGN KEY constraint
		FN = SQL scalar function
		FS = Assembly (CLR) scalar-function
		FT = Assembly (CLR) table-valued function
		IF = SQL inline table-valued function
		IT = Internal table
		P = SQL Stored Procedure
		PC = Assembly (CLR) stored-procedure
		PG = Plan guide
		PK = PRIMARY KEY constraint
		R = Rule (old-style, stand-alone)
		RF = Replication-filter-procedure
		S = System base table
		SN = Synonym
		SO = Sequence object
		U = Table (user-defined)
		V = View

		Applies to: SQL Server 2012 (11.x) and later.

		SQ = Service queue
		TA = Assembly (CLR) DML trigger
		TF = SQL table-valued-function
		TR = SQL DML trigger
		TT = Table type
		UQ = UNIQUE constraint
		X = Extended stored procedure

		Applies to: SQL Server 2014 (12.x) and later, Azure SQL Database, Azure Synapse Analytics, Analytics Platform System (PDW).

		ST = STATS_TREE

		Applies to: SQL Server 2016 (13.x) and later, Azure SQL Database, Azure Synapse Analytics, Analytics Platform System (PDW).

		ET = External Table

		Applies to: SQL Server 2017 (14.x) and later, Azure SQL Database, Azure Synapse Analytics, Analytics Platform System (PDW).

		EC = Edge constraint


	type_desc
	nvarchar(60) 	Description of the object type:

		AGGREGATE_FUNCTION
		CHECK_CONSTRAINT
		CLR_SCALAR_FUNCTION
		CLR_STORED_PROCEDURE
		CLR_TABLE_VALUED_FUNCTION
		CLR_TRIGGER
		DEFAULT_CONSTRAINT
		EDGE_CONSTRAINT
		EXTENDED_STORED_PROCEDURE
		FOREIGN_KEY_CONSTRAINT
		INTERNAL_TABLE
		PLAN_GUIDE
		PRIMARY_KEY_CONSTRAINT
		REPLICATION_FILTER_PROCEDURE
		RULE
		SEQUENCE_OBJECT
		SERVICE_QUEUE
		SQL_INLINE_TABLE_VALUED_FUNCTION
		SQL_SCALAR_FUNCTION
		SQL_STORED_PROCEDURE
		SQL_TABLE_VALUED_FUNCTION
		SQL_TRIGGER
		SYNONYM
		SYSTEM_TABLE
		TYPE_TABLE
		UNIQUE_CONSTRAINT
		USER_TABLE
		VIEW
*/

