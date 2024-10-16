sp_who active

SELECT * FROM master.sys.sysprocesses WHERE blocked != 0
SELECT spid FROM master.sys.sysprocesses WHERE blocked != 0
-- comando executed
dbcc inputbuffer (190)

Declare @SPID Int
Declare C_Buffer CURSOR For Select distinct SPID FROM master.sys.sysprocesses WHERE blocked != 0
Open C_Buffer
Fetch C_Buffer Into @SPID
While @@Fetch_Status = 0 
Begin
	exec ('Dbcc InputBuffer(' + @SPID + ') with NO_INFOMSGS ')
	Fetch C_Buffer Into @SPID
End
Close C_Buffer
Deallocate C_Buffer


