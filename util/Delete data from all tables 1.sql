/*
https://www.sqlteam.com/forums/topic.asp?TOPIC_ID=65341

*/


Set NoCount ON

Declare @tableName varchar(200)
set @tableName=''


While exists
	(	
		--Find all child tables and those which have no relations

		select T.table_name from INFORMATION_SCHEMA.TABLES T
		left outer join INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
		on T.table_name=TC.table_name where (TC.constraint_Type ='Foreign Key'
		or TC.constraint_Type is NULL) and 
		T.table_name not in ('dtproperties','sysconstraints','syssegments')
		and Table_type='BASE TABLE' and T.table_name > @TableName
	)
	

Begin
		Select @tableName=min(T.table_name) from INFORMATION_SCHEMA.TABLES T
		left outer join INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
		on T.table_name=TC.table_name where (TC.constraint_Type ='Foreign Key'
		or TC.constraint_Type is NULL) and 
		T.table_name not in ('dtproperties','sysconstraints','syssegments')
		and Table_type='BASE TABLE' and T.table_name > @TableName

		--Truncate the table
		Exec('Truncate table '+@tableName)

End

set @TableName=''


While exists
	(	
		--Find all Parent tables 

		select T.table_name from INFORMATION_SCHEMA.TABLES T
		left outer join INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
		on T.table_name=TC.table_name where TC.constraint_Type ='Primary Key'
		and T.table_name <>'dtproperties'and Table_type='BASE TABLE' 
		and T.table_name > @TableName		
	)
	

Begin
		Select @tableName=min(T.table_name) from INFORMATION_SCHEMA.TABLES T
		left outer join INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
		on T.table_name=TC.table_name where TC.constraint_Type ='Primary Key'
		and T.table_name <>'dtproperties'and Table_type='BASE TABLE' 
		and T.table_name > @TableName

		--Delete the table
		Exec('Delete from '+@tableName)

		--Reset identity column 
	If exists(
		SELECT * FROM information_schema.columns 
		WHERE COLUMNPROPERTY(OBJECT_ID( 
		QUOTENAME(table_schema)+'.'+QUOTENAME(@tableName)), 
		column_name,'IsIdentity')=1
	) 
	
	DBCC CHECKIDENT (@tableName, RESEED, 0)

End

Set NoCount Off

go




-- Delete data from all tables:
Set NoCount ON

Declare @tableName varchar(200)
set @tableName=''

While exists
	(	
		--Find all child tables and those which have no relations

		select T.table_name from INFORMATION_SCHEMA.TABLES T
		left outer join INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
		on T.table_name=TC.table_name where (TC.constraint_Type ='Foreign Key' or TC.constraint_Type is NULL) 
		and T.table_name not in ('dtproperties','sysconstraints','syssegments')
		and Table_type='BASE TABLE' and T.table_name > @TableName
	)
Begin
		Select @tableName = t.TABLE_SCHEMA +'.'+ t.TABLE_NAME --min(T.table_name)
		from INFORMATION_SCHEMA.TABLES T
		left outer join INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
		on T.table_name=TC.table_name where (TC.constraint_Type ='Foreign Key' or TC.constraint_Type is NULL) 
		and T.table_name not in ('dtproperties','sysconstraints','syssegments')
		and Table_type='BASE TABLE' and T.table_name > @TableName

		--Truncate the table
		print @tablename
		Exec('Truncate table '+ @tableName)
End

set @TableName=''
While exists
	(	
		--Find all Parent tables 

		select T.table_name from INFORMATION_SCHEMA.TABLES T
		left outer join INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
		on T.table_name=TC.table_name where TC.constraint_Type ='Primary Key'
		and T.table_name <>'dtproperties'and Table_type='BASE TABLE' 
		and T.table_name > @TableName		
	)
Begin
		Select @tableName = t.TABLE_SCHEMA +'.'+ t.TABLE_NAME --min(T.table_name) 
		from INFORMATION_SCHEMA.TABLES T
		left outer join INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
		on T.table_name=TC.table_name where TC.constraint_Type ='Primary Key'
		and T.table_name <>'dtproperties'and Table_type='BASE TABLE' 
		and T.table_name > @TableName

		--Delete the table
		print @tablename
		Exec('Delete from '+@tableName)

		--Reset identity column 
	If exists(
		SELECT * FROM information_schema.columns 
		WHERE COLUMNPROPERTY(OBJECT_ID( 
		QUOTENAME(table_schema)+'.'+QUOTENAME(@tableName)), 
		column_name,'IsIdentity')=1
	) 
	DBCC CHECKIDENT (@tableName, RESEED, 0)
