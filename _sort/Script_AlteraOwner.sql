-- Gera um script com todos os objetos com owner <> de dbo
-- Para alterar o owner dos objetos para dbo, basta executar o script gerado

select 'exec sp_changeobjectowner "'+ b.name+ '.' +a.name +'","DBO"' 
from sysobjects a Join sysusers b
	on a.uid = b.uid
where a.uid <>1