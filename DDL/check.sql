IF object_id('YourFunctionName', 'FN') IS NOT NULL
BEGIN
    DROP FUNCTION [dbo].[YourFunctionName]
END
GO
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-objects-transact-sql?view=sql-server-ver15
    --FN : Scalar function
    --IF : Inline table-valued function
    --TF : Table-valued-function
    --FS : Assembly (CLR) scalar-function
    --FT : Assembly (CLR) table-valued function



-- Adding a Column to a Table
IF NOT EXISTS(SELECT * FROM information_schema.columns
    WHERE table_schema = 'Education' AND table_name = 'SchoolSport' AND column_name = 'SportId'
)
BEGIN
    ALTER TABLE Education.SchoolSport ADD SportId INTEGER NOT NULL;
END
go

--CREATE 
alter FUNCTION dbo.IsColumnInTable (
	@schemaName varchar(255),
	@tableName varchar(255), 
	@columnName varchar(255)
)
RETURNS bit
--WITH EXECUTE AS CALLER
AS
BEGIN
	declare @result bit = 0
	IF EXISTS(SELECT * FROM information_schema.columns 
		WHERE table_schema = @schemaName AND table_name = @tableName AND column_name = @columnName)
	begin
		set @result = 1
	end
	RETURN @result
END

select dbo.IsColumnInTable('Education','SchoolSport','SportId') -- 0
select dbo.IsColumnInTable('Education','SchoolSport','Sport') -- 1

if exists(select null)
	print 'select return true for null'

IF (select dbo.IsColumnInTable('Education','SchoolSport','SportId')) = 1
	print 'OK'
else
	print 'NOK'

IF EXISTS(select dbo.IsColumnInTable('Education','SchoolSport','Sport')) 
	print 'OK'
else
	print 'NOK'

