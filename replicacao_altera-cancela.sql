

select * from dbo.Alteracao_Cancelamento where acdtsolicitacao >='2009-01-01'


select max(acid) from Alteracao_Cancelamento

12192


select * from senarprw03.senar_prod.dbo.Alteracao_Cancelamento where acdtsolicitacao >='2009-01-01'

select max(acid) from senarprw03.senar_prod.dbo.Alteracao_Cancelamento

11835


select max(acid) from Alteracao_Cancelamento 
select max(acid) from senarprw03.senar_prod.dbo.Alteracao_Cancelamento 


select * from Alteracao_Cancelamento where acid = 12192
select * from senarprw03.senar_prod.dbo.Alteracao_Cancelamento where acid = 12192

 
insert into senarprw03.senar_prod.dbo.Alteracao_Cancelamento
SELECT ACid, ACdtSolicitacao, ACevNumeroEvento, ACevID, ACtpSolicitacao, ACidMotivo, ACidSolicitante, ACnomeSolicitante, ACemailSolicitante, AClocal, ACroteiro, ACendereco, ACmotivo, ACdtAtualINI, ACdtAtualFIM, ACdtReproINI, ACdtReproFIM, ACstatus, ACdtProcessamento, ACroteiroP, AClocalAtual, ACroteiroAtual, ACenderecoAtual, ACpatrocinioAtual, ACpatrocinio, ACroteiroPatual, ACobs, ACuserAlt, ACinidAtual, ACinidNovo, ACforaprazo, ACdatastxt
	FROM senar_prod.dbo.Alteracao_Cancelamento order by 1

 where acid > 11835 order by 1
