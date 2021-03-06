--USE [careerdb]
--drop PROCEDURE [dbo].[RecoverDatabase]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RecoverDatabase]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[RecoverDatabase]
GO
/****** Object:  StoredProcedure [dbo].[RecoverDatabase]    Script Date: 2018-02-15 9:22:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[RecoverDatabase]
AS

SET NOCOUNT ON;

DECLARE @ts_now BIGINT 
DECLARE @SQLProcessUtilization INTEGER
DECLARE @SystemIdle INTEGER
DECLARE @OtherProcessUtilization INTEGER
DECLARE @session_id INTEGER
DECLARE @Text VARCHAR(MAX)
DECLARE @SQL NVARCHAR(MAX)
DECLARE @NTLogin VARCHAR(1000)
DECLARE @BlockedSessionsCount INTEGER
DECLARE @BlockingSessionsCount INTEGER
DECLARE @Level INTEGER

DECLARE @Subject VARCHAR(MAX)
DECLARE @Body VARCHAR(MAX)
DECLARE @Recipients VARCHAR(MAX) 
SET @Recipients = 'jonatasm@xello.world';--'benp@xello.world; arpitac@xello.world; christinel@xello.world; barmakb@xello.world; ivans@xello.world; coryt@xello.world; konstantins@xello.world';

SELECT @NTLogin = SYSTEM_USER 
SELECT @ts_now = ms_ticks FROM sys.dm_os_sys_info;
DECLARE @BlockingSessions TABLE(session_id INTEGER, [level] INTEGER, [text] VARCHAR(MAX))
DECLARE @Buffer TABLE(EventType VARCHAR(1000), [Parameters] VARCHAR(1000), EventInfo VARCHAR(MAX))	
DECLARE @Sessions TABLE(session_id INTEGER, blocking_session_id INTEGER, [status] VARCHAR(255), [command] VARCHAR(255), [database] VARCHAR(255), host_name VARCHAR(255), 
						program_name VARCHAR(255), nt_user_name VARCHAR(255), wait_time BIGINT, wait_type VARCHAR(255), total_elapsed_time BIGINT, open_transaction_count INTEGER, 
						cpu_time BIGINT, reads BIGINT, writes BIGINT, logical_reads BIGINT)

/******************************************************************************************************************************
	Gather summary perf counters from the SQL Server
*******************************************************************************************************************************/
SET @Subject = 'Blocking Sessions Debug Summary (' + CONVERT(VARCHAR(25), GETDATE(), 121) + ')'

SET @Body = '<b>Run by</b> ' + @NTLogin + '<br>'
SET @Body = @Body + '<b>Run on</b> ' + CONVERT(VARCHAR(25), GETDATE(), 121)
SET @Body = @Body + '<br><br>'

SET @Body = @Body + '<h1 style="font-family: Arial; font-size: 16px; font-weight: bold;">Server Summary</h1>'

SELECT TOP 1 
	   @SQLProcessUtilization = SQLProcessUtilization, 
	   @SystemIdle = SystemIdle, 
	   @OtherProcessUtilization = 100 - SystemIdle - SQLProcessUtilization
