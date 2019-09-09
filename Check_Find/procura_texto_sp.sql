/* 
########################################################################

select id, text from syscomments where text like '%crchinstrutor%'

select name from sysobjects where id 
	in (select id from syscomments where text like '%crchinstrutor%')
*/

exec sp_texto 'crchinstrutor'

alter procedure sp_texto 
( 
  @txt varchar(300)
)
as

/*
  Esta procedure procura um texto dentro das stored procedures


	Existe uma tabela chama SYSCOMMENTS em cada banco do sql server. 
	Nessa tabela esta listado os codigos de todos os objetos criados nesse banco. 
	O comando a seguir retornará todos os IDs dos objetos que tiverem o texto no "Like". 
	depois voce da um select sysobjects e localiza o nome da objeto 
	que tem o codigo retornado pelo select anterior...
*/
declare @txt_like varchar(302)

select @txt_like = '%' + @txt + '%'

select sysobjects.name, syscomments.id, syscomments.text 
  from sysobjects inner join syscomments on sysobjects.id=syscomments.id
where syscomments.id 
	in (select syscomments.id from syscomments where syscomments.text like @txt_like)

-- depois usa:	(para pegar o nome da procedure)
-- select * from sysobjects where id=68247348

return