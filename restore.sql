use master


sp_who 

restore log testes 
from disk='E:\MSSQL\BACKUP\senar_prod_tlog_200603020000.TRN'
WITH RECOVERY
--WITH STANDBY = 'c:\undo.ldf'

--You can set the database to single user mode using
ALTER DATABASE testes SET SINGLE_USER WITH ROLLBACK IMMEDIATE
ALTER DATABASE testes SET RESTRICTED_USER
ALTER DATABASE testes SET OFFLINE WITH ROLLBACK IMMEDIATE
ALTER DATABASE testes SET ONLINE

ALTER DATABASE testes SET MULTI_USER
-- SINGLE_USER | RESTRICTED_USER | MULTI_USER 
-- OFFLINE | ONLINE 
-- READ_ONLY | READ_WRITE 


RESTORE DATABASE TESTES 
FROM DISK='E:\MSSQL\BACKUP\senar_prod\senar_prod_db_200603031201.BAK'
WITH file=2, 
NORECOVERY

--The log in this backup set terminates at LSN 1493000001612900001, which is too early to apply to the database. 
--  A more recent log backup that includes LSN 1496000001791100001 can be restored.
RESTORE LOG testes
FROM DISK = 'E:\MSSQL\BACKUP\senar_prod_tlog_200602280000.TRN'
WITH --RESTART,
NORECOVERY
go

-- The log in this backup set terminates at LSN 1494000004204100001, which is too early to apply to the database. 
--   A more recent log backup that includes LSN 1496000001791100001 can be restored.
RESTORE LOG testes
FROM DISK = 'E:\MSSQL\BACKUP\senar_prod_tlog_200603010000.TRN'
WITH --RESTART,
NORECOVERY
go

--The log in this backup set terminates at LSN 1494000004204100001, which is too early to apply to the database. 
--  A more recent log backup that includes LSN 1496000001791100001 can be restored.
RESTORE LOG testes
FROM DISK = 'E:\MSSQL\BACKUP\senar_prod_tlog_200603020000.TRN'
WITH --RESTART,
NORECOVERY
go

--The log in this backup set begins at LSN 1496000002324800001, which is too late to apply to the database. 
-- An earlier log backup that includes LSN 1496000001791100001 can be restored.
RESTORE LOG testes
FROM DISK = 'E:\MSSQL\BACKUP\senar_prod_tlog_200603030000.TRN'
WITH 
RECOVERY , replace
--RESTART, 
RESTRICTED_USER,
file=1,
MOVE 'senar_prod' TO 'E:\MSSQL\Data\testes.mdf' ,
MOVE 'senar_prod_log' TO 'E:\MSSQL\Data\testes.ldf' --,

restore log testes with recovery

RESTORE VERIFYONLY FROM DISK = 'E:\MSSQL\BACKUP\senar_prod_tlog_200603020000.TRN'
RESTORE VERIFYONLY FROM DISK = 'E:\MSSQL\BACKUP\senar_prod_tlog_200603030000.TRN'


select top 10 * from testes.dbo.eventos order by 1 desc

select top 100 * from senar_prod.dbo.eventos order by 1 desc

