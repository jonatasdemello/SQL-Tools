/*

Syntax
sp_spaceused [[@objname =] 'objname'] 
    [,[@updateusage =] 'updateusage']


Result Sets
If objname is omitted, two result sets are returned.

Column name 		Data type 		Description 
database_name 		varchar(18) 	Name of the current database. 
database_size 		varchar(18) 	Size of the current database. 
unallocated space 	varchar(18) 	Unallocated space for the database. 

Column name 			Data type Description 
reserved varchar(18) 	Total amount of reserved space. 
Data varchar(18) 		Total amount of space used by data. 
index_size varchar(18) 	Space used by indexes. 
Unused varchar(18) 		Amount of unused space. 

If parameters are specified, this is the result set.

Column name 	Data type 			Description
--------------------------------------------------- 
Name 			nvarchar(20) 		Name of the table for which space usage information was requested. 
Rows 			char(11) 			Number of rows existing in the objname table. 
reserved 		varchar(18) 		Amount of total reserved space for objname. 
Data 			varchar(18) 		Amount of space used by data in objname. 
index_			size varchar(18) 	Amount of space used by the index in objname. 
Unused		 	varchar(18) 		Amount of unused space in objname. 

*/


select * from master.dbo.sysdatabases

select * from master.dbo.sysobjects

select * from sysobjects where xtype ='u'




sp_help logs_navegacao

sp_spaceused 'logs_navegacao'

create table #tabEspaco (
tName 			nvarchar(20),		--Name of the table for which space usage information was requested. 
tRows 			char(11), 			--Number of rows existing in the objname table. 
treserved 		varchar(18), 		--Amount of total reserved space for objname. 
tData 			varchar(18), 		--Amount of space used by data in objname. 
tindex_size		varchar(18), 		--Amount of space used by the index in objname. 
tUnused		 	varchar(18), 		--Amount of unused space in objname. 
)

select * from #tabEspaco

insert into #tabEspaco values 

	sp_spaceused 'logs_navegacao'

go
EXEC sp_MSforeachTable @command1="print '?' ", @command2="sp_spaceused '?' "


EXEC sp_MSforeachTable @command1="sp_spaceused '?' "

-- verificar todos os BD
exec sp_MSForEachDB @command1="print '?'" ,@command2="DBCC CHECKDB ('?')"


exec s_SpaceUsed 'senar_prod' 

select * from #tables
select * from #SpaceUsed



if exists (select * from sysobjects where id = object_id(N'[dbo].[s_SpaceUsed]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[s_SpaceUsed]
GO

Create procedure s_SpaceUsed
@SourceDB	varchar(128)
as
	/* exec s_SpaceUsed 'mydb' */

	set nocount on

	declare @sql varchar(128)
	create table #tables(name varchar(128))
	
	select @sql = 'insert #tables select TABLE_NAME from ' + @SourceDB + '.INFORMATION_SCHEMA.TABLES where TABLE_TYPE = ''BASE TABLE'''
	exec (@sql)
	
	create table #SpaceUsed (name varchar(128), rows varchar(11), reserved varchar(18), data varchar(18), index_size varchar(18), unused varchar(18))
	declare @name varchar(128)
	select @name = ''
	while exists (select * from #tables where name > @name)
	begin
		select @name = min(name) from #tables where name > @name
		select @sql = 'exec ' + @SourceDB + '..sp_executesql N''insert #SpaceUsed exec sp_spaceused ' + @name + ''''
		exec (@sql)
	end
	select * from #SpaceUsed
	drop table #tables
	drop table #SpaceUsed
go





/*
Os parâmetros da procedure são:

Parâmetro 	Obrigatório ? Para que serve 
@command1      Sim      Primeiro comando que se deseja executar.  
@command2      Não      Segundo comando que se deseja executar 
@command3      Não      Terceiro comando que se deseja executar 
@replacechar   Não      Caractere que deverá ser substituído pelo nome do database nos parâmetros @command1..3. Quando não especificado, o caractere default será o sinal de interrogação ‘?’. 
@precommand    Não      Comando que deverá ser executado ANTES de @command1..3 
@poscommand    Não      Comando que deverá ser executado APÓS @command1..3 

*/ 

select count(*) from eventos

select name from master.dbo.SysDatabases


/* USANDO UM CURSOR */

declare cr_Cursor cursor fast_forward
for 

     select name from master.dbo.SysDatabases

declare @database varchar(200)
declare @cmd varchar(200)
open cr_Cursor

fetch next from cr_Cursor into @database
while (@@fetch_status <> -1)
begin
          if (@@fetch_status <> -2)
          begin
               set @cmd = 'dbcc checkdb('+''''+@database+''''+')'
                         print ''
               print '-------------------------------------------'
               print '>>>> Database: '+ @database
               print '-------------------------------------------'
                         exec (@cmd)
          end
          fetch next from cr_Cursor into @database
end

close cr_Cursor
deallocate cr_Cursor

/* FIM */