/****************************************
		Manutenção e Reindexação 
****************************************/

set nocount on

declare @comando varchar(255)
declare @comando1 varchar(255)
declare @comando2 varchar(255)
declare @comando3 varchar(255)
declare @comando4 varchar(255)
declare @tabela varchar (100)
declare @database varchar (225)

declare base cursor for 

SELECT distinct TABLE_CATALOG FROM INFORMATION_SCHEMA.TABLES

open base

fetch next from base into @database


declare tabelas cursor for 
select name from sysobjects where type='U' order by name

open tabelas

fetch next from tabelas into @tabela

while @@fetch_status=0


begin

 print 'Reindexando os indices da Tabela '+ @tabela
 set @comando = 'dbcc dbreindex ('+@tabela+') WITH NO_INFOMSGS' 
 exec (@comando)
 print '---------------------------------------------'
 print ' '
 print 'Verificando estrututura da tabela '+ @tabela
 set @comando1 ='dbcc checktable ('+@tabela+') WITH NO_INFOMSGS'
 exec (@comando1)
 print '---------------------------------------------'
 print ' '
 print 'Verificando espaco alocado na tabela'+@tabela
 set @comando2= 'dbcc updateusage ('+@database+','+@tabela+') WITH NO_INFOMSGS'
 exec (@comando2)
 print '---------------------------------------------'
 print ' '
 fetch next from tabelas into @tabela
end

Print 'Final da Manuntencao'
print '*******************************************************************************************'
print '**********************************************************************************'
print '***************************************************************'
close base
close tabelas
deallocate tabelas
deallocate base