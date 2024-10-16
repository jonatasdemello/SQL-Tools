--SQL CPU History

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
