--Please run the following SQL statement to capture the current traffic and paste the results into Excel so that we can troubleshoot the cause after the sessions are cleared out.

SELECT blocking_session_id, session_id, r.total_elapsed_time, wait_time, wait_type, command, open_transaction_count, st.[text] AS SQL 
FROM sys.dm_exec_requests r 
CROSS APPLY sys.dm_exec_sql_text(r.[sql_handle]) st 
WHERE r.session_id > 50 AND r.session_id != @@SPID AND wait_type NOT LIKE 'BROKER%' 
ORDER BY r.total_elapsed_time DESC;

-- Once you've copied the results to Excel, please run the following script to clear out all of the sessions. You may need to run this script multiple times before traffic clears up.

-- Nuke Script
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
DEALLOCATE c
