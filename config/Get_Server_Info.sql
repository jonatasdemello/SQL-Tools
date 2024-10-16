select SERVERPROPERTY('MachineName') as 'MachineName'
select SERVERPROPERTY('ComputerNamePhysicalNetBIOS') as 'ComputerNamePhysicalNetBIOS'
select SERVERPROPERTY('ServerName') as 'ServerName'
select SERVERPROPERTY('InstanceName') as 'InstanceName'
select SERVERPROPERTY('InstanceDefaultDataPath') as 'InstanceDefaultDataPath'
select SERVERPROPERTY('InstanceDefaultLogPath') as 'InstanceDefaultLogPath'
select SERVERPROPERTY('Edition') as 'Edition'
select SERVERPROPERTY('EditionID') as 'EditionID'
select SERVERPROPERTY('EngineEdition') as 'EngineEdition'
select SERVERPROPERTY('ProductBuild') as 'ProductBuild'
select SERVERPROPERTY('ProductBuildType') as 'ProductBuildType'
select SERVERPROPERTY('ProductLevel') as 'ProductLevel'
select SERVERPROPERTY('ProductMajorVersion') as 'ProductMajorVersion'
select SERVERPROPERTY('ProductMinorVersion') as 'ProductMinorVersion'
select SERVERPROPERTY('ProductUpdateLevel') as 'ProductUpdateLevel'
select SERVERPROPERTY('ProductVersion') as 'ProductVersion'
select SERVERPROPERTY('BuildClrVersion') as 'BuildClrVersion'
select SERVERPROPERTY('Collation') as 'Collation'
select SERVERPROPERTY('LCID') as 'LCID'
select SERVERPROPERTY('IsSingleUser') as 'IsSingleUser'
select SERVERPROPERTY('IsIntegratedSecurityOnly') as 'IsIntegratedSecurityOnly'
select SERVERPROPERTY('IsHadrEnabled') as 'IsHadrEnabled'
select SERVERPROPERTY('HadrManagerStatus') as 'HadrManagerStatus'
select SERVERPROPERTY('IsAdvancedAnalyticsInstalled') as 'IsAdvancedAnalyticsInstalled'
select SERVERPROPERTY('IsClustered') as 'IsClustered'
select SERVERPROPERTY('IsFullTextInstalled') as 'IsFullTextInstalled'
select SERVERPROPERTY('ProcessID. ') as 'ProcessID. '


SELECT SERVERPROPERTY('productversion'), SERVERPROPERTY ('productlevel'), SERVERPROPERTY ('edition')

SELECT @@version
-- Microsoft SQL Server 2019 (RTM-CU12) (KB5004524) - 15.0.4153.1 (X64)
-- 	Jul 19 2021 15:37:34
-- 	Copyright (C) 2019 Microsoft Corporation
--	Developer Edition (64-bit) on Linux (Ubuntu 21.04) <X64>


SELECT SUBSTRING(@@VERSION,CHARINDEX('Windows',@@VERSION,0),100) AS OSVersion;
GO

SELECT host_platform, host_distribution, host_release FROM sys.dm_os_host_info;
GO