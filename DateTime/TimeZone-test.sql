use master;

select name from sys.databases

-- DROP database Local_DB
-- DROP database CC3_powershell

-- exec sp_who

-- kill 51

use Local_DB;

select * from sys.time_zone_info
go

DECLARE @dt DATETIME2
select @dt = CAST('2023-12-01 00:00:00' as datetime2)
select @dt as UTC_TIME, dbo.udf_ConvertToTimeZone(@dt, 'UTC', 'Eastern Standard Time') as EST_TIME-- GMT+5

GO
-- list of available timezones
select * from sys.time_zone_info

-- running in Docker
DECLARE @dt DATETIME2
select @dt = CAST('2023-12-01 00:00:00' as datetime2)
      select @dt as UTC_TIME, dbo.udf_ConvertToTimeZone(@dt, 'UTC', 'UTC') as TimeZone, 'UTC'
UNION select @dt as UTC_TIME, dbo.udf_ConvertToTimeZone(@dt, 'UTC', 'GMT Standard Time')          as TimeZone, 'GMT+0'
UNION select @dt as UTC_TIME, dbo.udf_ConvertToTimeZone(@dt, 'UTC', 'Newfoundland Standard Time') as TimeZone, 'GMT-3'
UNION select @dt as UTC_TIME, dbo.udf_ConvertToTimeZone(@dt, 'UTC', 'Atlantic Standard Time')     as TimeZone, 'GMT-4'
UNION select @dt as UTC_TIME, dbo.udf_ConvertToTimeZone(@dt, 'UTC', 'Eastern Standard Time')      as TimeZone, 'GMT-5'
UNION select @dt as UTC_TIME, dbo.udf_ConvertToTimeZone(@dt, 'UTC', 'Central Standard Time')      as TimeZone, 'GMT-6'
UNION select @dt as UTC_TIME, dbo.udf_ConvertToTimeZone(@dt, 'UTC', 'Mountain Standard Time')     as TimeZone, 'GMT-7'
UNION select @dt as UTC_TIME, dbo.udf_ConvertToTimeZone(@dt, 'UTC', 'Pacific Standard Time')      as TimeZone, 'GMT-8'
UNION select @dt as UTC_TIME, dbo.udf_ConvertToTimeZone(@dt, 'UTC', 'Alaskan Standard Time')      as TimeZone, 'GMT-9'
UNION select @dt as UTC_TIME, dbo.udf_ConvertToTimeZone(@dt, 'UTC', 'Hawaiian Standard Time')     as TimeZone, 'GMT-10'

GO

select * from dbo.TimeZone

-- running in 127.0.0.1
DECLARE @dt DATETIME2
select @dt = CAST('2023-12-01 00:00:00' as datetime2)
select @dt as UTC_TIME, dbo.udf_ConvertTimeZone(@dt, 'UTC', 'UTC') as TimeZone, 'UTC'
UNION select @dt as UTC_TIME, dbo.udf_ConvertTimeZone(@dt, 'UTC', 'GMT Standard Time')          as TimeZone, 'GMT+0'
UNION select @dt as UTC_TIME, dbo.udf_ConvertTimeZone(@dt, 'UTC', 'Newfoundland Standard Time') as TimeZone, 'GMT-3'
UNION select @dt as UTC_TIME, dbo.udf_ConvertTimeZone(@dt, 'UTC', 'Atlantic Standard Time')     as TimeZone, 'GMT-4'
UNION select @dt as UTC_TIME, dbo.udf_ConvertTimeZone(@dt, 'UTC', 'Eastern Standard Time')      as TimeZone, 'GMT-5'
UNION select @dt as UTC_TIME, dbo.udf_ConvertTimeZone(@dt, 'UTC', 'Central Standard Time')      as TimeZone, 'GMT-6'
UNION select @dt as UTC_TIME, dbo.udf_ConvertTimeZone(@dt, 'UTC', 'Mountain Standard Time')     as TimeZone, 'GMT-7'
UNION select @dt as UTC_TIME, dbo.udf_ConvertTimeZone(@dt, 'UTC', 'Pacific Standard Time')      as TimeZone, 'GMT-8'
UNION select @dt as UTC_TIME, dbo.udf_ConvertTimeZone(@dt, 'UTC', 'Alaskan Standard Time')      as TimeZone, 'GMT-9'
UNION select @dt as UTC_TIME, dbo.udf_ConvertTimeZone(@dt, 'UTC', 'Hawaiian Standard Time')     as TimeZone, 'GMT-10'