FROM ( 
	SELECT record.value('(./Record/@id)[1]', 'int') AS record_id, 
		   record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS SystemIdle,  
		   record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS SQLProcessUtilization, 
		   [timestamp]
	FROM ( 
		SELECT [timestamp], 
			   CONVERT(xml, record) AS record  
		FROM sys.dm_os_ring_buffers 
		WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' AND record LIKE '%<SystemHealth>%') AS x 
) AS y
ORDER BY record_id DESC;

SELECT @BlockedSessionsCount = COUNT(NULLIF(r.blocking_session_id, 0)), 
	   @BlockingSessionsCount = COUNT(DISTINCT NULLIF(r.blocking_session_id, 0))
FROM sys.dm_exec_requests r
WHERE r.session_id >= 50 AND r.session_id != @@SPID;

SET @Body = @Body + '<TABLE style="border-collapse: collapse; border-spacing: 0; width: 100%; height: 100%; margin: 0px; padding 2px;">'
SET @Body = @Body + '   <TR style="font-family: Arial; font-size: 12px; background-color: #005fbf; color: #ffffff; font-weight: bold; border:1px solid #000000;">' 
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>Blocked Sessions</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>Blocking Sessions</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>SQL CPU Utilization</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>System Idle</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>Other CPU Utilization</TD>'
SET @Body = @Body + '   </TR>'
SET @Body = @Body + '   <TR style="font-family: Arial; font-size: 12px; background-color: #ffffff; border-width: 1px; border:1px solid #000000;">' 
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>' + CONVERT(VARCHAR(25), ISNULL(@BlockedSessionsCount, 0)) + '</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>' + CONVERT(VARCHAR(25), ISNULL(@BlockingSessionsCount, 0)) + '</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>' + CONVERT(VARCHAR(25), ISNULL(@SQLProcessUtilization, 0)) + '</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>' + CONVERT(VARCHAR(25), ISNULL(@SystemIdle, 0)) + '</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>' + CONVERT(VARCHAR(25), ISNULL(@OtherProcessUtilization, 0)) + '</TD>'
SET @Body = @Body + '   </TR>'
SET @Body = @Body + '</TABLE>';

-- Session Summary
WITH CTE_BlockingSessions AS
(
	SELECT r.session_id, r.blocking_session_id, r.status, r.command, DB_NAME(r.database_id) AS [Database],	
		   s.host_name, s.program_name, s.nt_user_name, 
		   r.wait_type, r.wait_time, r.total_elapsed_time, r.open_transaction_count, r.cpu_time, r.reads, r.writes, r.logical_reads
	FROM sys.dm_exec_requests r
	INNER JOIN sys.dm_exec_sessions s ON (s.session_id = r.session_id)
	WHERE r.session_id >= 50 AND r.session_id != @@SPID AND r.wait_type NOT LIKE '%BROKER%'
)
INSERT INTO @Sessions(session_id, blocking_session_id, [status], [command], [database], host_name, program_name, nt_user_name, wait_type, wait_time, total_elapsed_time, open_transaction_count, cpu_time, reads, writes, logical_reads)
SELECT session_id, blocking_session_id, [status], command, [Database], host_name, program_name, nt_user_name, wait_type, wait_time, total_elapsed_time, open_transaction_count,
	   cpu_time, reads, writes, logical_reads 
FROM CTE_BlockingSessions

UNION ALL

SELECT session_id, 0, [status], 'SOMEONE LEFT A TRANSACTION OPEN', '', host_name, program_name, nt_user_name, '', 0, total_elapsed_time, 0,
	   cpu_time, reads, writes, logical_reads 
FROM sys.dm_exec_sessions s
WHERE s.session_id IN(SELECT blocking_session_id FROM CTE_BlockingSessions) AND s.session_id NOT IN(SELECT session_id FROM CTE_BlockingSessions);

WITH CTE_Root AS
(
	SELECT r.session_id, r.blocking_session_id, 1 AS [Level]
	FROM @Sessions r
	WHERE r.blocking_session_id != 0
	
	UNION ALL

	SELECT r.session_id, r.blocking_session_id, [Level] + 1 AS [Level]
	FROM @Sessions r
	INNER JOIN CTE_Root rt ON (rt.blocking_session_id = r.session_id)
)
INSERT INTO @BlockingSessions(session_id, [level])
SELECT r.session_id, MAX(r.[Level]) AS [level]
FROM CTE_Root r
WHERE r.blocking_session_id = 0
GROUP BY r.session_id, r.blocking_session_id;

DECLARE c CURSOR FOR
SELECT session_id 
FROM @BlockingSessions 

OPEN c
FETCH NEXT FROM c INTO @session_id 

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @SQL = N'DBCC INPUTBUFFER(' + CONVERT(VARCHAR(255), @session_id) + ');'

	INSERT INTO @Buffer(EventType, [Parameters], EventInfo)	
	EXEC sp_executeSQL @SQL;
	
	SELECT TOP 1 @Text = EventInfo FROM @Buffer 

	UPDATE bs SET
		bs.[text] = @Text
	FROM @BlockingSessions bs
	WHERE bs.session_id = @session_id

	FETCH NEXT FROM c INTO @session_id 
END

CLOSE c
DEALLOCATE c

SET @Body = @Body + '<br><br>'
SET @Body = @Body + '<h1 style="font-family: Arial; font-size: 16px; font-weight: bold;">Root Level Blockers (These Sessions Were Killed)</h1>'
SET @Body = @Body + '<TABLE style="border-collapse: collapse; border-spacing: 0; width: 100%; height: 100%; margin: 0px; padding 2px;">'
SET @Body = @Body + '   <TR style="font-family: Arial; font-size: 12px; background-color: #005fbf; color: #ffffff; font-weight: bold; border:1px solid #000000;">' 
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>Session Id</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>Level</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>SQL</TD>'
SET @Body = @Body + '   </TR>'

DECLARE c CURSOR FOR
SELECT session_id, [level], [text]
FROM @BlockingSessions 
ORDER BY session_id 

OPEN c

FETCH NEXT FROM c INTO @session_id, @level, @text
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @Body = @Body + '   <TR style="font-family: Arial; font-size: 12px; background-color: #ffffff; border-width: 1px; border:1px solid #000000;">' 
	SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>' + CONVERT(VARCHAR(25), ISNULL(@session_id, 0)) + '</TD>'
	SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>' + CONVERT(VARCHAR(25), ISNULL(@level, 0)) + '</TD>'
	SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>' + ISNULL(@Text, 'No Text') + '</TD>'
	SET @Body = @Body + '   </TR>'	
	
	FETCH NEXT FROM c INTO @session_id, @level, @text
END

CLOSE c 
DEALLOCATE c

SET @Body = @Body + '</TABLE>'

SET @Body = @Body + '<br><br>'
SET @Body = @Body + '<h1 style="font-family: Arial; font-size: 16px; font-weight: bold;">All Session Details</h1>'
SET @Body = @Body + '<TABLE style="border-collapse: collapse; border-spacing: 0; width: 100%; height: 100%; margin: 0px; padding 2px;">'
SET @Body = @Body + '   <TR style="font-family: Arial; font-size: 12px; background-color: #005fbf; color: #ffffff; font-weight: bold; border:1px solid #000000;">' 
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>Session Id</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>Blocking Session Id</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>Status</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>Command</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>Database Id</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>Host Name</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>Program Name</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>NT User Name</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>Wait Time</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>Wait Type</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>Total Elapsed Time</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>Open Transactions</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>CPU Time</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>Reads</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>Writes</TD>'
SET @Body = @Body + '      <TD style="border:1px solid #000000; padding: 5px;" nowrap>Logical Reads</TD>'
SET @Body = @Body + '   </TR>'

DECLARE @blocking_session_id INTEGER
DECLARE @status VARCHAR(255)
DECLARE @command VARCHAR(255)
DECLARE @database VARCHAR(255)
DECLARE @host_name VARCHAR(255)
DECLARE @program_name VARCHAR(255)
DECLARE @nt_user_name VARCHAR(255)
DECLARE @wait_time BIGINT
DECLARE @wait_type VARCHAR(25)
DECLARE @total_elapsed_time BIGINT
DECLARE @open_transaction_count INTEGER
DECLARE @cpu_time BIGINT
DECLARE @reads BIGINT
DECLARE @writes BIGINT
DECLARE @logical_reads BIGINT
DECLARE @color VARCHAR(255)
DECLARE @bordercolor VARCHAR(255) 

SET @color = ''
SET @bordercolor = '#000000'

-- TODO: COLOR HIGHLIGHT SESSIONS
DECLARE c CURSOR FOR
SELECT session_id, blocking_session_id, [status], [command], [database], host_name, program_name, nt_user_name, wait_time, wait_type, total_elapsed_time, open_transaction_count, 
	   cpu_time, reads, writes, logical_reads 
FROM @Sessions 

OPEN c
FETCH NEXT FROM c INTO @session_id, @blocking_session_id, @status, @command, @database, @host_name, @program_Name, @nt_user_name, @wait_time, @wait_type, @total_elapsed_time, 
						@open_transaction_count, @cpu_time, @reads, @writes, @logical_reads
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @color = ''

	IF @command = 'SOMEONE LEFT A TRANSACTION OPEN'
	BEGIN
	   SET @color = 'bgcolor = "#FF0000"'
	END
	
	IF EXISTS(SELECT * FROM @BlockingSessions WHERE session_id = @session_id) AND @color = ''
	BEGIN
	   SET @color = 'bgcolor = "#FFA500"'
	END

	SET @Body = @Body + '   <TR style="font-family: Arial; font-size: 12px; background-color: #ffffff; border-width: 1px; border:1px solid #000000;">' 
	SET @Body = @Body + '      <TD ' + @color + ' style="border:1px solid ' + @bordercolor + '; padding: 5px;" nowrap>' + CONVERT(VARCHAR(25), ISNULL(@session_id, 0)) + '</TD>'
	SET @Body = @Body + '      <TD ' + @color + ' style="border:1px solid ' + @bordercolor + '; padding: 5px;" nowrap>' + CONVERT(VARCHAR(25), ISNULL(@blocking_session_id, 0)) + '</TD>'
	SET @Body = @Body + '      <TD ' + @color + ' style="border:1px solid ' + @bordercolor + '; padding: 5px;" nowrap>' + ISNULL(@status, '') + '</TD>'
	SET @Body = @Body + '      <TD ' + @color + ' style="border:1px solid ' + @bordercolor + '; padding: 5px;" nowrap>' + ISNULL(@command, '') + '</TD>'
	SET @Body = @Body + '      <TD ' + @color + ' style="border:1px solid ' + @bordercolor + '; padding: 5px;" nowrap>' + ISNULL(@database, '') + '</TD>'
	SET @Body = @Body + '      <TD ' + @color + ' style="border:1px solid ' + @bordercolor + '; padding: 5px;" nowrap>' + ISNULL(@host_name, '') + '</TD>'
	SET @Body = @Body + '      <TD ' + @color + ' style="border:1px solid ' + @bordercolor + '; padding: 5px;" nowrap>' + ISNULL(@program_name, '') + '</TD>'
	SET @Body = @Body + '      <TD ' + @color + ' style="border:1px solid ' + @bordercolor + '; padding: 5px;" nowrap>' + ISNULL(@nt_user_name, '') + '</TD>'
	SET @Body = @Body + '      <TD ' + @color + ' style="border:1px solid ' + @bordercolor + '; padding: 5px;" nowrap>' + CONVERT(VARCHAR(25), ISNULL(@wait_time, 0)) + '</TD>'
	SET @Body = @Body + '      <TD ' + @color + ' style="border:1px solid ' + @bordercolor + '; padding: 5px;" nowrap>' + ISNULL(@wait_type, '') + '</TD>'
	SET @Body = @Body + '      <TD ' + @color + ' style="border:1px solid ' + @bordercolor + '; padding: 5px;" nowrap>' + CONVERT(VARCHAR(25), ISNULL(@total_elapsed_time, 0)) + '</TD>'
	SET @Body = @Body + '      <TD ' + @color + ' style="border:1px solid ' + @bordercolor + '; padding: 5px;" nowrap>' + CONVERT(VARCHAR(25), ISNULL(@open_transaction_count, 0)) + '</TD>'
	SET @Body = @Body + '      <TD ' + @color + ' style="border:1px solid ' + @bordercolor + '; padding: 5px;" nowrap>' + CONVERT(VARCHAR(25), ISNULL(@cpu_time, 0)) + '</TD>'
	SET @Body = @Body + '      <TD ' + @color + ' style="border:1px solid ' + @bordercolor + '; padding: 5px;" nowrap>' + CONVERT(VARCHAR(25), ISNULL(@reads, 0)) + '</TD>'
	SET @Body = @Body + '      <TD ' + @color + ' style="border:1px solid ' + @bordercolor + '; padding: 5px;" nowrap>' + CONVERT(VARCHAR(25), ISNULL(@writes, 0)) + '</TD>'
	SET @Body = @Body + '      <TD ' + @color + ' style="border:1px solid ' + @bordercolor + '; padding: 5px;" nowrap>' + CONVERT(VARCHAR(25), ISNULL(@logical_reads, 0)) + '</TD>'
	SET @Body = @Body + '   </TR>'		
	
	FETCH NEXT FROM c INTO @session_id, @blocking_session_id, @status, @command, @database, @host_name, @program_Name, @nt_user_name, @wait_time, @wait_type, @total_elapsed_time, 
							@open_transaction_count, @cpu_time, @reads, @writes, @logical_reads
END

CLOSE c
DEALLOCATE c

SET @Body = @Body + '</TABLE>'
/*
EXEC msdb.dbo.sp_send_dbmail @recipients=@Recipients,
								@subject = @Subject,
								@body = @Body, 
								@importance = 'high',
								@body_format = 'HTML';
*/
print @Subject
Print @Body

-- Kill Root Level Blockers
DECLARE c CURSOR FOR
SELECT session_id 
FROM @BlockingSessions 

OPEN c
FETCH NEXT FROM c INTO @session_id

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SQL = 'kill ' + CONVERT(VARCHAR(25), @session_id)
	EXEC sp_executeSQL @SQL;
	
	FETCH NEXT FROM c INTO @session_id
END

CLOSE c
DEALLOCATE c

