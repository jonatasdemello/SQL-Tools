

alter table participantes
 alter column PANome varchar(255)
   collate SQL_Latin1_General_CP1_CI_AI


select * from participantes where panome like 'Joao%'

sp_help participantes

--remover indices
drop index participantes.[participantes.IX_Participantes]
drop index participantes.[participantes.participantes0]

drop index participantes.IX_Participantes 
drop index participantes.participantes0


-- mudar para case-insensitive, accent-insensitive
alter table participantes
 alter column PANome varchar(255)
   collate SQL_Latin1_General_CP1_CI_AI

alter table participantes
 alter column PANomeMae varchar(255)
   collate SQL_Latin1_General_CP1_CI_AI


-- criar indice novamente
CREATE  INDEX [IX_Participantes] ON [dbo].[Participantes]([PANome], [PANomeMae], [PALocalNascimento]) ON [PRIMARY]
GO
CREATE  INDEX [participantes0] ON [dbo].[Participantes]([PANome], [PAMunicipios]) ON [PRIMARY]
go





