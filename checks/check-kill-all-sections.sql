-- Kill all sections
DECLARE @session_id INTEGER
DECLARE @SQL NVARCHAR(MAX)
DECLARE c CURSOR FOR
SELECT r.session_id
FROM sys.dm_exec_requests r
WHERE r.session_id > 50 AND r.session_id != @@SPID AND r.wait_type NOT LIKE 'BROKER%'
OPEN c
FETCH NEXT FROM c INTO @session_id
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SQL = N'KILL ' + CONVERT(VARCHAR(25), @session_id)
	EXEC sp_executeSQL @SQL;
	FETCH NEXT FROM c INTO @session_id
END
CLOSE c