-------------------------------------------------------------------------------------------------------------------------------
-- SQL Blocking Sessions
-------------------------------------------------------------------------------------------------------------------------------

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

-------------------------------------------------------------------------------------------------------------------------------
-- SQL CPU History
-------------------------------------------------------------------------------------------------------------------------------

declare @ms_now bigint
 select @ms_now = ms_ticks from sys.dm_os_sys_info;


select top 200 record_id,
  dateadd(ms, -1 * (@ms_now - [timestamp]), GetDate()) as EventTime, 
  SQLProcessUtilization,
  SystemIdle,
  100 - SystemIdle - SQLProcessUtilization as OtherProcessUtilization
 from (
  select 
   record.value('(./Record/@id)[1]', 'int') as record_id,
   record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') as SystemIdle,
   record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') as SQLProcessUtilization,
   timestamp
  from (
   select timestamp, convert(xml, record) as record 
   from sys.dm_os_ring_buffers 
   where ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
   and record like '%<SystemHealth>%') as x
  ) as y 
 order by record_id desc

-------------------------------------------------------------------------------------------------------------------------------
-- SQL Who is running integration during the Day
-------------------------------------------------------------------------------------------------------------------------------

USE DataIntegration
GO 
​
-- Who's running integrations?!?

SELECT id.IntegrationDistrictId, id.Name, h.StartTime, h.EndTime, DATEDIFF(s, h.StartTime, h.EndTime) / 60.0 AS [TimeTakenMinutes], s.Name AS LastStatus, h.[Message], CASE WHEN bh.ExecutionSourceId = 2 THEN 'Manual' ELSE 'Scheduled' END AS ExecutionType, lr.UserName AS LstRunBy
FROM [audit].BatchIntegrationHistory h
INNER JOIN dbo.Integration i ON (i.IntegrationId = h.IntegrationId)
INNER JOIN dbo.IntegrationDistrict id ON (id.IntegrationDistrictId = i.IntegrationDistrictId)
INNER JOIN dbo.IntegrationStatus s ON (s.IntegrationStatusId = i.IntegrationStatusId)
INNER JOIN [audit].BatchHistory bh ON (bh.BatchId = h.BatchId)
OUTER APPLY
(	
	SELECT TOP 1 [UserName]
	FROM [audit].UserActivityLog l
	WHERE l.IntegrationDistrictId = id.IntegrationDistrictId AND l.LogMessage = 'Integration was run.'
	ORDER BY l.CreatedDate DESC
) lr
WHERE h.StartTime > '2021-02-08 16:00:00' AND h.StartTime < '2021-02-08 18:00:00'
ORDER BY h.StartTime

