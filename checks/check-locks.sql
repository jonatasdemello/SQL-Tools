SELECT 
	sqltext.text,
	req.session_id,
	req.blocking_session_id,
	req.command,
	req.status,
	req.total_elapsed_time,
	req.cpu_time
FROM sys.dm_exec_requests req
CROSS APPLY sys.dm_exec_sql_text(sql_handle) as sqltext
WHERE req.session_id <> @@spid
order by total_elapsed_time desc

-- kill process...
