
set nocount on;
 
-- write the sps we require
 
-- create the local variables
declare @spId int
declare @spSchema varchar(200)
declare @spTable varchar(200)
declare @spInsertSQL varchar(max)
declare @spUpdateSQL varchar(max)
declare @spDeleteSQL varchar(max) 
declare @dropPoint int
declare @drop_sp_sql varchar(max)
declare @create_sp_sql varchar(max)
declare @spsToWrite table(spId int identity(1,1), spSchema varchar(200), spTable varchar(200))
 
-- populate the list of tables to process
insert into @spsToWrite(spSchema, spTable)
select ist.TABLE_SCHEMA, ist.TABLE_NAME
from INFORMATION_SCHEMA.TABLES ist
inner join 
(
select c.table_schema, c.table_name
from information_schema.table_constraints pk 
inner join information_schema.key_column_usage c 
	on c.table_name = pk.table_name 
	and c.constraint_name = pk.constraint_name
where pk.constraint_type = 'primary key'
	and c.column_name in
		(
		select COLUMN_NAME
		from INFORMATION_SCHEMA.COLUMNS
		where columnproperty(object_id(quotename(c.table_schema) + '.' + 
		quotename(c.table_name)), COLUMN_NAME, 'IsIdentity') = 1 -- column is an identity column
		group by COLUMN_NAME
		)
group by c.table_schema, c.table_name
having count(c.column_name) = 1 -- table only has one primary key
) tables_with_one_identity_pk
	on ist.table_schema = tables_with_one_identity_pk.table_schema
	and ist.table_name = tables_with_one_identity_pk.table_name
where (ist.TABLE_TYPE = 'BASE TABLE'
	and ist.TABLE_NAME not like 'ddl%' 
	and ist.TABLE_NAME not like 'sys%') -- add any further where clause restrictions here: certain schema, specific table names, etc.
order by TABLE_NAME

begin try
 
	-- get the first table to process
	select @spId = (select top 1 spId from @spsToWrite order by spId)
 
	-- loop through each table and create the desired stored procedures
	while (@spId <> 0)
	begin
 
		select	@spSchema = spSchema,
				@spTable = spTable
		from @spsToWrite
		where spId = @spId
 		
		set @drop_sp_sql = ''
		set @create_sp_sql = ''
 
		-- write an insert procedure for this table
		set @spInsertSQL = dbo.createInsertSP(@spSchema, @spTable)
 			
		set @dropPoint = CHARINDEX('||', @spInsertSQL)
		set @drop_sp_sql = left(@spInsertSQL, @dropPoint - 1)
		set @create_sp_sql = right(@spInsertSQL, len(@spInsertSQL) - (@dropPoint + 1))
 			
		execute(@drop_sp_sql) -- drop any existing procedure
		execute(@create_sp_sql) -- create the new one
 			
		--print @drop_sp_sql
		--print 'GO'
		--print @create_sp_sql
		--print 'GO'
 			
		-- write an update procedure for this table
		set @spUpdateSQL = dbo.createUpdateSP(@spSchema, @spTable)
 			
		set @dropPoint = CHARINDEX('||', @spUpdateSQL)
		set @drop_sp_sql =  left(@spUpdateSQL, @dropPoint - 1)
		set @create_sp_sql =  right(@spUpdateSQL, len(@spUpdateSQL) - (@dropPoint + 1))
 			
		execute(@drop_sp_sql) -- drop any existing procedure
		execute(@create_sp_sql) -- create the new one
 			
		--print @drop_sp_sql
		--print 'GO'
		--print @create_sp_sql
		--print 'GO'
 
		-- write a delete sp for this table
		set @spDeleteSQL = dbo.createDeleteSP(@spSchema, @spTable) -- code in delete
 			
		set @dropPoint = CHARINDEX('||', @spDeleteSQL)
		set @drop_sp_sql =  left(@spDeleteSQL, @dropPoint - 1)
		set @create_sp_sql =  right(@spDeleteSQL, len(@spDeleteSQL) - (@dropPoint + 1))
 			
		execute(@drop_sp_sql) -- drop any existing procedure
		execute(@create_sp_sql) -- create the new one
 			
		--print @drop_sp_sql
		--print 'GO'
		--print @create_sp_sql
		--print 'GO'
 		
		-- delete the table just processed from the working table
		delete from @spsToWrite where spId = @spId
 		
		-- get the next one
		set @spId = 0
		select @spId = (select top 1 spId from @spsToWrite order by spId)
 		
	end
 	
end try
 
begin catch
 
		select	ERROR_NUMBER() AS ErrorNumber,
				ERROR_SEVERITY() AS ErrorSeverity,
				ERROR_STATE() AS ErrorState,
				ERROR_PROCEDURE() AS ErrorProcedure,
				ERROR_LINE() AS ErrorLine,
				ERROR_MESSAGE() AS ErrorMessage;
 
end catch
go
