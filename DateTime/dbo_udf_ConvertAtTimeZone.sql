IF EXISTS (SELECT * FROM information_schema.routines WHERE routine_type = 'function' AND routine_schema = 'dbo' AND routine_name = 'udf_ConvertAtTimeZone')
BEGIN 
	DROP FUNCTION dbo.udf_ConvertAtTimeZone
END
GO

-- Create a NEW function so we can test and compare results without changing the current CLR behaviour
-- Use "AT TIME ZONE" if SQL_SERVER >= SQL2016 (13.x) OR Azure
-- ref: https://learn.microsoft.com/en-us/sql/t-sql/queries/at-time-zone-transact-sql?view=sql-server-ver16
-- Applies to: 
--        SQL Server 2016 (13.x) and later 
--        Azure SQL Database 
--        Azure SQL Managed Instance 
--        Azure Synapse Analytics SQL analytics endpoint in Microsoft Fabric 
--        Warehouse in Microsoft Fabric
--        SQL Server on Linux


IF EXISTS (SELECT 1 WHERE CAST(SERVERPROPERTY('ProductMajorVersion') AS INT) >= 13 )
	OR EXISTS (SELECT 'Azure' WHERE @@Version LIKE '%Azure%')
BEGIN
	execute dbo.sp_executesql @statement = N'
CREATE FUNCTION dbo.udf_ConvertAtTimeZone
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
GO
