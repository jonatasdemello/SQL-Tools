If 1=0
begin

select dbo.udf_ConvertTimeZone ('2023-12-21 18:17:57', NULL, 'Eastern Standard Time'), 'CLR, NULL as @source_time_zone'
union all
select dbo.udf_ConvertTimeZone ('2023-12-21 18:17:57', 'UTC', 'Eastern Standard Time' ), 'CLR, UTC as @source_time_zone'
union all

select dbo.udf_ConvertAtTimeZone ('2023-12-21 18:17:57', NULL, 'Eastern Standard Time'), 'ATZ, NULL as @source_time_zone'
union all
select dbo.udf_ConvertAtTimeZone ('2023-12-21 18:17:57', 'UTC', 'Eastern Standard Time' ), 'ATZ, UTC as @source_time_zone'

end
go



    IF OBJECT_ID('tempdb..#UTCDates') IS NOT NULL 
    BEGIN
        DROP TABLE #UTCDates
    END

    CREATE TABLE #UTCDates
    (
        Id INT,
        source_Time DATETIME2,
        source_time_zone NVARCHAR(255),
	    destination_time_zone NVARCHAR(255),
        GMT_time_zone NVARCHAR(255),
        expected_time DATETIME2,
        result_time_clr DATETIME2,
		result_time_atz DATETIME2,
		result NVARCHAR(255)
    )

    insert into #UTCDates 
	(Id ,  source_Time         ,  expected_time       ,  source_time_zone      , destination_time_zone       , GMT_time_zone) values
    ( 1 , '2023-12-01 00:00:00', '2023-12-01 00:00:00', 'UTC'                  , 'UTC'                       , 'UTC'        ),
    ( 2 , '2023-12-01 00:00:00', '2023-12-01 00:00:00', 'UTC'                  , 'GMT Standard Time'         , 'GMT+0'      ),
    ( 3 , '2023-12-01 00:00:00', '2023-11-30 20:30:00', 'UTC'                  , 'Newfoundland Standard Time', 'GMT-3'      ),
    ( 4 , '2023-12-01 00:00:00', '2023-11-30 20:00:00', 'UTC'                  , 'Atlantic Standard Time'    , 'GMT-4'      ),
    ( 5 , '2023-12-01 00:00:00', '2023-11-30 19:00:00', 'UTC'                  , 'Eastern Standard Time'     , 'GMT-5'      ),
    ( 6 , '2023-12-01 00:00:00', '2023-11-30 18:00:00', 'UTC'                  , 'Central Standard Time'     , 'GMT-6'      ),
    ( 7 , '2023-12-01 00:00:00', '2023-11-30 17:00:00', 'UTC'                  , 'Mountain Standard Time'    , 'GMT-7'      ),
    ( 8 , '2023-12-01 00:00:00', '2023-11-30 16:00:00', 'UTC'                  , 'Pacific Standard Time'     , 'GMT-8'      ),
    ( 9 , '2023-12-01 00:00:00', '2023-11-30 15:00:00', 'UTC'                  , 'Alaskan Standard Time'     , 'GMT-9'      ),
    ( 10, '2023-12-01 00:00:00', '2023-11-30 14:00:00', 'UTC'                  , 'Hawaiian Standard Time'    , 'GMT-10'     ),
    --Local time zone: (GMT-08:00) Pacific Time (US & Canada) To Eastern Standard Time (U.S. and Canada).
    ( 11, '2010-01-01 00:01:00', '2010-01-01 03:01:00', 'Pacific Standard Time', 'Eastern Standard Time'     , 'GMT-5'      ),
    ( 12, '2009-12-31 19:01:00', '2009-12-31 22:01:00', 'Pacific Standard Time', 'Eastern Standard Time'     , 'GMT-5'      ),
    ( 13, '2010-01-01 00:01:00', '2010-01-01 03:01:00', 'Pacific Standard Time', 'Eastern Standard Time'     , 'GMT-5'      ),
    ( 14, '2010-11-06 23:30:00', '2010-11-07 01:30:00', 'Pacific Standard Time', 'Eastern Standard Time'     , 'GMT-5'      ),
    ( 15, '2010-11-07 02:30:00', '2010-11-07 05:30:00', 'Pacific Standard Time', 'Eastern Standard Time'     , 'GMT-5'      ),
	-- TESTING NULL PARAMS
    ( 16, '2023-12-21 18:17:57', '2023-12-21 13:17:57',  NULL ,  NULL, 'GMT-5' ),
    ( 17, '2023-12-21 18:17:57', '2023-12-21 13:17:57', 'UTC' ,  NULL, 'GMT-5'  ),
    ( 18, '2023-12-21 18:17:57', '2023-12-21 13:17:57',  NULL , 'Eastern Standard Time'     , 'GMT-5'  ),
    ( 19, '2023-12-21 18:17:57', '2023-12-21 13:17:57', 'UTC' , 'Eastern Standard Time'     , 'GMT-5'  )


--if (source_time_zone == null)      {source_time_zone = "UTC"; }
--if (destination_time_zone == null) {destination_time_zone = "Eastern Standard Time"; }

--select dbo.udf_ConvertTimeZone ('2023-12-21 18:17:57', NULL, NULL), 'CLR, NULL as @source_time_zone'
--select dbo.udf_ConvertTimeZone ('2023-12-21 18:17:57', 'UTC', 'Eastern Standard Time' ), 'CLR, UTC as @source_time_zone'
--SELECT dbo.udf_ConvertATTimeZone ('2023-12-21 18:17:57', NULL, 'Pacific Standard Time'), 'ATZ, NULL as @source_time_zone'
--select dbo.udf_ConvertAtTimeZone ('2023-12-21 18:17:57', 'UTC', 'Pacific Standard Time' ), 'ATZ, UTC as @source_time_zone'


    update #UTCDates set result_time_clr = dbo.udf_ConvertTimeZone(source_Time, source_time_zone, destination_time_zone)
	update #UTCDates set result_time_atz = dbo.udf_ConvertAtTimeZone(source_Time, source_time_zone, destination_time_zone)

	update #UTCDates set [result] = 'OK' WHERE result_time_clr = expected_time 
	update #UTCDates set [result] = 'FAIL' WHERE result_time_clr != expected_time 
	update #UTCDates set [result] = 'FAIL' WHERE result_time_clr != ISNULL(result_time_atz, '')


	SELECT * FROM #UTCDates

    IF OBJECT_ID('tempdb..#UTCDates') IS NOT NULL 
    BEGIN
        DROP TABLE #UTCDates
    END