--------------------------------------
IF EXISTS (SELECT * FROM information_schema.routines WHERE routine_type = 'function' AND routine_schema = 'dbo' AND routine_name = 'udf_ConvertToTimeZone')
BEGIN 
	DROP FUNCTION dbo.udf_ConvertToTimeZone
END
GO
-- Only create an Assembly if it is Windows OS and SQL SQL2017 or higher
IF EXISTS (SELECT 'windows' WHERE @@Version LIKE '%windows%') 
    AND EXISTS (SELECT 1 WHERE CAST(SERVERPROPERTY('ProductMajorVersion') AS INT) >= 13 )
BEGIN
    execute dbo.sp_executesql @statement = N'
    CREATE FUNCTION dbo.udf_ConvertToTimeZone
    (
        @datetime DATETIME,
        @source_time_zone NVARCHAR(255),
        @destination_time_zone NVARCHAR(255) 
    )
    RETURNS DATETIME
    AS
    BEGIN
        DECLARE @RESULT DATETIME2

        SELECT @RESULT = @datetime AT TIME ZONE @source_time_zone AT TIME ZONE @destination_time_zone

        RETURN @RESULT
    END'
END
GO
---------------------------




-- running in 127.0.0.1
select @@VERSION

select len(@@VERSION)

--Microsoft SQL Server 2014 (SP3-GDR) (KB5029184) - 12.0.6179.1 (X64)  	Jul 27 2023 21:44:30  	Copyright (c) Microsoft Corporation 	Standard Edition (64-bit) on Windows NT 6.1 <X64> (Build 7601: Service Pack 1) (Hypervisor)

select * from sys.dm_os_windows_info -- Windows only

-- sys.dm_os_host_info was added with 2017, as SQL Server was made available on both Windows and Linux with that Version.
SELECT * FROM sys.dm_os_host_info -- SQL Server 2017 (14.x) and later

SELECT TOP (100) * FROM sys.dm_os_host_info

DECLARE @VER VARCHAR(1000);
SELECT @VER = @@Version;
SELECT 'Windows' WHERE @VER LIKE '%windows%'
SELECT 'Linux' WHERE @VER LIKE '%linux%'

SELECT 'windows' WHERE @@Version LIKE '%windows%'
SELECT 'linux' WHERE @@Version LIKE '%linux%'

SELECT
 SERVERPROPERTY('MachineName') AS ComputerName,
 SERVERPROPERTY('ServerName') AS InstanceName,
 SERVERPROPERTY('Edition') AS Edition,
 SERVERPROPERTY('ProductVersion') AS ProductVersion,
 SERVERPROPERTY('ProductLevel') AS ProductLevel,
 SERVERPROPERTY('ProductMajorVersion') AS ProductMajorVersion;

select SERVERPROPERTY('ProductBuild'),
SERVERPROPERTY('ProductMajorVersion'),
SERVERPROPERTY('ProductVersion'),
SERVERPROPERTY('ProductLevel')

select CAST(SERVERPROPERTY('ProductMajorVersion') AS INT) AS ProductMajorVersion;

-- AT TIME ZONE : SQL Server 2016 (13.x) and later 


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetTZDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
    execute dbo.sp_executesql @statement = N'
        CREATE FUNCTION [dbo].[fn_GetTZDate] ()

        RETURNS datetime
        AS -- WITH ENCRYPTION AS
        BEGIN
            -- Declare the return variable here
            DECLARE @tzadj int, @sysdate datetime
            SET @sysdate = getdate()
            SET @tzadj = 0
            SELECT @tzadj = [tzAdjustment] FROM USysSecurity WHERE [WindowsUserName] = SYSTEM_USER
            if @tzadj <> 0
            BEGIN
                SET @sysdate = dateadd(hh, @tzadj, @sysdate)
            END

            -- Return the result of the function
            RETURN @sysdate
        END'
END
GO