End

Set NoCount Off






/*
I modified your script little bit...

This batch t-sql deletes data from all the tables in the database.

Here is what it does:
1) Disable all the constraints/triggers for all the tables
2) Delete the data for each child table & stand-alone table
3) Delete the data for all the parent tables
4) Reseed the identities of all tables to its initial value.
5) Enable all the constraints/triggers for all the tables.


Note: This is a batch t-sql code which does not create any object in database.
If any error occurs, re-run the code again. It does not use TRUNCATE statement to delete
the data and instead it uses DELETE statement. Using DELETE statement can increase the
size of the log file and hence used the CHECKPOINT statement to clear the log file after
every DELETE statement.

Imp: You may want to skip CHECKIDENT statement for all tables and manually do it yourself. To skip the CHECKIDENT,
set the variable @skipident to "YES" (By default, its set to "NO")

Usage: replace #database_name# with the database name (that you wanted to truncate) and just execute the script in query analyzer.

*/

use [#database_name#]

Set NoCount ON


Declare @tableName varchar(200)
Declare @tableOwner varchar(100)
Declare @skipident varchar(3)
Declare @identInitValue int

set @tableName = ''
set @tableOwner = ''
set @skipident = 'NO'
set @identInitValue=1

/*
Step 1: Disable all constraints
*/

exec sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
exec sp_MSforeachtable 'ALTER TABLE ? DISABLE TRIGGER ALL'

/*
Step 2: Delete the data for all child tables & those which has no relations
*/

While exists
(
select T.table_name from INFORMATION_SCHEMA.TABLES T
left outer join INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
on T.table_name=TC.table_name where (TC.constraint_Type ='Foreign Key'
or TC.constraint_Type is NULL) and
T.table_name not in ('dtproperties','sysconstraints','syssegments')
and Table_type='BASE TABLE' and T.table_name > @TableName
)


Begin
Select top 1 @tableOwner=T.table_schema,@tableName=T.table_name from INFORMATION_SCHEMA.TABLES T
left outer join INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
on T.table_name=TC.table_name where (TC.constraint_Type ='Foreign Key'
or TC.constraint_Type is NULL) and
T.table_name not in ('dtproperties','sysconstraints','syssegments')
and Table_type='BASE TABLE' and T.table_name > @TableName
order by t.table_name


--Delete the table
Exec('DELETE FROM '+ @tableOwner + '.' + @tableName)

--Reset identity column
If @skipident = 'NO'
If exists(
SELECT * FROM information_schema.columns
WHERE COLUMNPROPERTY(OBJECT_ID(
QUOTENAME(table_schema)+'.'+QUOTENAME(@tableName)),
column_name,'IsIdentity')=1
)
begin
set @identInitValue=1
set @identInitValue=IDENT_SEED(@tableOwner + '.' + @tableName)
DBCC CHECKIDENT (@tableName, RESEED, @identInitValue)
end

checkpoint
End

/*
Step 3: Delete the data for all Parent tables
*/

set @TableName=''
set @tableOwner=''

While exists
(
select T.table_name from INFORMATION_SCHEMA.TABLES T
left outer join INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
on T.table_name=TC.table_name where TC.constraint_Type ='Primary Key'
and T.table_name <>'dtproperties'and Table_type='BASE TABLE'
and T.table_name > @TableName
)


Begin
Select top 1 @tableOwner=T.table_schema,@tableName=T.table_name from INFORMATION_SCHEMA.TABLES T
left outer join INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
on T.table_name=TC.table_name where TC.constraint_Type ='Primary Key'
and T.table_name <>'dtproperties'and Table_type='BASE TABLE'
and T.table_name > @TableName
order by t.table_name

--Delete the table
Exec('DELETE FROM '+ @tableOwner + '.' + @tableName)

--Reset identity column
If @skipident = 'NO'
If exists(
SELECT * FROM information_schema.columns
WHERE COLUMNPROPERTY(OBJECT_ID(
QUOTENAME(table_schema)+'.'+QUOTENAME(@tableName)),
column_name,'IsIdentity')=1
)
begin
set @identInitValue=1
set @identInitValue=IDENT_SEED(@tableOwner + '.' + @tableName)
DBCC CHECKIDENT (@tableName, RESEED, @identInitValue)
end

checkpoint

End

/*
Step 4: Enable all constraints
*/

exec sp_MSforeachtable 'ALTER TABLE ? CHECK CONSTRAINT ALL'
exec sp_MSforeachtable 'ALTER TABLE ? ENABLE TRIGGER ALL'

Set NoCount Off
Go to Top of Page
