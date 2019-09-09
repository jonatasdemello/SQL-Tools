

select top 50 * from logs_navegacao

sp_help logs_navegacao

sp_spaceused 'logs_navegacao'


go
EXEC sp_MSforeachTable @command1="print '?' ", @command2="sp_spaceused '?' "


-- verificar todos os BD
exec sp_MSForEachDB @command1="print '?'" ,@command2="DBCC CHECKDB ('?')"




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