--SQL Blocking Sessions

SELECT 
sqlconn.client_net_address,
sqlconn.local_net_address,
req.session_id,
req.blocking_session_id,
req.command,
req.status,
req.total_elapsed_time,
req.cpu_time,
sqltext.text
FROM sys.dm_exec_requests req
CROSS APPLY sys.dm_exec_sql_text(sql_handle) as sqltext
LEFT JOIN sys.dm_exec_connections as sqlconn on sqlconn.connection_id = req.connection_id
WHERE req.session_id <> @@spid
order by req.total_elapsed_time desc

--kill (process id)
