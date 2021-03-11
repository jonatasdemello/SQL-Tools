-- show Memory Grants.

SELECT 
	requested_memory_kb / 1000.0 AS RequestedMemoryMB, 
	required_memory_kb / 1000.0 AS requiredMemoryMB, 
	granted_memory_kb / 1000.0 AS grantedMemoryMB,
	st2.[Text], * 
FROM sys.dm_exec_query_memory_grants g
INNER JOIN sys.dm_exec_sessions s ON (s.session_id = g.session_Id)
OUTER APPLY sys.dm_exec_sql_text(g.[sql_handle]) st2
order by grantedMemoryMB DESC 
