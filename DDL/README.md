# Xello CC3_Database

## Project to build Xello CC3 Database

References:

> Links on Confluence:

http://confluence.careercruising.com:8090/display/IS/DDL+Scripting+Recipes

http://confluence.careercruising.com:8090/display/DT/SQL+Coding+Standards


> More info:

http://confluence.careercruising.com:8090/display/IS/SQL+Joins+Illustration+Diagram

http://confluence.careercruising.com:8090/display/IS/Database+Maintenance

http://confluence.careercruising.com:8090/display/IS/Azure+SQL+Database+Connection+and+Maintenance


> Database Identity Seeds:

http://confluence.careercruising.com:8090/display/IS/Database+Identity+Seeds


---------
# Table of Contents

- [Overview](#overview)
- [Overall Build Process](#overall-build-process)
- [Where to Place Upgrade Code](#where-to-place-upgrade-code)
  * [Build Database Process in Details](#build-database-process-in-details)
    + [1 - Create Database](#1---create-database)
    + [2 - Upgrade Database](#2---upgrade-database)
- [DDL Scripting Recipes](#ddl-scripting-recipes)
  * [Table-Valued Functions](#table-valued-functions)
  * [Scalar-Valued Functions](#scalar-valued-functions)
  * [Views](#views)
  * [Stored Procedures](#stored-procedures)
- [Useful Scripts](#useful-scripts)
  * [Getting a List of all Foreign Key References](#getting-a-list-of-all-foreign-key-references)
  * [Adding Column to Table](#adding-column-to-table)
  * [Removing Column from Table](#removing-column-from-table)
  * [Renaming Column](#renaming-column)
  * [Upcasting - Changing Column Data Type](#upcasting---changing-column-data-type)
  * [Downcasting - Changing Column Data Type](#downcasting---changing-column-data-type)
  * [Add New Index](#add-new-index)
  * [Drop Existing Index](#drop-existing-index)
  * [Change Existing Index](#change-existing-index)
  * [Drop Table](#drop-table)
  * [Add New Table](#add-new-table)
  * [Add Foreign Key Constraint](#add-foreign-key-constraint)
  * [Remove Foreign Key Constraint](#remove-foreign-key-constraint)
  * [Add a Record](#add-a-record)
  * [Remove a Record](#remove-a-record)
  * [Update a Record](#update-a-record)
  * [Changing a Default Column Value](#changing-a-default-column-value)
- [SQL Coding Standards](#sql-coding-standards)
  * [Naming Conventions](#naming-conventions)
  * [Data Types](#data-types)
  * [Formatting](#formatting)
  * [Writing Robust Code](#writing-robust-code)
- [Performance Related](#performance-related)
  * [General Performance Guidelines](#general-performance-guidelines)
  * [Avoid Function Operations on Columns in the WHERE clause](#avoid-function-operations-on-columns-in-the-where-clause)
  * [Avoid udf Calls that Perform a Query](#avoid-udf-calls-that-perform-a-query)
  * [Use Temp Tables to Pass Arrays to SQL](#use-temp-tables-to-pass-arrays-to-sql)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

----------


# Overview

This document describes common scenarios that would result in the alteration of a database model, and how to defensively script these out so that existing databases can be upgraded in-place, safely and effectively.

# Overall Build Process

The overall build process will be fairly straightforward. First, the **upgrade** scripts will run.
These scripts will modify tables, indexes, constraints, and other schema objects.
After that, all the scripts in the functions, then views, then procedures folder will be applied, regardless of whether or not anything has changed.
This has the benefit of allowing us to maintain all T-SQL scripts in one place for both full deploys and upgrades.

# Where to Place Upgrade Code

The build system will run all the scripts in the following order:

- UpgradeScripts
- Functions
- Views
- StoredProcedures

Code in any of the folders not listed above will only be run on local deploys
(CreateDatabase.bat – where the database is dropped and recreated).

Upgrade scripts run first because these are the scripts making changes to tables and columns -
objects that will potentially be required by code in the next 3 folders.

For any changes to the database schema, or to data, place these in the _UpgradeScripts_ folder.

For any changes to SQL code (functions/views/stored procedures), please follow these conventions listed below.

---------
## Build Database Process in Details

The build process is composed by two scripts.

The first one can be used to create a new local Database and the second one is used to Upgrade the Dabatase, applying necessary changes.

### 1 - Create Database

Run this to create a new LOCAL database,

**Note:** this also runs for Pull Request checks - DB test build on Jenkins - when you make changes and create a Pull Request on Github, we first create a new temp database to make sure the build process is consistent, and you are not breaking or forgetting anything.

**CreateDatabae** will run on jenkins only (not used by Octopus).

The Server, Database, Username, Password are parameters passed to the script:

```call CreateDatabase.bat [Server] [Database] [username] [password]```

For example:

```call CreateDatabase.bat localhost\sqlexpress CC3_local username password```


Inside each folder there is a ".bat" script to load and execute all ".sql" files inside that folder.

The CreateDatabase script will execute in the following order:
```
Create Database Steps:
	*[Drop and Create a new empty Database]
	ECHO ... Creating Assemblies .......... CALL .\Assemblies\CreateAssemblies.bat
	ECHO ... Creating Schemas ............. CALL .\Schemas\CreateSchemas.bat
	ECHO ... Creating Synonyms ............ CALL .\Synonyms\CreateSynonyms.bat
	ECHO ... Creating Sequences ........... CALL .\Sequences\CreateSequences.bat
	ECHO ... Creating Types ............... CALL ..\Types\CreateTypes.bat
	ECHO ... Creating Tables .............. CALL .\Tables\CreateTables.bat
	ECHO ... Creating Foreign Keys ........ CALL .\ForeignKeys\CreateFKs.bat
	ECHO ... Creating UDFs ................ CALL .\Functions\CreateFunctions.bat
	ECHO ... Creating Views ............... CALL .\Views\CreateViews.bat
	ECHO ... Creating Stored Procedures ... CALL .\StoredProcedures\CreateSprocs.bat
	ECHO ... Creating Users and Logins .... CALL .\Security\CreateSecurity.bat
	ECHO ... Generating Default Data ...... CALL .\Data\Default\CreateDefaultData.bat
	ECHO ... Generating Test Data ......... CALL .\Data\TestData\CreateTestData.bat
	ECHO ... Running Unit Tests ........... CALL .\StoredProcedures\UnitTests\RunUnitTests.bat
```

### 2 - Upgrade Database

This process runs in all environment to update the database to the last desired stated.

**Upgrade** will run in all environment by Octopus.

The Server, Database, Username, Password are parameters passed to the script:

```call Upgrade.bat [Server] [Database] [username] [password]```

For example:

```call Upgrade.bat localhost\sqlexpress CC3_local username password```


Inside each folder there is a ".bat" script to load and execute all ".sql" files inside that folder.

The Upgrade script will execute in the following order:
```
Upgrade Database Steps:
	ECHO ... Altering UDFs (Functions) .... CALL .\Functions\CreateFunctions.bat
	ECHO ... Running Upgrade Scripts ...... CALL .\UpgradeScripts\RunUpgradeScripts.bat
	ECHO ... Altering Views ............... CALL .\Views\CreateViews.bat
	ECHO ... Altering Stored Procedures ... CALL .\StoredProcedures\CreateSprocs.bat
```

---------

# DDL Scripting Recipes

Upgrade scripts run first because these are the scripts making changes to tables and columns –
objects that will potentially be required by code in the next 3 folders.

Because this upgrade scripts can run multiple times in the same database, we need to make them consistent and idempotent.

**Idempotent:**
> In computing, an idempotent operation is one that has no additional effect if it is called more than once with the same input parameters. For example, removing an item from a set can be considered an idempotent operation on the set.
>
> An idempotent operation can be repeated an arbitrary number of times and the result will be the same as if it had been done only once. In arithmetic, adding zero to a number is idempotent.

In a nutshell, the **"dbo.ProvisionXXX"** stored procedures will create an empty object if not exists, allowing us to script the "update" or "alter" without checking for its existence before.

<br/>
<br/>

## Table-Valued Functions
```sql
EXEC dbo.ProvisionTableFunction 'dbo', 'udf_GetChildRegions'
GO
ALTER FUNCTION dbo.udf_GetChildRegions(@InstitutionId INTEGER)
RETURNS @Institutions TABLE(RegionId INTEGER)
AS
```

## Scalar-Valued Functions
```sql
EXEC dbo.ProvisionScalarFunction 'dbo', 'udf_GetFilterCondition'
GO
ALTER FUNCTION dbo.udf_GetFilterCondition(@Filters FilterList READONLY)
RETURNS NVARCHAR(MAX)
AS
```

## Views
```sql
EXEC dbo.ProvisionView 'Solr', 'vwAssignments'
GO
ALTER VIEW Solr.vwAssignments
AS
```

## Stored Procedures
```sql
EXEC dbo.ProvisionSproc 'Career', 'ClustersGet';
GO
ALTER PROCEDURE [Career].[ClustersGet]
AS
```

# Useful Scripts

You can use this recipes to check the existence of foreign keys, idexes, columns and so on.

Notes:
- The use of ";" is not mandatory in SQL Server, but it is recommended.
- SELECT * is only acceptable inside the EXISTS ( ) clause because SQL will optimize it.
- Sometimes we use "IF NOT EXISTS" and sometimes "IF EXISTS"


## Getting a List of all Foreign Key References


```sql
SELECT
	obj.name  AS [FK_NAME],
	sch.name  AS [schema_name],
	tab1.name AS [table],
	col1.name AS [column],
	tab2.name AS [referenced_table],
	col2.name AS [referenced_column]
FROM
	sys.foreign_key_columns fkc
	INNER JOIN sys.objects obj ON obj.object_id = fkc.constraint_object_id
	INNER JOIN sys.tables tab1 ON tab1.object_id = fkc.parent_object_id
	INNER JOIN sys.schemas sch ON tab1.schema_id = sch.schema_id
	INNER JOIN sys.columns col1 ON col1.column_id = parent_column_id AND col1.object_id = tab1.object_id
	INNER JOIN sys.tables tab2 ON tab2.object_id = fkc.referenced_object_id
	INNER JOIN sys.columns col2 ON col2.column_id = referenced_column_id AND col2.object_id = tab2.object_id
WHERE
	tab1.name = 'Students';
```

## Adding Column to Table

```sql
IF NOT EXISTS (
		SELECT * FROM information_schema.columns
		WHERE table_schema = 'Education'
			AND table_name = 'SchoolSport'
			AND column_name = 'SportId'
)
BEGIN
	ALTER TABLE Education.SchoolSport ADD SportId INTEGER NOT NULL;
END
```

## Removing Column from Table

```sql
IF EXISTS (
		SELECT * FROM information_schema.columns
		WHERE table_schema = 'Education'
			AND table_name = 'SchoolSport'
			AND column_name = 'SportId'
)
BEGIN
	ALTER TABLE Education.SchoolSport DROP COLUMN SportId;
END
```

## Renaming Column

```sql
IF EXISTS (
		SELECT * FROM information_schema.columns
		WHERE table_schema = 'Education'
			AND table_name = 'SchoolSport'
			AND column_name = 'SportId'
)
BEGIN
	EXEC sp_rename 'Education.SchoolSport.SportId', 'SportId2'
END
```

## Upcasting - Changing Column Data Type

Upcasting refers to a type-safe conversion from a smaller data type to a larger data type.

For example, changing a TINYINT to an INTEGER.

These are type-safe conversions because the entire range of TINYINT values can fit into an INTEGER.

```sql
ALTER TABLE Education.SchoolSport ALTER COLUMN SportId BIGINT NOT NULL
```

## Downcasting - Changing Column Data Type

Downcasting refers to a non type-safe conversion from a larger data type to a smaller data type.

These types of conversions could result in the loss of data and, for that reason, should only be done if you know for certain that the new data type you're using will cover all the possible ranges of values for this column.

An example of downcasting would be going from INTEGER to TINYINT or from VARCHAR(50) to VARCHAR(25).

If you attempt to downcast a column data type and data would be lost, you'll get an error.

For this reason, your script may have to first clean up the data to remove invalid values.

```sql
-- Downcast every pending username to 50 characters before we change data type.
UPDATE dbo.UserAccount SET PendingUserName = LEFT(PendingUserName, 50)

-- Change data type.
ALTER TABLE dbo.UserAccount ALTER COLUMN PendingUserName VARCHAR(50) NOT NULL
```

## Add New Index

```sql
IF NOT EXISTS (
		SELECT i.name, o.name, s.name
		FROM sys.indexes i
		INNER JOIN sys.objects o ON (o.[object_id] = i.[object_id])
		INNER JOIN sys.schemas s ON (s.[schema_id] = o.[schema_id])
		WHERE s.name = 'Student'
			AND o.name = 'StudentProfile'
			AND i.name = 'IX_StudentProfile_UserAccountId'
)
BEGIN
	CREATE INDEX IX_StudentProfile_UserAccountId ON Student.StudentProfile(UserAccountId);
END
```

## Drop Existing Index

```sql
IF EXISTS (
	SELECT i.name, o.name, s.name
	FROM sys.indexes i
	INNER JOIN sys.objects o ON (o.[object_id] = i.[object_id])
	INNER JOIN sys.schemas s ON (s.[schema_id] = o.[schema_id])
	WHERE s.name = 'Student'
		AND o.name = 'StudentProfile'
		AND i.name = 'IX_StudentProfile_UserAccountId'
)
BEGIN
	DROP INDEX Student.StudentProfile.IX_StudentProfile_UserAccountId;
END
```

## Change Existing Index

Here, we can simply drop the existing index and create the same index again (but modified).

```sql
IF EXISTS (
	SELECT i.name, o.name, s.name
	FROM sys.indexes i
	INNER JOIN sys.objects o ON (o.[object_id] = i.[object_id])
	INNER JOIN sys.schemas s ON (s.[schema_id] = o.[schema_id])
	WHERE s.name = 'Student'
		AND o.name = 'StudentProfile'
		AND i.name = 'IX_StudentProfile_UserAccountId'
)
BEGIN
	DROP INDEX Student.StudentProfile.IX_StudentProfile_UserAccountId;
END
GO
CREATE INDEX IX_StudentProfile_UserAccountId ON Student.StudentProfile(UserAccountId) INCLUDE(UserName);
GO
```

## Drop Table

Note: Here, you may need to drop any FK constraints before you'll be able to drop the table.
Check the [Remove Foreign Key Constraint](#Remove-Foreign-Key-Constraint)

```sql
IF EXISTS (
	SELECT *
	FROM information_schema.tables
	WHERE table_schema = 'Student'
		AND table_name = 'StudentProfileExtension'
)
BEGIN
	DROP TABLE Student.StudentProfileExtension;
END
```

## Add New Table

```sql
IF NOT EXISTS (
	SELECT *
	FROM information_schema.tables
	WHERE table_schema = 'Student'
		AND table_name = 'StudentProfileExtension'
)
BEGIN
	CREATE TABLE Student.StudentProfileExtension
	(
		PortfolioId INTEGER NOT NULL REFERENCES Student.StudentProfile(PortfolioId),
		BikeColor VARCHAR(255) NULL,
		CreatedDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
		ModifiedDate DATETIME2 NOT NULL DEFAULT SYSDATETIME()
	)
END
```

Note: using "REFERENCES" will generate a random name for the Foreign Key making it harder to alter/drop later. I am in favor of using the following approach below.


## Add Foreign Key Constraint

```sql
IF NOT EXISTS (
	SELECT *
	FROM information_schema.TABLE_CONSTRAINTS
	WHERE constraint_type = 'FOREIGN KEY'
		AND constraint_name = 'FK_ReportVisualization_ReportId'
)
BEGIN
	ALTER TABLE School.ReportVisualization
		ADD CONSTRAINT FK_ReportVisualization_ReportId
		FOREIGN KEY (ReportId) REFERENCES School.Report(ReportId);
END
GO
```

## Remove Foreign Key Constraint

```sql
IF EXISTS (
	SELECT *
	FROM information_schema.TABLE_CONSTRAINTS
	WHERE constraint_type = 'FOREIGN KEY'
		AND constraint_name = 'FK_ReportVisualization_ReportId'
)
BEGIN
	ALTER TABLE School.ReportVisualization DROP CONSTRAINT FK_ReportVisualization_ReportId;
END
GO
```

## Add a Record

```sql
IF NOT EXISTS (
	SELECT *
	FROM School.AccessType
	WHERE TranslationKey = 'CAREERCRUISING_ADMIN'
)
BEGIN
	INSERT INTO School.AccessType(TranslationKey, [Description])
	VALUES('CAREERCRUISING_ADMIN', 'Career Cruising Admin');
END
GO
```

## Remove a Record

This one's sometimes fairly simple – you don't need to do an existence check because a delete where no record exists is benign.

Where you may run into trouble is with foreign keys.

If you're trying to delete a record and there's a foreign key pointing to it, you'll have to delete all records, in the correct table order, that rely on this one record you're trying to delete.

Unravelling this chain can sometimes be tedious, but it does prevent the database from becoming corrupted.

```sql
DELETE FROM School.AccessType WHERE TranslationKey = 'CAREERCRUISING_ADMIN';
```

## Update a Record

Another very easy one because there's no need for an existence check.

```sql
UPDATE School.AccessType SET [Description] = 'CC Admin' WHERE TranslationKey = 'CAREERCRUISING_ADMIN';
```

## Changing a Default Column Value

This one's quite tricky because most **default** constraints do not have a defined name
(they use SQL's auto-generated constraint names, which will be randomly generated on each server).

Because of this, we first have to look up the constraint name, drop it, and recreate it
(ideally with a defined name for easier modifications in the future).
Here's an example:

```sql
DECLARE @ConstraintName NVARCHAR(255)
DECLARE @SQL NVARCHAR(MAX)

SELECT
	@ConstraintName = OBJECT_NAME(dc.object_id)
FROM
	sys.default_constraints dc
	INNER JOIN sys.columns c ON (c.column_id = dc.parent_column_id AND c.object_id = dc.parent_object_id)
WHERE
	SCHEMA_NAME(dc.schema_id) = 'School'
	AND OBJECT_NAME(dc.parent_object_id) = 'SchoolInfo'
	AND c.name = 'CoursePlannerStatusId'
	AND dc.[definition] = '((1))'

IF @ConstraintName IS NOT NULL
BEGIN
	SET @SQL = 'ALTER TABLE School.SchoolInfo DROP CONSTRAINT ' + @ConstraintName;

	EXEC sp_executeSQL @SQL;

	SET @SQL = 'ALTER TABLE School.SchoolInfo ADD CONSTRAINT DF_SchoolInfo_CoursePlannerStatusId DEFAULT 2 FOR CoursePlannerStatusId';

	EXEC sp_executeSQL @SQL;
END
GO
```

---------

# SQL Coding Standards

## Naming Conventions

* All objects MUST be referenced with their schema name at all times (within C# code and within SQL), even if the schema is the default **dbo** schema.
	*   Failure to do so forces a performance hit because SQL to do an extra lookup on the schema during query execution.
	*   There's also a potential for SQL to reference the wrong object if there are two objects with the same name but in different schemas.
	*   For instance, `EXEC PortfolioSave` would be incorrect. The call should be `EXEC dbo.PortfolioSave`

* Table names should be **singular**;
	* for instance, name your table `dbo.Portfolio` rather than `dbo.Portfolios`.
	* Same thing goes for many-to-many tables: instead of `dbo.PortfolioRoles`, use `dbo.PortfolioRole`.

* Objects should be named using **Pascal casing** in which case the first letter of each word is uppercase, while the rest of the identifier is in lowercase.

	*  Examples of **incorrect** names:
		* dbo.portfolioRole,
		* dbo.Portfolio_Role,
		* dbo.[Portfolio Role].
	* The **correct** naming convention is `dbo.PortfolioRole`

* Underscores and spaces should **never be used** in object names with the exception of using underscores when identifying views, indexes, or functions.

* **IDENTITY** columns should always be named in the format `[Table Name]Id` where:
	* `Id` is always capitalized on the first letters and lower case on the second letter.
	* Example: `PortfolioId`, or `LanguageSkillId`

* **Foreign key** columns should always be identical to the primary key of the referenced table.
	* For instance, if `PortId` exists in the `dbo.LanguageSkill` table and references `dbo.Portfolio.PortfolioId`, it should be renamed to match `PortfolioId`.

* **Schema** names should always use **Pascal casing**.
	* Examples include `Student`, `School`, and `Report`
	* The number of schemas inside a database should not exceed 10 - don't get carried away with them.

* The following object types should be named with specific prefixes to identify their type;
	* additionally some formatting rules apply to indexes and constraints to make their meaning clear.


<br/>

| Object Type | Prefix | Naming Convention | Example |
|------------ |------- |------------------ |-------- |
| View | vw_ | vw_[ViewName] | dbo.vw_InactivePortfolios |
| User Defined Functions | udf_ | udf_[UDFName] | dbo.udf_CalculateCreditsTaken() |
| Indexes | ix_ | ix_[TableName]_[Col1]_[Col2]_[etc...] | ix_Portfolio_LastName_FirstName |
| Unique Indexes | ux_ | ux_[TableName]_[Col1]_[Col2]_[etc...] | ux_Portfolio_Email_Password |
| Primary Keys | pk_ | pk_[TableName]_[Col1]_[Col2]_[etc...] | pk_Portfolio_PortfolioID |
| Foreign Keys | fk_ | fk_[CurrentTable]_[FKTable]_[Column] | fk_Portfolio_Country_CountryId |
| Default Constraints | df_ | df_[CurrentTable]_[Column] | df_Portfolio_CreatedDate |
| Check Constraints | chk_ | chk_[CurrentTable]_[Column] | chk_Portfolio_PCSStatus |
| Stored Procedures | Nothing | - | (see below) |

<br/>

**Stored procedures should have no prefix.**

In many companies, the standard is to use "sp_" as the prefix, but this is a big performance hit because "sp_" is a naming convention SQL Server uses internally for system procedures, so by prefixing stored procedures with this prefix, SQL will first do an unnecessary look-up in system procedures folder before it's able to determine the call refers to a non-system stored procedure.

Stored procedures should be named first by the table they operate on and then a verb that describes their operation. Examples:

|Operation|RecommendedName|
|--- |--- |
|Retrieve all languages from dbo.Language|dbo.LanguageGetAll|
|Save a portfolio|dbo.PortfolioSave|
|Generate a list of 20 random interests.|dbo.InterestGetRandom|
|Generate a complex report on military careers chosen by gender.|dbo.MilitaryCareerReportByGender|

<br>

Note: Since this procedure is likely operating on a number of tables,
it's more logical to name the procedure based on the type of report it produces rather than the tables it reads from.

<br/>

## Data Types

* TEXT, NTEXT, and IMAGE is deprecated.
	* Use VARCHAR(MAX), NVARCHAR(MAX), and VARBINARY(MAX) respectively.
* DateTime is deprecated,
	* Use Date, DateTime2 or DateTimeOffset instead (_SQL 2008 and later_)
* You'll also want to swap out any GETDATE() references for SYSDATETIME() which is for DATETIME2 and has a higher precision.
* Hard-coded dates should always be expressed in an unambiguous format `yyyymmddhhmmss`.
* Any other format runs the risk of mixing up the day with the month (for instance 2014-04-02) depending on the server locale settings.

## Formatting

SQL keywords should all be in upper case and SELECT, JOIN, WHERE, GROUP BY and HAVING should all be on their own lines. Take into consideration the following query:

```sql
select p.Gender, count(*) as PortfolioCount from dbo.Portfolio p inner join dbo.LanguageSkill ls ON (ls.PortfolioId = p.PortfolioId) where p.active = 1 group by p.Gender;
```

Should be re-written as follows:

```sql
SELECT p.Gender, COUNT(*) AS PortfolioCount
FROM dbo.Portfolio p
INNER JOIN dbo.LanguageSkill ls ON (ls.PortfolioId = p.PortfolioId)
WHERE p.Active = 1
GROUP BY p.Gender;
```

Use spaces between expressions for better readability.

Instead of a WHERE clause that looks like this:

`WHERE p.status=1 AND ls.LanguageId=1234`

Use:

`WHERE p.status = 1 AND ls.LanguageId = 1234`

When declaring a stored procedure or function, each parameter should be defined on its own line.

Take into consideration the following creation script:

```sql
CREATE PROCEDURE dbo.LanguageSkillSave(@PortfolioId INTEGER, @LanguageId INTEGER, @Language VARCHAR(50)) AS
```

Should be re-written as follows:

```sql
CREATE PROCEDURE dbo.LanguageSkillSave
(
   @PortfolioId INTEGER,
   @LanguageId INTEGER,
   @Language VARCHAR(50)
)
AS
```

## Writing Robust Code

**NEVER** use `SELECT *`!!!!

`SELECT *` causes a performance hit because SQL Server first has to look-up all of the column name metadata before it can actually execute the query.

Worse still, it's non-deterministic: adding, removing, or re-ordering a column in the base table will cause the results to change and could possibly break calling code that expects a specific result set signature.

Never use column numbers in the ORDER BY clause.

Doing so means that if the SELECT list changes and you forget to change the ORDER BY clause, you'll start getting incorrect sorts.

```sql
-- Sort by LastName, then FirstName
SELECT FirstName, LastName, Gender, PortfolioId
FROM dbo.Portfolio
WHERE dbo.SchoolId = 1234
ORDER BY 2, 1
```

Instead it should be written as:

```sql
-- Sort by LastName, then FirstName
SELECT FirstName, LastName, Gender, PortfolioId
FROM dbo.Portfolio
WHERE dbo.SchoolId = 1234
ORDER BY LastName, FirstName
```

Never use query hints:

Avoid `(NOLOCK), (FORCESCAN), (FORCESEEK)` and all the rest.

Overriding the SQL Optimizer can cause huge performance bottlenecks as table sizes and cardinality change.

If you want to read uncommitted transactions use
`SET TRANSACTION ISOLATION LEVEL READ_UNCOMMITTED` instead of (NOLOCK).

No cross-database references in queries. Hard-coding cross-database references makes it much harder to move or rename a database.

Instead use `SYNONYMS` in the current database and point that synonym to the referenced database object.

This will ensure that the cross-referenced object appears in SQL code as if it exists in the current database. If a database migration needs to happen, only the synonyms need to be updated and all in one place.

Every table should have a `CreatedDate` and `ModifiedDate` column, DATETIME2, and both defaulting to SYSDATETIME().

Update: since we have clients in multiple time zones, it is better to use UTC date.

`[CreatedDateUTC] DATETIME2(7) NOT NULL DEFAULT (SYSUTCDATETIME()),`

`[ModifiedDateUTC] DATETIME2(7) NOT NULL DEFAULT (SYSUTCDATETIME()),`


This will be a huge help internally as it provides us with some simple auditing capabilities.

<br/>

# Performance Related

## General Performance Guidelines
<br/>

Here are some performance related suggestions / best practices:

Never create a CLUSTERED key on a UNIQUEIDENTIFIER as the random nature of UNIQUEIDENTIFIERs will result in a lot of disk fragmentation.

**Never use triggers**.

Triggers hurt performance, cause deadlocks, and worst of all, cause unintended side-effects on DML operations. Triggers are often used as hacks where the code would be better suited to be within a stored procedure or in calling code directly.

Every table **must have a primary key and a clustered index** (they can be the one and the same).

Avoid dynamic SQL and cursors whenever possible.

Never use the Data Tuning Advisor. It has no context about database workload outside of what you provide it and most of the time makes poor index suggestions. Indexes should be carefully considered by a human based on the understanding of the entire database workload.

If a table has more than 5 indexes or has a number of wide indexes, the code should probably be refactored such that extraneous indexes can be dropped. **Too many indexes hurt DML performance**.

Avoid excessive use of temp tables. They make for difficult to read code and they generally perform worse than CTE's.

Place `SET NOCOUNT ON` at the top of every stored procedure.

Fully qualify calls to stored procedures with their schema name. This saves SQL Server from having to perform a look-up on the schema when it's generating an execution plan.

`exec dbo.UserAccountGetByUserAccountId`

Avoid `ORDER BY` operations in stored procedures where possible. ORDER BY is a heavy operation and better suited for the application or report to handle.


## Avoid Function Operations on Columns in the WHERE clause

One very common performance related issue is when functions wrap columns in the WHERE clause. As soon as a column is wrapped by a function, any index on that column cannot be used.

**Example #1**

```sql
-- Courses selected in July 2014
SELECT PortfolioID, CourseCode, CourseSelectionTime
FROM dbo.CourseSelections
WHERE YEAR(CourseSelectionTime) = 2014 AND MONTH(CourseSelectionTime) = 7
```

Assuming there's an index on `CourseSelectionTime` column, the query could be improved by re-writing it as follows:

```sql
-- Courses selected in July 2014
SELECT PortfolioId, CourseCode, CourseSelectionTime
FROM dbo.CourseSelections
WHERE CourseSelectionTime >= '20140701' AND CourseSelectdionTime < '20140801'
```

**Example #2**

```sql
-- Filter students by status (which is an INT)
DECLARE @Status TINYINT = 1
SELECT PortfolioId, FirstName, LastName
FROM dbo.Portfolio
WHERE CONVERT(TINYINT, Status) = @Status
```

Assuming there's an index on `Status` column, the query could be improved by re-writing it as follows:

```sql
-- Filter students by status (which is an INT)
DECLARE @Status TINYINT = 1
SELECT PortfolioId, FirstName, LastName
FROM dbo.Portfolio
WHERE Status = CONVERT(INTEGER, @Status)
```

## Avoid udf Calls that Perform a Query

It's often tempting to encapsulate logic within a UDF and use that UDF in a SELECT statement to perform a calculation for each row.

While this creates clean code, it also performs horribly because it's effectively doing a subquery for every row returned by the SELECT statement.

For instance:

```sql
-- Calculate revenue in USD for customer ID 1234 in 2014
SELECT ProductId, SUM(Amount * dbo.udf_ExchangeRate(OrderDate, Currency, 'USD')) AS AmountUSD
FROM dbo.Orders o
WHERE o.CustomerId = 1234 AND o.OrderDate >= '20140101' AND o.OrderDate < '20150101'
GROUP BY ProductId
```

This query makes sense, however, it's going to be very inefficient because of the subqueries.
In this case, the function will be applied to every row in the result set.

This can be even worse if we use a function in a `WHERE` clause. In this case, the function has to be applied to all rows in order to decide if it must be included in the result.

```sql
-- Calculate revenue in USD for customer ID 1234 in 2014
SELECT ProductId, SUM(Amount * dbo.udf_ExchangeRate(OrderDate, Currency, 'USD')) AS AmountUSD
FROM dbo.Orders o
WHERE dbo.udf_ExchangeRate(OrderDate, Currency, 'USD') > 100
GROUP BY ProductId
```

This can be significantly improved by doing a JOIN instead. Here we are using a view instead:

```sql
-- Calculate revenue in USD for customer ID 1234 in 2014
SELECT ProductId, SUM(Amount * r.ExchangeRate) AS AmountUSD
FROM dbo.Orders o
INNER JOIN dbo.vw_ExchangeRates r ON (r.ExchangeDate = o.OrderDate AND r.FromCurrency = o.Currency AND r.ToCurrency = 'USD')
WHERE o.CustomerId = 1234 AND o.OrderDate >= '20140101' AND o.OrderDate < '20150101'
GROUP BY ProductId
```

Note that udf's do perform well in the SELECT clause if they do a calculation but **DO NOT** access any tables.


## Use Temp Tables to Pass Arrays to SQL

Many times a program needs to perform an operation on a number of records;
for instance, saving all 40 matchmaker answers.

Typical ways to handle this include:

1.  Looping in C# and calling the stored procedure 40 times.
2.  Passing through a comma delimited string of values and splitting those values in the stored procedure.

Option #1 is very poor performing because it requires 40 round-trips to the SQL Server.

Option #2 can sometimes work well, but when there are multiple values per row (for instance AnswerId and AnswerTime) the comma delimited string becomes much harder to parse in the stored procedure.

The best performing and cleanest method is to pass a table-valued parameter to the stored procedure.

This is supported by Dapper: [https://gist.github.com/taylorkj/9012616](https://gist.github.com/taylorkj/9012616)

The stored procedure might look like this:

```sql
-- First create the type
CREATE TYPE MatchmakerAnswer AS TABLE
(
   AnswerId INTEGER NOT NULL,
   AnswerTime DATETIME2 NOT NULL
)
-- Create the stored procedure
CREATE PROCEDURE dbo.MatchmakerSave
(
   @PortfolioId INTEGER,
   @Answers MatchmakerAnswer READONLY
)
AS
INSERT INTO dbo.MatchmakerAnswers(PortfolioId, AnswerId, AnswerTime)
SELECT @PortfolioId, AnswerId, AnswerTime
FROM @Answers
GO
```
