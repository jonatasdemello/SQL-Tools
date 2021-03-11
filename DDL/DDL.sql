
foreach ($filename in Get-ChildItem -Path $FolderPath -Filter "*.sql") { Invoke-Sqlcmd -ServerInstance ".\SQLEXPRESS" -Database "CC3_CMS_test" -InputFile $filename}


extended properties
https://www.sqlservercentral.com/articles/modifying-and-deleting-extended-properties

https://docs.microsoft.com/en-us/sql/relational-databases/system-functions/sys-fn-listextendedproperty-transact-sql?view=sql-server-ver15

School.SISVendor

    SELECT * FROM information_schema.TABLE_CONSTRAINTS
    WHERE constraint_type = 'FOREIGN KEY' AND constraint_name = 'FK_MigrationLog_SchoolId'

	SELECT * FROM information_schema.columns
    WHERE table_schema = 'PCS' AND table_name = 'LessonSetting' AND column_name = 'IsCoreLesson'

    SELECT i.name, o.name, s.name FROM sys.indexes i
    INNER JOIN sys.objects o ON (o.[object_id] = i.[object_id])
    INNER JOIN sys.schemas s ON (s.[schema_id] = o.[schema_id])
    WHERE s.name = 'PCS' AND o.name = 'StudentExerciseInput' AND i.name = 'IX_StudentExerciseInput_StudentExerciseId_InputId'

	SELECT OBJECT_ID FROM sys.indexes 
	WHERE OBJECT_NAME(object_Id)='Canvas' and name='IX_Canvas_PortfolioId')


	SELECT * FROM information_schema.routines
	WHERE routine_type = 'PROCEDURE' AND routine_schema = 'Education' AND routine_name = 'SchoolGetByCodeList')

	SELECT * FROM information_schema.tables
	WHERE table_schema = 'Education' AND table_name = 'ApprenticeshipProgramCategory')


	SELECT * FROM sys.schemas WHERE [name] = 'qa')

	SELECT * FROM sys.table_types WHERE name = 'FileUpload'

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;

-- Alter tables if they exist
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE table_schema = 'Student' 
	AND table_name = 'CollegeApplication' 
	AND column_name = 'CollegeApplicationStatusId')
BEGIN
	DECLARE @ConstraintName nvarchar(200)
	--Determine DF Constraint name and drop it:
	SELECT @ConstraintName = Name FROM SYS.DEFAULT_CONSTRAINTS 
	WHERE PARENT_OBJECT_ID = OBJECT_ID('Student.CollegeApplication') 
	AND PARENT_COLUMN_ID = (SELECT column_id FROM sys.columns WHERE NAME = N'CollegeApplicationStatusId' 
							AND object_id = OBJECT_ID(N'Student.CollegeApplication'))
	-- Drop the Constraint
	EXEC('ALTER TABLE Student.CollegeApplication DROP CONSTRAINT ' + @ConstraintName)

	ALTER TABLE [Student].CollegeApplication
	DROP COLUMN CollegeApplicationStatusId
END
GO






sp_helpconstraint 'CoursePlanner.CourseGuide'

-- DF__CourseGui__Guild__2E144E70
SELECT * FROM information_schema.TABLE_CONSTRAINTS
		  WHERE constraint_name = 'DF__CourseGui__Guild__2E144E70'

select OBJECT_ID('DF__CourseGui__Guild__2E144E70') 

SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE table_schema = 'CoursePlanner' 
	AND table_name = 'CourseGuide' 
	AND column_name = 'CollegeApplicationStatusId'

select * from sys.default_constraints con
WHERE con.[name] = 'DF__CourseGui__Guild__2E144E70'

select con.[name] as constraint_name,
    schema_name(t.schema_id) + '.' + t.[name]  as [table],
    col.[name] as column_name,
    con.[definition]
from sys.default_constraints con
    left outer join sys.objects t        on con.parent_object_id = t.object_id
    left outer join sys.all_columns col        on con.parent_column_id = col.column_id         and con.parent_object_id = col.object_id
WHERE con.[name] = 'DF__CourseGui__Guild__2E144E70'
order by con.name

select schema_name(t.schema_id) + '.' + t.[name] as [table],
    col.column_id,
    col.[name] as column_name,
    con.[definition],
    con.[name] as constraint_name
from sys.default_constraints con
    left outer join sys.objects t
        on con.parent_object_id = t.object_id
    left outer join sys.all_columns col
        on con.parent_column_id = col.column_id
        and con.parent_object_id = col.object_id
order by schema_name(t.schema_id) + '.' + t.[name], 
    col.column_id
	



EXEC dbo.ProvisionScalarFunction 'CoursePlanner', 'udf_AreSchoolsInSameDCM'
GO 

ALTER FUNCTION util.udf_Check_Column
(
	@SchemaName
	@TableName
	@ColumnName
)
RETURNS INTEGER
AS
BEGIN
    SELECT count(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE constraint_type = 'FOREIGN KEY' AND constraint_name = 'FK_MigrationLog_SchoolId'
END
GO


EXEC dbo.ProvisionScalarFunction 'CoursePlanner', 'udf_AreSchoolsInSameDCM'
GO 

ALTER FUNCTION util.udf_Check_Constraint
(
	@SchemaName
	@constraint_type
	@constraint_name
)
RETURNS INTEGER
AS
BEGIN
    SELECT count(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE constraint_type = 'FOREIGN KEY' AND constraint_name = 'FK_MigrationLog_SchoolId'
END
GO