-- Check Query Activity
SELECT 
	r.percent_complete, s.host_name, r.blocking_session_id, r.session_id, 
	r.total_elapsed_time / 1000.0 / 60.0 as timeInMin, 
	r.wait_time, 
	r.wait_type, 
	r.command, 
	r.open_transaction_count, 
	st.[text] AS SQL 
	--st2.[Text] AS BlockingSQL, 	r2.wait_type AS BlockingWaitType, r.wait_resource, r2.wait_resource AS BlockingWaitResource
FROM sys.dm_exec_requests r 
CROSS APPLY sys.dm_exec_sql_text(r.[sql_handle]) st 
LEFT JOIN sys.dm_exec_requests r2 ON (r2.session_id = r.blocking_session_id)
OUTER APPLY sys.dm_exec_sql_text(r2.[sql_handle]) st2
INNER JOIN sys.dm_exec_sessions s ON (s.[session_id] = r.[session_id])
WHERE r.session_id != @@SPID AND ISNULL(r.wait_type, '') NOT LIKE 'BROKER%' 
ORDER BY 
	--r.total_elapsed_time DESC;
	r.wait_time desc,
	r.total_elapsed_time DESC


-- https://www.red-gate.com/simple-talk/sql/performance/identifying-and-solving-index-scan-problems/