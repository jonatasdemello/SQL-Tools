/*********************************************************************************************/
/* sp_usrheadblocker */
/*********************************************************************************************/


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_usrheadblocker]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_usrheadblocker]
GO
Create Proc dbo.sp_usrheadblocker
/******************************************************************************************
Procedure: 	sp_usrheadblocker															
Descrição:Possui a característica de reunir em apenas um comando as instruções: sp_who Active
e DBCC InputBuffer(n). Retorna apenas as linhas que estão com Status de Blocked <> 0 e no
final de cada linha traz o InputBuffer.

A primeira linha sempre será a ponta (head blocker-a conexão que está causando o bloqueio de
todas as outras) e as demais linhas, as que estão aguardando a liberação do recurso. 
Pode-se ver a quanto tempo cada	uma das conexões está aguardando a liberação. 
 							
Autor Original: Marcelo Andretto
Adaptada por : Nilton Pinheiro
WebSite: http://www.mcdbabrasil.com.br

-- Melhor visualizada em modo ..GRADE..
******************************************************************************************/
as
Set NoCount on

-- Tabelas de Apoio.
CREATE TABLE #tbheadBlocked (
	[Host_Id] [int] NULL ,
	[SPID] [int] NULL ,
	[a] [varchar] (14)  NULL ,
	[b] [int] NULL ,
	[TextBuffer] [varchar] (255) NULL 
) 

Create Table #tbInputBuffer(
a VarChar(14),
b int,
TextBuffer VarChar(255))

-- Passo1 -- Insere na tabela temporária "#tbheadblocked" todos os SPID que estão bloqueados
Insert Into #tbheadBlocked Select Host_id(),SPID,null,null,null
from master..sysprocesses (NoLock)
Where SPID in (Select Blocked from master..sysprocesses (NoLock)
Where Blocked <>0)or Blocked <> 0 

-- Passo 2 -- Abre um cursor para obter o DBCC InputBuffer de todas os SPID que foram inseridas
-- na tabela do passo 1 e armazena em uma nova tabela temporária "#tbInputBuffer"

Declare @SPID Int
Declare C_Buffer CURSOR For Select SPID from #tbheadBlocked 
Open C_Buffer
Fetch C_Buffer Into @SPID
While @@Fetch_Status = 0 
Begin
	Insert Into #tbInputBuffer exec ('Dbcc InputBuffer(' + @SPID + ') with NO_INFOMSGS ')
	Update #tbheadBlocked Set TextBuffer = #tbInputBuffer.TextBuffer from #tbInputBuffer Where Spid = @spid
	Fetch C_Buffer Into @SPID
End
Close C_Buffer
Deallocate C_Buffer

-- Passo 3 -- Faz o Join das tabelas temporárias apresentando o resultado final.
-- Uma concatenação da SP_Who Active + DBCC InputBuffer() 

select distinct	a.SPID, 
	a.Blocked,
	a.ECID,
	a.WaitTime as WaitTimeMS,
   datediff (mi,a.last_batch,getDate() ) as RunAs, --Tempo de execução em minutos
	SubString(a.Status,1,10) as Status,
	a.CPU,
	SubString(Cast(a.Physical_IO as Varchar(10)),1,10) as Physical_IO,
	SubString(a.HostName,1,15) as HostName,
	SubString(a.LogiName,1,15) as LoginName,
	SubString(DB_Name(a.dbid),1,13) as DBName,
	SubString(convert(VarChar(24),a.last_batch ,113),1,24) as Last_Batch,
	a.open_tran,
	a.MemUsage,
	b.TextBuffer
from master..sysprocesses a (NoLock) Right Outer Join  #tbheadBlocked b (NoLock)
	On a.Spid = b.spid
Where a.SPID in (Select c.Blocked from master..sysprocesses c (NoLock)Where Blocked <>0)
	or a.Blocked <> 0 
Order By a.Blocked 

Set NoCount off

Drop Table #tbInputBuffer
Drop table #tbheadBlocked
GO


