-------------------------------------------------------------------------------------------------------------------------------
use master

select * from master.sys.databases order by name

select name, state_desc from master.sys.databases order by 2,1


select * from master.sys.databases where name like 'TEST%'

drop database TEST_12345


drop database IF EXISTS TEST_12345
drop database IF EXISTS TEST_5be1a1b168a7443ea2560ce7b0d3bcae

------------------------------------------------------------------------------------------------------------------------------
select @@VERSION

SELECT
 SERVERPROPERTY('MachineName') AS ComputerName,
 SERVERPROPERTY('ServerName') AS InstanceName,
 SERVERPROPERTY('Edition') AS Edition,
 SERVERPROPERTY('ProductVersion') AS ProductVersion,
 SERVERPROPERTY('ProductLevel') AS ProductLevel;
GO
-------------------------------------------------------------------------------------------------------------------------------
-- run sSQLt

EXEC tSQLt.RunAll

select * from sys.schemas order by 1

--tSQLt
--SQLCop

select ROUTINE_SCHEMA, ROUTINE_NAME, ROUTINE_TYPE From INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA = 'tSQLt' order by 2

select ROUTINE_SCHEMA, ROUTINE_NAME From INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA = 'SQLCop' order by 2


