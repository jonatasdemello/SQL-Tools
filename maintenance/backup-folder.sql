Use master  
go  
  
SELECT  
    database_name,  
    backup_finish_date,  
    CASE msdb..backupset.type  
        WHEN 'D' THEN 'Database'  
        WHEN 'L' THEN 'Log'  
    END AS backup_type,  
    physical_device_name  
FROM msdb.dbo.backupmediafamily  
INNER JOIN msdb.dbo.backupset  
    ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id  
--WHERE (CONVERT(datetime, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 1)  
ORDER BY database_name,backup_finish_date




-- File name : Where are the backups.sql
-- Author : Graham Okely B App Sc
-- Scope : OK on SQL Server 2000,2005,2008R2,2012
-- Select the information we require to make a decision about which backup we want to use

select  top 5 a.server_name, a.database_name, backup_finish_date, a.backup_size,
CASE a.[type] -- Let's decode the three main types of backup here
 WHEN 'D' THEN 'Full'
 WHEN 'I' THEN 'Differential'
 WHEN 'L' THEN 'Transaction Log'
 ELSE a.[type]
END as BackupType
 ,b.physical_device_name
from msdb.dbo.backupset a join msdb.dbo.backupmediafamily b
  on a.media_set_id = b.media_set_id
where a.database_name Like 'master%'
order by a.backup_finish_date desc




-- File name : Where is my specific backup located.sql
-- Author : Graham Okely B App Sc
-- Scope : OK on SQL Server 2000,2005,2008R2,2012
-- Select the information we require to make a decision about which backup we want to use

select  top 5 a.server_name, a.database_name, backup_finish_date, a.backup_size,
CASE a.[type] -- Let's decode the three main types of backup here
 WHEN 'D' THEN 'Full'
 WHEN 'I' THEN 'Differential'
 WHEN 'L' THEN 'Transaction Log'
 ELSE a.[type]
END as BackupType
-- Build a path to the backup
,'\\' + 
-- lets extract the server name out of the recorded server and instance name
CASE
 WHEN patindex('%\%',a.server_name) = 0  THEN a.server_name
 ELSE substring(a.server_name,1,patindex('%\%',a.server_name)-1)
END 
-- then get the drive and path and file information
+ '\' + replace(b.physical_device_name,':','$') AS '\\Server\Drive\backup_path\backup_file'
from msdb.dbo.backupset a join msdb.dbo.backupmediafamily b
  on a.media_set_id = b.media_set_id
where a.database_name Like 'master%'
order by a.backup_finish_date desc



-- File name : A query to a pathway.sql
-- Author : Graham Okely B App Sc
-- Select the information we require to make a decision about which backup we want to use

select  top 5 a.server_name, a.database_name, backup_finish_date, a.backup_size,
CASE a.[type] -- Let's decode the three main types of backup here
 WHEN 'D' THEN 'Full'
 WHEN 'I' THEN 'Differential'
 WHEN 'L' THEN 'Transaction Log'
 ELSE a.[type]
END as BackupType
-- Browse to the file
,'\\' + 
-- lets extract the server name out of the recorded server and instance name
CASE
 WHEN patindex('%\%',a.server_name) = 0  THEN a.server_name
 ELSE substring(a.server_name,1,patindex('%\%',a.server_name)-1)
END 
-- then get the drive information
+ '\' + left(replace(b.physical_device_name,':','$'),2) AS '\\Server\Drive'
from msdb.dbo.backupset a join msdb.dbo.backupmediafamily b
  on a.media_set_id = b.media_set_id
where a.database_name Like 'master%'
order by a.backup_finish_date desc




-- File name : Space the final frontier.sql
-- Author : Graham Okely B App Sc
-- Purpose : Create the path for each drive on a SQL Server instance
-- Scope : OK on SQL Server 2000,2005,2008R2,2012

USE [Master]
GO

-- 2000 specific drop temp table
IF Object_id('tempdb..#Drives') IS NOT NULL
  DROP TABLE #Drives

-- Make a space for data
CREATE TABLE #Drives ( Drive_Letter  CHAR(1), mb_Free_Space int )

-- Collect the data
INSERT INTO #Drives EXEC xp_FixedDrives

-- Display a path to the drives
SELECT '\\' + CAST(Serverproperty('MachineName') AS NVARCHAR(128)) + 
 '\' + Drive_Letter + '$' AS 'Server and Drive'
       ,mb_Free_Space/1024 AS 'GB Free space'
FROM   #Drives

-- Clean up
DROP TABLE #Drives