select SERVERPROPERTY ('productversion')
, CASE
	WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '8%' THEN 8 -- 'SQL2000'
	WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '9%' THEN 9 -- 'SQL2005'
	WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.0%' THEN 10 -- 'SQL2008'
	WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.5%' THEN 10 -- 'SQL2008 R2'
	WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '11%' THEN 11 -- 'SQL2012'
	WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '12%' THEN 12 -- 'SQL2014'
	WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '13%' THEN 13 -- 'SQL2016'
	WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '14%' THEN 14 -- 'SQL2017'
	WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '15%' THEN 15 -- 'SQL2019'
	WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '16%' THEN 16 -- 'SQL2022'
	ELSE 0
END




SELECT
  CASE 
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '8%' THEN 'SQL2000'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '9%' THEN 'SQL2005'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.0%' THEN 'SQL2008'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.5%' THEN 'SQL2008 R2'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '11%' THEN 'SQL2012'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '12%' THEN 'SQL2014'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '13%' THEN 'SQL2016'     
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '14%' THEN 'SQL2017' 
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '15%' THEN 'SQL2019' 
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '16%' THEN 'SQL2022' 
     ELSE 'unknown'
  END AS MajorVersion,
  SERVERPROPERTY('ProductLevel') AS ProductLevel,
  SERVERPROPERTY('Edition') AS Edition,
  SERVERPROPERTY('ProductVersion') AS ProductVersion

/*
SQL Server Versions
-------------------------------------------------------------------------------------------------------------------------------
SQL Server 2000 - Microsoft SQL Server 2000 - 8.00.760 (Intel X86)
SQL Server 2005 - Microsoft SQL Server 2005 - 9.00.1399.06 (Intel X86)
SQL Server 2008 - Microsoft SQL Server 2008 (SP1) - 10.0.2573.0 (X64)
SQL Server 2008 R2 - Microsoft SQL Server 2008 R2 (RTM) - 10.50.1600.1 (X64)
SQL Server 2012 - Microsoft SQL Server 2012 - 11.0.2100.60 (X64)
SQL Server 2014 - Microsoft SQL Server 2014 - 12.0.2254.0 (X64)
SQL Server 2016 - Microsoft SQL Server 2016 (RTM) - 13.0.1601.5 (X64)
SQL Server 2017 - Microsoft SQL Server 2017 (RTM) - 14.0.1000.169 (X64)
SQL Server 2019 - Microsoft SQL Server 2019 (RTM) - 15.0.2000.5 (X64)
SQL Server 2022 - Microsoft SQL Server 2022 (CTP2.0) - 16.0.600.9 (X64)


DefinitionByPortfolioIdGet
Survey.DefinitionByPortfolioIdGet


YYYY-MM-DDThh:mm:ss[.nnnnnnn]
YYYY-MM-DDThh:mm:ss[.nnnnnnn]


This format is not affected by the SET LANGUAGE and SET DATEFORMAT session locale settings. The T, the colons (:) and the period (.) are included in the string literal, for example '2007-05-02T19:58:47.1234567'.

SQL datetimeoffset:

ISO 8601 	Description
YYYY-MM-DDThh:mm:ss[.nnnnnnn][{+|-}hh:mm] 	These two formats are not affected by the SET LANGUAGE and SET DATEFORMAT session locale settings. Spaces are not allowed between the datetimeoffset and the datetime parts.
YYYY-MM-DDThh:mm:ss[.nnnnnnn]Z (UTC) 	This format by ISO definition indicates the datetime portion should be expressed in Coordinated Universal Time (UTC). For example, 1999-12-12 12:30:30.12345 -07:00 should be represented as 1999-12-12 19:30:30.12345Z.


https://www.browserstack.com/guide/change-time-zone-in-chrome-for-testing

Method 1: Using Developer Tools to Change Chrome Timezone

To change the Chrome time zone for testing, follow the steps below:

    Open DevTools in Chrome -> Open the Console drawer.
    Click on the three-dotted menu -> Click on More tools -> Sensors.chrome set timezone for testing
    From the Sensors tab, set the location according to your preference and define the specific timezone.
    Refer to the image below to better understand how to set a timezone for testing in Chrome.
	
*/
