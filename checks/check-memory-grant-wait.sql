/*
Identify memory grant wait performance issues
If your top wait type is RESOURCE_SEMAHPORE and you don't have a high CPU usage issue, you may have a memory grant waiting issue.

Determine if a RESOURCE_SEMAHPORE wait is a top wait
Use the following query to determine if a RESOURCE_SEMAHPORE wait is a top wait
*/
SELECT wait_type,
       SUM(wait_time) AS total_wait_time_ms
FROM sys.dm_exec_requests AS req
    JOIN sys.dm_exec_sessions AS sess
        ON req.session_id = sess.session_id
WHERE is_user_process = 1
GROUP BY wait_type
ORDER BY SUM(wait_time) DESC;
