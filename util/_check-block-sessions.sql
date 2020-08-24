-- check block sessions

SELECT r.blocking_session_id, r.session_id, r.total_elapsed_time, r.wait_time, r.wait_type, r.command, r.open_transaction_count, st.[text] AS SQL, st2.[Text] AS BlockingSQL
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.[sql_handle]) st
LEFT JOIN sys.dm_exec_requests r2 ON (r2.session_id = r.blocking_session_id)
OUTER APPLY sys.dm_exec_sql_text(r2.[sql_handle]) st2
WHERE r.session_id > 50 AND r.session_id != @@SPID AND ISNULL(r.wait_type, '') NOT LIKE 'BROKER%'
ORDER BY r.total_elapsed_time DESC;
