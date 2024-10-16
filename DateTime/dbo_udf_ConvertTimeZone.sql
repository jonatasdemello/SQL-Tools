IF EXISTS (SELECT * FROM information_schema.routines WHERE routine_type = 'function' AND routine_schema = 'dbo' AND routine_name = 'udf_ConvertTimeZone')
BEGIN 
	DROP FUNCTION dbo.udf_ConvertTimeZone
END
GO

/*
--- SQL versions for reference (until 2024-04) ---
	SQL Server 2000    - 8.00.x
	SQL Server 2005    - 9.00.x
	SQL Server 2008    - 10.0.x
	SQL Server 2008 R2 - 10.5.x
	SQL Server 2012    - 11.0.x
	SQL Server 2014    - 12.0.x
	SQL Server 2016    - 13.0.x
	SQL Server 2017    - 14.0.x
	SQL Server 2019    - 15.0.x
	SQL Server 2022    - 16.0.x
*/

IF EXISTS (SELECT 'Linux' WHERE @@Version LIKE '%linux%')
	OR EXISTS (SELECT 'Azure' WHERE @@Version LIKE '%Azure%')
BEGIN
	-- Azure: only accepts assemblies if they are trusted and signed with a certificate or an asymmetric key
	-- Linux / Docker / Azure: does not support Assemblies, and must use AT TIME ZONE instead 
	-- "AT TIME ZONE" is available if SQL_SERVER >= SQL2016 (13.x) OR Azure
	-- https://learn.microsoft.com/en-us/sql/t-sql/queries/at-time-zone-transact-sql?view=sql-server-ver16
	IF EXISTS (SELECT 1 WHERE CAST(SERVERPROPERTY('ProductMajorVersion') AS INT) >= 13 )
		OR EXISTS (SELECT 'Azure' WHERE @@Version LIKE '%Azure%')
	BEGIN
		execute dbo.sp_executesql @statement = N'
CREATE FUNCTION dbo.udf_ConvertTimeZone
(
	@datetime DATETIME,
	@source_time_zone NVARCHAR(255),
	@destination_time_zone NVARCHAR(255) 
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @RESULT DATETIME2

	IF (@source_time_zone IS NULL)
		SELECT @source_time_zone = ''UTC''

	IF (@destination_time_zone IS NULL )
		SELECT @destination_time_zone = ''Eastern Standard Time''

	SELECT @RESULT = @datetime AT TIME ZONE @source_time_zone AT TIME ZONE @destination_time_zone

	RETURN @RESULT
END'
	END
	ELSE
	BEGIN
		RAISERROR('Error: minimal supported version is SQL SQL2016 (13.x)', 16, 1);
	END
END
ELSE
BEGIN
	-- Windows: only create CLR Assembly if OS = Windows (SQL Server)
	execute dbo.sp_executesql @statement = N'
CREATE FUNCTION dbo.udf_ConvertTimeZone
(
	@datetime DATETIME,
	@source_time_zone NVARCHAR(255),
	@destination_time_zone NVARCHAR(255) 
)
RETURNS DATETIME
AS
	EXTERNAL NAME TimeZoneInfo.UserDefinedFunctions.convert_timezone;'
END
GO
