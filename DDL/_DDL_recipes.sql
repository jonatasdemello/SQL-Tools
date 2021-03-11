$FolderPath = Get-Location
foreach ($filename in Get-ChildItem -Path $FolderPath -Filter "*.sql") { Invoke-Sqlcmd -ServerInstance ".\SQLEXPRESS" -Database "CC3_CMS_test" -InputFile $filename}

-- DDL Recipes

--Table-Valued Functions

EXEC dbo.ProvisionTableFunction 'dbo', 'udf_GetChildRegions'
GO
ALTER FUNCTION dbo.udf_GetChildRegions(@InstitutionId INTEGER)
RETURNS @Institutions TABLE(RegionId INTEGER)
AS

-- Scalar-Valued Functions
EXEC dbo.ProvisionScalarFunction 'dbo', 'udf_GetFilterCondition'
GO
BEGIN
END
 
ALTER FUNCTION dbo.udf_GetFilterCondition(@Filters FilterList READONLY)
RETURNS NVARCHAR(MAX)
AS
BEGIN
END

-- Views
EXEC dbo.ProvisionView 'Solr', 'vwAssignments'
GO
ALTER VIEW Solr.vwAssignments
AS
BEGIN
END

-- Stored Procedures
EXEC dbo.ProvisionSproc 'Career', 'ClustersGet';
GO
ALTER PROCEDURE [Career].[ClustersGet]
AS
BEGIN
END

-- Useful Scripts

-- Getting a List of all Foreign Key References
SELECT  obj.name AS FK_NAME,
    sch.name AS [schema_name],
    tab1.name AS [table],
    col1.name AS [column],
    tab2.name AS [referenced_table],
    col2.name AS [referenced_column]
FROM sys.foreign_key_columns fkc
INNER JOIN sys.objects obj ON obj.object_id = fkc.constraint_object_id
INNER JOIN sys.tables tab1 ON tab1.object_id = fkc.parent_object_id
INNER JOIN sys.schemas sch ON tab1.schema_id = sch.schema_id
INNER JOIN sys.columns col1 ON col1.column_id = parent_column_id AND col1.object_id = tab1.object_id
INNER JOIN sys.tables tab2 ON tab2.object_id = fkc.referenced_object_id
INNER JOIN sys.columns col2 ON col2.column_id = referenced_column_id AND col2.object_id = tab2.object_id


-- Adding a Column to a Table
IF NOT EXISTS(SELECT * FROM information_schema.columns
    WHERE table_schema = 'Education' AND table_name = 'SchoolSport' AND column_name = 'SportId'
)
BEGIN
    ALTER TABLE Education.SchoolSport ADD SportId INTEGER NOT NULL;
END

-- Removing a Column from a Table
IF EXISTS(SELECT * FROM information_schema.columns
	WHERE table_schema = 'Education' AND table_name = 'SchoolSport' AND column_name = 'SportId'
)
BEGIN
    ALTER TABLE Education.SchoolSport DROP COLUMN SportId;
END

-- Renaming a Column
IF EXISTS(SELECT * FROM information_schema.columns
	WHERE table_schema = 'Education' AND table_name = 'SchoolSport' AND column_name = 'SportId'
)
BEGIN
    EXEC sp_rename 'Education.SchoolSport.SportId', 'SportId2'
END

-- Changing a Column Data Type (Upcasting)

-- Upcasting refers to a type-safe conversion from a smaller data type to a larger data type. 
-- For example, changing a TINYINT to an INTEGER. 
-- These are type-safe conversions because the entire range of TINYINT values can fit into an INTEGER.

ALTER TABLE Education.SchoolSport ALTER COLUMN SportId BIGINT NOT NULL

-- Changing a Column Data Type (Downcasting)

-- Downcasting refers to a non type-safe conversion from a larger data type to a smaller data type. 
-- These types of conversions could result in the loss of data and, for that reason, 
-- should only be done if you know for certain that the new data type you're using will cover 
-- all the possible ranges of values for this column. 
-- An example of downcasting would be going from INTEGER to TINYINT or from VARCHAR(50) to VARCHAR(25).
-- If you attempt to downcast a column data type and data would be lost, you'll get an error. 
-- For this reason, your script may have to first clean up the data to remove invalid values.

-- Downcast every pending username to 50 characters before we change data type.
UPDATE dbo.UserAccount SET PendingUserName = LEFT(PendingUserName, 50)
 
-- Change data type.
ALTER TABLE dbo.UserAccount ALTER COLUMN PendingUserName VARCHAR(50) NOT NULL

-- Add New Index
IF NOT EXISTS(SELECT i.name, o.name, s.name FROM sys.indexes i
    INNER JOIN sys.objects o ON (o.[object_id] = i.[object_id])
    INNER JOIN sys.schemas s ON (s.[schema_id] = o.[schema_id])
    WHERE s.name = 'Student' AND o.name = 'StudentProfile' AND i.name = 'IX_StudentProfile_UserAccountId'
)
BEGIN
    CREATE INDEX IX_StudentProfile_UserAccountId ON Student.StudentProfile(UserAccountId);
END

