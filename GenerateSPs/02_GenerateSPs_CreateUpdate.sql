
/*

Update Procedure Creation Logic

Generates a drop if exists statement
Generates a parameter list inclusding all columns in the table
Generates and Update Statement

All wrapped in a try catch and transactional

*/


-- set (insert\update)
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[createUpdateSP]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[createUpdateSP]
GO

CREATE FUNCTION dbo.createUpdateSP
(
	@spSchema varchar(200),
	@spTable varchar(200)
)
RETURNS varchar(max)
AS
BEGIN

	declare @SQL_DROP varchar(max)
	declare @SQL varchar(max)
	declare @COLUMNS varchar(max)
	declare @PK_COLUMN varchar(200)
	
	set @SQL = ''
	set @SQL_DROP = ''
	set @COLUMNS = ''
	
	-- generate the drop
	set @SQL_DROP = @SQL_DROP + 'IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[' + @spSchema + '].[update' + @spTable + ']'') AND type in (N''P'', N''PC''))' + char(13)
	set @SQL_DROP = @SQL_DROP + 'DROP PROCEDURE [' + @spSchema + '].[update' + @spTable + ']'
	
	set @SQL = @SQL + 'CREATE PROC [' + @spSchema + '].[update' + @spTable + ']' + char(13)
	set @SQL = @SQL + '(' + char(13)
	
	-- now put all the table columns in
	set @PK_COLUMN = 
	(
	select c.column_name
	from information_schema.table_constraints pk 
	inner join information_schema.key_column_usage c 
		on c.table_name = pk.table_name 
		and c.constraint_name = pk.constraint_name
	where pk.TABLE_SCHEMA = @spSchema
		and pk.TABLE_NAME = @spTable
		and pk.constraint_type = 'primary key'
		and c.column_name in
			(
			select COLUMN_NAME
			from INFORMATION_SCHEMA.COLUMNS
			where columnproperty(object_id(quotename(@spSchema) + '.' + 
			quotename(@spTable)), COLUMN_NAME, 'IsIdentity') = 1
			group by COLUMN_NAME
			)
	group by column_name
	having COUNT(column_name) = 1
	)
	
	select @COLUMNS = @COLUMNS + '@' + COLUMN_NAME 
			+ ' as ' 
			+ (case DATA_TYPE when 'numeric' then DATA_TYPE + '(' + convert(varchar(10), NUMERIC_PRECISION) + ',' + convert(varchar(10), NUMERIC_SCALE) + ')' else DATA_TYPE end)
			+ (case when CHARACTER_MAXIMUM_LENGTH is not null then '(' + case when CONVERT(varchar(10), CHARACTER_MAXIMUM_LENGTH) = '-1' then 'max' else CONVERT(varchar(10), CHARACTER_MAXIMUM_LENGTH) end + ')' else '' end)
			+ (case 
				when IS_NULLABLE = 'YES'
					then
						case when COLUMN_DEFAULT is null
							then ' = Null'
							else ''
						end
					else
						case when COLUMN_DEFAULT is null
							then ''
							else
								case when COLUMN_NAME = @PK_COLUMN
									then ''
									else
										case when COLUMN_NAME = @PK_COLUMN
										then ''
										else ' = ' + replace(replace(COLUMN_DEFAULT, '(', ''), ')', '')
									end
								end
						end
				end)
			+ ',' + char(13) 
	from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA = @spSchema and TABLE_NAME = @spTable
	order by ORDINAL_POSITION
	
	set @SQL = @SQL + left(@COLUMNS, len(@COLUMNS) - 2) + char(13)
	
	set @SQL = @SQL + ')' + char(13)
	set @SQL = @SQL + 'AS' + char(13)
	set @SQL = @SQL + '' + char(13)
	
	-- metadata here
	set @SQL = @SQL + '-- Author: Auto' + char(13)
	set @SQL = @SQL + '-- Created: ' + convert(varchar(11), getdate(), 106) + char(13)
	set @SQL = @SQL + '-- Function: Create or update a ' + @spSchema + '.' + @spTable + ' table record' + char(13)
	set @SQL = @SQL + '' + char(13)
	set @SQL = @SQL + '-- Modifications:' + char(13)
	set @SQL = @SQL + '' + char(13)
	
	-- body here
	
	-- Update the database in a transaction
	set @SQL = @SQL + 'begin transaction' + char(13) + char(13)
	
	set @SQL = @SQL + 'begin try' + char(13) + char(13) 
	
	set @SQL = @SQL + '-- update' + char(13)
	
	-- code the update
	set @COLUMNS = ''
	
	set @SQL = @SQL + 'update [' + @spSchema + '].[' + @spTable + '] set' + char(13)
	
	select @COLUMNS = @COLUMNS + '		' + COLUMN_NAME + ' = coalesce(@' + COLUMN_NAME + ', ' + COLUMN_NAME + '),' + char(13)
	from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA = @spSchema and TABLE_NAME = @spTable
		and COLUMN_NAME <> @PK_COLUMN
	order by ORDINAL_POSITION
	
	set @SQL = @SQL + left(@COLUMNS, len(@COLUMNS) - 2) + char(13)
	
	set @SQL = @SQL + 'where ' + @PK_COLUMN + ' = @' + @PK_COLUMN + char(13) + char(13)
	
	set @SQL = @SQL + 'select @' + @PK_COLUMN + char(13) + char(13)
	
	set @SQL = @SQL + 'commit transaction;' + char(13) + char(13)
	
	set @SQL = @SQL + 'end try' + char(13) + char(13)
	
	set @SQL = @SQL + 'begin catch' + char(13) + char(13)  
		
	set @SQL = @SQL + '	declare @ErrorMessage NVARCHAR(4000);' + char(13)
	set @SQL = @SQL + '	declare @ErrorSeverity INT;' + char(13)
	set @SQL = @SQL + '	declare @ErrorState INT;' + char(13) + char(13)
	set @SQL = @SQL + '	select @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();' + char(13) + char(13)
	set @SQL = @SQL + '	raiserror (@ErrorMessage, @ErrorSeverity, @ErrorState);' + char(13) + char(13)
	set @SQL = @SQL + '	rollback transaction' + char(13) + char(13)  
	
	set @SQL = @SQL + 'end catch;' + char(13) + char(13)
	
	RETURN @SQL_DROP + '||' + @SQL

END
GO