

select top 50 * from logs_navegacao

sp_help logs_navegacao

sp_spaceused 'logs_navegacao'


go
EXEC sp_MSforeachTable @command1="print '?' ", @command2="sp_spaceused '?' "


-- verificar todos os BD
exec sp_MSForEachDB @command1="print '?'" ,@command2="DBCC CHECKDB ('?')"




/*
Os par�metros da procedure s�o:

Par�metro 	Obrigat�rio ? Para que serve 
@command1      Sim      Primeiro comando que se deseja executar.  
@command2      N�o      Segundo comando que se deseja executar 
@command3      N�o      Terceiro comando que se deseja executar 
@replacechar   N�o      Caractere que dever� ser substitu�do pelo nome do database nos par�metros @command1..3. Quando n�o especificado, o caractere default ser� o sinal de interroga��o �?�. 
@precommand    N�o      Comando que dever� ser executado ANTES de @command1..3 
@poscommand    N�o      Comando que dever� ser executado AP�S @command1..3 

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