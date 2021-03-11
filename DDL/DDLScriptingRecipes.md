# DDL Scripting Recipes

- [Overview](#DDLScriptingRecipes-Overview)
- [Overall Build Process](#DDLScriptingRecipes-OverallBuildProcess)
- [At the end of a Sprint](#DDLScriptingRecipes-AttheendofaSprint)
- [Where to Place Upgrade Code](#DDLScriptingRecipes-WheretoPlaceUpgrade)
  - [Table-Valued Functions](#DDLScriptingRecipes-Table-ValuedFunctio)
  - [Scalar-Valued Functions](#DDLScriptingRecipes-Scalar-ValuedFuncti)
  - [Views](#DDLScriptingRecipes-Views)
  - [Stored Procedures](#DDLScriptingRecipes-StoredProcedures)
- [Useful Scripts](#DDLScriptingRecipes-UsefulScripts)
  - [Getting a List of all Foreign Key References](#DDLScriptingRecipes-GettingaListofallFo)
- [Recipes](#DDLScriptingRecipes-Recipes)
  - [Adding a Column to a Table](#DDLScriptingRecipes-AddingaColumntoaTab)
  - [Removing a Column from a Table](#DDLScriptingRecipes-RemovingaColumnfrom)
  - [Renaming a Column](#DDLScriptingRecipes-RenamingaColumn)
  - [Changing a Column Data Type (Upcasting)](#DDLScriptingRecipes-ChangingaColumnData)
  - [Changing a Column Data Type (Downcasting)](#DDLScriptingRecipes-ChangingaColumnData)
  - [Add New Index](#DDLScriptingRecipes-AddNewIndex)
  - [Drop Existing Index](#DDLScriptingRecipes-DropExistingIndex)
  - [Change Existing Index](#DDLScriptingRecipes-ChangeExistingIndex)
  - [Add New Table](#DDLScriptingRecipes-AddNewTable)
  - [Drop Table ](#DDLScriptingRecipes-DropTable)
  - [Add Foreign Key Constraint](#DDLScriptingRecipes-AddForeignKeyConstr)
  - [Remove Foreign Key Constraint](#DDLScriptingRecipes-RemoveForeignKeyCon)
  - [Add a Record](#DDLScriptingRecipes-AddaRecord)
  - [Remove a Record](#DDLScriptingRecipes-RemoveaRecord)
  - [Update a Record](#DDLScriptingRecipes-UpdateaRecord)
  - [Changing a Default Column Value](#DDLScriptingRecipes-ChangingaDefaultCol)

# Overview

This document describes common scenarios that would result in the alteration of a database model, and how to defensively script these out so that existing databases can be upgraded in-place, safely and effectively.

This document will be updated as new common recipes are uncovered.

# Overall Build Process

The overall build process will be fairly straightforward. First, the upgrade scripts will run. These scripts will modify tables, indexes, constraints, and other schema objects. After that, all the scripts in the functions, then view, then procedures folder will be applied, regardless of whether or not anything has changed. This has the benefit of allowing us to maintain all T-SQL scripts in one place for both full deploys and upgrades.

# At the end of a Sprint

At the end of a sprint, after the production DB deploy, all SQL scripts in the upgrade folder should be dropped (don&#39;t worry they&#39;re backed up in Github anyhow). This will start the next sprint off with a clean slate. At this point there should no schema/procedure differences between a fully deployed local database and the production database.

# Where to Place Upgrade Code

The build system will run all the scripts in the following order:

- UpgradeScripts
- Functions
- Views
- StoredProcedures

Code in any of the folders not circled above will only be run on local deploys (CreateDatabase.bat – where the database is dropped and recreated).

Upgrade scripts run first because these are the scripts making changes to tables and columns – objects that will potentially be required by code in the next 3 folders.

For any changes to the database schema, or to data, place these in the _UpgradeScripts_ folder.

For any changes to SQL code (functions/views/stored procedures), please follow these conventions.

## Table-Valued Functions

EXEC dbo.ProvisionTableFunction &#39;dbo&#39;, &#39;udf\_GetChildRegions&#39;

GO

ALTER FUNCTION dbo.udf\_GetChildRegions(@InstitutionId INTEGER)

RETURNS @Institutions TABLE(RegionId INTEGER)

AS

...

## Scalar-Valued Functions

EXEC dbo.ProvisionScalarFunction &#39;dbo&#39;, &#39;udf\_GetFilterCondition&#39;

GO

ALTER FUNCTION dbo.udf\_GetFilterCondition(@Filters FilterList READONLY)

RETURNS NVARCHAR(MAX)

AS

...

## Views

EXEC dbo.ProvisionView &#39;Solr&#39;, &#39;vwAssignments&#39;

GO

ALTER VIEW Solr.vwAssignments

AS

...

## Stored Procedures

EXEC dbo.ProvisionSproc &#39;Career&#39;, &#39;ClustersGet&#39;;

GO

ALTER PROCEDURE [Career].[ClustersGet]

AS

...

# Useful Scripts

## Getting a List of all Foreign Key References

(you can modify this to filter to a specific table or column)

SELECT obj.name AS FK\_NAME,

sch.name AS [schema\_name],

tab1.name AS [table],

col1.name AS [column],

tab2.name AS [referenced\_table],

col2.name AS [referenced\_column]

FROM sys.foreign\_key\_columns fkc

INNER JOIN sys.objects obj

ON obj.object\_id = fkc.constraint\_object\_id

INNER JOIN sys.tables tab1

ON tab1.object\_id = fkc.parent\_object\_id

INNER JOIN sys.schemas sch

ON tab1.schema\_id = sch.schema\_id

INNER JOIN sys.columns col1

ON col1.column\_id = parent\_column\_id AND col1.object\_id = tab1.object\_id

INNER JOIN sys.tables tab2

ON tab2.object\_id = fkc.referenced\_object\_id

INNER JOIN sys.columns col2

ON col2.column\_id = referenced\_column\_id AND col2.object\_id = tab2.object\_id

# Recipes

## Adding a Column to a Table

IF NOT EXISTS(SELECT \*

FROM information\_schema.columns

WHERE table\_schema = &#39;Education&#39; AND table\_name = &#39;SchoolSport&#39; AND column\_name = &#39;SportId&#39;

)

BEGIN

ALTER TABLE Education.SchoolSport ADD SportId INTEGER NOT NULL;

END

## Removing a Column from a Table

IF EXISTS(SELECT \*

FROM information\_schema.columns

WHERE table\_schema = &#39;Education&#39; AND table\_name = &#39;SchoolSport&#39; AND column\_name = &#39;SportId&#39;

)

BEGIN

ALTER TABLE Education.SchoolSport DROP COLUMN SportId;

END

## Renaming a Column

IF EXISTS(SELECT \*

FROM information\_schema.columns

WHERE table\_schema = &#39;Education&#39; AND table\_name = &#39;SchoolSport&#39; AND column\_name = &#39;SportId&#39;

)

BEGIN

EXEC sp\_rename &#39;Education.SchoolSport.SportId&#39;, &#39;SportId2&#39;

END

## Changing a Column Data Type (Upcasting)

Upcasting refers to a type-safe conversion from a smaller data type to a larger data type. For example, changing a TINYINT to an INTEGER. These are type-safe conversions because the entire range of TINYINT values can fit into an INTEGER.

ALTER TABLE Education.SchoolSport ALTER COLUMN SportId BIGINT NOT NULL

## Changing a Column Data Type (Downcasting)

Downcasting refers to a non type-safe conversion from a larger data type to a smaller data type. These types of conversions could result in the loss of data and, for that reason, should only be done if you know for certain that the new data type you&#39;re using will cover all the possible ranges of values for this column. An example of downcasting would be going from INTEGER to TINYINT or from VARCHAR(50) to VARCHAR(25).  If you attempt to downcast a column data type and data would be lost, you&#39;ll get an error. For this reason, your script may have to first clean up the data to remove invalid values.

-- Downcast every pending username to 50 characters before we change data type.

UPDATE dbo.UserAccount SET PendingUserName = LEFT(PendingUserName, 50)

-- Change data type.

ALTER TABLE dbo.UserAccount ALTER COLUMN PendingUserName VARCHAR(50) NOT NULL

## Add New Index

IF NOT EXISTS(

SELECT i.name, o.name, s.name

FROM sys.indexes i

INNER JOIN sys.objects o ON (o.[object\_id] = i.[object\_id])

INNER JOIN sys.schemas s ON (s.[schema\_id] = o.[schema\_id])

WHERE s.name = &#39;Student&#39; AND o.name = &#39;StudentProfile&#39; AND i.name = &#39;IX\_StudentProfile\_UserAccountId&#39;

)

BEGIN

CREATE INDEX IX\_StudentProfile\_UserAccountId ON Student.StudentProfile(UserAccountId);

END

## Drop Existing Index

IF EXISTS(

SELECT i.name, o.name, s.name

FROM sys.indexes i

INNER JOIN sys.objects o ON (o.[object\_id] = i.[object\_id])

INNER JOIN sys.schemas s ON (s.[schema\_id] = o.[schema\_id])

WHERE s.name = &#39;Student&#39; AND o.name = &#39;StudentProfile&#39; AND i.name = &#39;IX\_StudentProfile\_UserAccountId&#39;

)

BEGIN

DROP INDEX Student.StudentProfile.IX\_StudentProfile\_UserAccountId

END

## Change Existing Index

Here, we can simply drop the existing index and create the same index again (but modified)

IF EXISTS(

SELECT i.name, o.name, s.name

FROM sys.indexes i

INNER JOIN sys.objects o ON (o.[object\_id] = i.[object\_id])

INNER JOIN sys.schemas s ON (s.[schema\_id] = o.[schema\_id])

WHERE s.name = &#39;Student&#39; AND o.name = &#39;StudentProfile&#39; AND i.name = &#39;IX\_StudentProfile\_UserAccountId&#39;

)

BEGIN

DROP INDEX Student.StudentProfile.IX\_StudentProfile\_UserAccountId

END

GO

CREATE INDEX IX\_StudentProfile\_UserAccountId ON Student.StudentProfile(UserAccountId) INCLUDE(UserName);

## Add New Table

IF NOT EXISTS(

SELECT \*

FROM information\_schema.tables

WHERE table\_schema = &#39;Student&#39; AND table\_name = &#39;StudentProfileExtension&#39;

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

## Drop Table

Note: Here, you may need to drop any FK constraints before you&#39;ll be able to drop the table.

IF EXISTS(

SELECT \*

FROM information\_schema.tables

WHERE table\_schema = &#39;Student&#39; AND table\_name = &#39;StudentProfileExtension&#39;

)

BEGIN

DROP TABLE Student.StudentProfileExtension

END

## Add Foreign Key Constraint

IF NOT EXISTS(

SELECT \*

FROM information\_schema.TABLE\_CONSTRAINTS

WHERE constraint\_type = &#39;FOREIGN KEY&#39; AND constraint\_name = &#39;FK\_ReportVisualization\_ReportId&#39;

)

BEGIN

ALTER TABLE School.ReportVisualization ADD CONSTRAINT FK\_ReportVisualization\_ReportId

FOREIGN KEY (ReportId) REFERENCES School.Report(ReportId)

END

GO

## Remove Foreign Key Constraint

IF EXISTS(

SELECT \*

FROM information\_schema.TABLE\_CONSTRAINTS

WHERE constraint\_type = &#39;FOREIGN KEY&#39; AND constraint\_name = &#39;FK\_ReportVisualization\_ReportId&#39;

)

BEGIN

ALTER TABLE School.ReportVisualization DROP CONSTRAINT FK\_ReportVisualization\_ReportId

END

GO

## Add a Record

IF NOT EXISTS (

SELECT \*

FROM School.AccessType

WHERE TranslationKey = &#39;CAREERCRUISING\_ADMIN&#39;

)

BEGIN

INSERT INTO School.AccessType(TranslationKey, [Description])

VALUES(&#39;CAREERCRUISING\_ADMIN&#39;, &#39;Career Cruising Admin&#39;);

END

GO

## Remove a Record

This one&#39;s sometimes fairly simple – you don&#39;t need to do an existence check because a delete where no record exists is benign. Where you may run into trouble is with foreign keys. If you&#39;re trying to delete a record and there&#39;s a foreign key pointing to it, you&#39;ll have to delete all records, in the correct table order, that rely on this one record you&#39;re trying to delete. Unravelling this chain can sometimes be tedious, but it does prevent the database from becoming corrupted.

DELETE FROM School.AccessType WHERE TranslationKey = &#39;CAREERCRUISING\_ADMIN&#39;;

## Update a Record

Another very easy one because there&#39;s no need for an existence check.

UPDATE School.AccessType SET [Description] = &#39;CC Admin&#39; WHERE TranslationKey = &#39;CAREERCRUISING\_ADMIN&#39;;

## Changing a Default Column Value

This one&#39;s quite tricky because most default constraints do not have a defined name (they use SQL&#39;s auto-generated constraint names, which will be randomly generated on each server). Because of this, we first have to look up the constraint name, drop it, and recreate it (ideally with a defined name for easier modifications in the future). Here&#39;s an example:

DECLARE @ConstraintName VARCHAR(255)

DECLARE @SQL NVARCHAR(MAX)

SELECT @ConstraintName = OBJECT\_NAME(dc.object\_id)

FROM sys.default\_constraints dc

INNER JOIN sys.columns c ON (c.column\_id = dc.parent\_column\_id AND c.object\_id = dc.parent\_object\_id)

WHERE SCHEMA\_NAME(dc.schema\_id) = &#39;School&#39; AND OBJECT\_NAME(dc.parent\_object\_id) = &#39;SchoolInfo&#39; AND c.name = &#39;CoursePlannerStatusId&#39; AND dc.[definition] = &#39;((1))&#39;

IF @ConstraintName IS NOT NULL

BEGIN

SET @SQL = &#39;ALTER TABLE School.SchoolInfo DROP CONSTRAINT &#39; + @ConstraintName;

EXEC sp\_executeSQL @SQL;

SET @SQL = &#39;ALTER TABLE School.SchoolInfo ADD CONSTRAINT DF\_SchoolInfo\_CoursePlannerStatusId DEFAULT 2 FOR CoursePlannerStatusId&#39;;

EXEC sp\_executeSQL @SQL;

END

GO