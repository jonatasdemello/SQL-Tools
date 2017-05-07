/*
> 
> Tenho uma tabela EVENTOS, e um campo EVStatus 
> Preciso saber quais store procedures do banco tem algo como: 
> Select ... Where Evstatus=3 
> Porque preciso alterá-las. 
> Ou seja, quais store proceduresm, tem dentro do texto (comandos) a string "EVStatus" 

Existe uma tabela chama SYSCOMMENTS em cada banco do sql server. 
Nessa tabela esta listado os codigos de todos os objetos criados nesse banco. 
voce poderia executar o seguinte comando:
*/
	select id, text from syscomments where text like '%Where Evstatus=3%'

/*
O comando anterior retornará todos os  IDs dos objetos que tiverem o texto no "Like". 
depois voce da um select sysobjects e localiza o nome da objeto que tem o codigo retornado pelo select anterior...
Acredito que com isso da pra fazer..
*/

select id, text from syscomments where text like '%supervisor%'

select * from syscomments where text like '%supervisor%'

select id, text from syscomments where text like '%auxemail%'

exec sp_texto 'crchinstrutor'