-- Drop Existing Index
IF EXISTS(SELECT i.name, o.name, s.name FROM sys.indexes i
    INNER JOIN sys.objects o ON (o.[object_id] = i.[object_id])
    INNER JOIN sys.schemas s ON (s.[schema_id] = o.[schema_id])
    WHERE s.name = 'Student' AND o.name = 'StudentProfile' AND i.name = 'IX_StudentProfile_UserAccountId'
)
BEGIN
    DROP INDEX Student.StudentProfile.IX_StudentProfile_UserAccountId
END

-- Change Existing Index

-- Here, we can simply drop the existing index and create the same index again (but modified)
IF EXISTS(SELECT i.name, o.name, s.name
    FROM sys.indexes i
    INNER JOIN sys.objects o ON (o.[object_id] = i.[object_id])
    INNER JOIN sys.schemas s ON (s.[schema_id] = o.[schema_id])
    WHERE s.name = 'Student' AND o.name = 'StudentProfile' AND i.name = 'IX_StudentProfile_UserAccountId'
)
BEGIN
    DROP INDEX Student.StudentProfile.IX_StudentProfile_UserAccountId
END
GO
CREATE INDEX IX_StudentProfile_UserAccountId ON Student.StudentProfile(UserAccountId) INCLUDE(UserName);
GO

-- Add New Table
IF NOT EXISTS(SELECT * FROM information_schema.tables
    WHERE table_schema = 'Student' AND table_name = 'StudentProfileExtension'
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

-- Drop Table 

-- Note: Here, you may need to drop any FK constraints before you'll be able to drop the table.
IF EXISTS(SELECT * FROM information_schema.tables
    WHERE table_schema = 'Student' AND table_name = 'StudentProfileExtension'
)
BEGIN
    DROP TABLE Student.StudentProfileExtension
END

-- Add Foreign Key Constraint
IF NOT EXISTS(SELECT * FROM information_schema.TABLE_CONSTRAINTS
    WHERE constraint_type = 'FOREIGN KEY' AND constraint_name = 'FK_ReportVisualization_ReportId'
)
BEGIN
    ALTER TABLE School.ReportVisualization ADD CONSTRAINT FK_ReportVisualization_ReportId
        FOREIGN KEY (ReportId) REFERENCES School.Report(ReportId)
END
GO

-- Remove Foreign Key Constraint
IF EXISTS(SELECT * FROM information_schema.TABLE_CONSTRAINTS
    WHERE constraint_type = 'FOREIGN KEY' AND constraint_name = 'FK_ReportVisualization_ReportId'
)
BEGIN
    ALTER TABLE School.ReportVisualization DROP CONSTRAINT FK_ReportVisualization_ReportId
END
GO

-- Add a Record
IF NOT EXISTS (SELECT * FROM School.AccessType
    WHERE TranslationKey = 'CAREERCRUISING_ADMIN'
)
BEGIN
    INSERT INTO School.AccessType(TranslationKey, [Description])
    VALUES('CAREERCRUISING_ADMIN', 'Career Cruising Admin');
END
GO

-- Remove a Record

-- This one's sometimes fairly simple – you don't need to do an existence check 
-- because a delete where no record exists is benign. 
-- Where you may run into trouble is with foreign keys. 
-- If you're trying to delete a record and there's a foreign key pointing to it, 
-- you'll have to delete all records, in the correct table order, 
-- that rely on this one record you're trying to delete. 
-- Unravelling this chain can sometimes be tedious, 
-- but it does prevent the database from becoming corrupted.

DELETE FROM School.AccessType WHERE TranslationKey = 'CAREERCRUISING_ADMIN';

-- Update a Record

-- Another very easy one because there's no need for an existence check.
UPDATE School.AccessType SET [Description] = 'CC Admin' WHERE TranslationKey = 'CAREERCRUISING_ADMIN';

-- Changing a Default Column Value

-- This one's quite tricky because most default constraints do not have a defined name 
-- (they use SQL's auto-generated constraint names, which will be randomly generated on each server). 
-- Because of this, we first have to look up the constraint name, drop it, and recreate it 
-- (ideally with a defined name for easier modifications in the future). Here's an example:

DECLARE @ConstraintName VARCHAR(255)
DECLARE @SQL NVARCHAR(MAX)
  
SELECT @ConstraintName = OBJECT_NAME(dc.object_id)
FROM sys.default_constraints dc
INNER JOIN sys.columns c ON (c.column_id = dc.parent_column_id AND c.object_id = dc.parent_object_id)
WHERE SCHEMA_NAME(dc.schema_id) = 'School' AND OBJECT_NAME(dc.parent_object_id) = 'SchoolInfo' AND c.name = 'CoursePlannerStatusId' AND dc.[definition] = '((1))'
  
IF @ConstraintName IS NOT NULL
BEGIN
   SET @SQL = 'ALTER TABLE School.SchoolInfo DROP CONSTRAINT ' + @ConstraintName;  
   EXEC sp_executeSQL @SQL;
     
   SET @SQL = 'ALTER TABLE School.SchoolInfo ADD CONSTRAINT DF_SchoolInfo_CoursePlannerStatusId DEFAULT 2 FOR CoursePlannerStatusId';  
   EXEC sp_executeSQL @SQL;
END
GO 
