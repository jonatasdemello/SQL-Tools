
sp_who

sp_who 'ACTIVE'

EXEC sp_usrheadblocker

Select * from sysprocesses 

SELECT * FROM master.sys.sysprocesses
	WHERE blocked != 0

dbcc inputbuffer (92) -- (<spid>)

dbcc inputbuffer (60)

	--DELETE FROM dbo.VW_Student WHERE SystemNameId = 1

EXEC sp_usrinputbuffer 60

Kill <spid>

alter database <banco de dados> set restricted_user with rollback immediate
alter database <banco de dados> set multi_user

xp_readerrorlog

