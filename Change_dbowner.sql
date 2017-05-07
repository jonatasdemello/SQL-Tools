
sp_help [webmaster.noticia]
sp_help noticia

select * from noticia

sp_help [dbsenarpr]


alter table [webmaster.noticia] alter column conteudo varchar(255)

alter table noticia alter column conteudo varchar(255)

alter table [noticia] alter column conteudo varchar(255)



select * from [webmaster.produto]
select * from produto

EXEC sp_changedbowner 'webmaster'

EXEC sp_changedbowner 'sa'

EXEC sp_changeobjectowner 'webmaster.noticia', 'dbo'
EXEC sp_changeobjectowner 'webmaster.acessorio', 'dbo'
EXEC sp_changeobjectowner 'webmaster.departamento', 'dbo'
EXEC sp_changeobjectowner 'webmaster.emprestimo', 'dbo'
EXEC sp_changeobjectowner 'webmaster.funcionario', 'dbo'
EXEC sp_changeobjectowner 'webmaster.produto', 'dbo'
EXEC sp_changeobjectowner 'webmaster.superadmin', 'dbo'
EXEC sp_changeobjectowner 'webmaster.manutencao', 'dbo'

EXEC sp_changeobjectowner 'sistema_W05.PAT_itens', 'dbo'
