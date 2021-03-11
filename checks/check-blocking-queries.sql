-- Check Blocking Queries

SELECT blocking_session_id, 
       session_id, 
       r.total_elapsed_time, 
       wait_time, 
       wait_type, 
       command, 
       open_transaction_count, 
       st.[text] AS SQL
FROM sys.dm_exec_requests r
     CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) st
WHERE r.session_id > 50
      AND r.session_id != @@SPID
      AND wait_type NOT LIKE 'BROKER%'
	  AND wait_type != 'XE_LIVE_TARGET_TVF'
ORDER BY r.total_elapsed_time DESC;