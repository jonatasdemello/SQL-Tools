SELECT 
    d.name,
    d.is_query_store_on
FROM sys.databases AS d 


--This DMV sys.database_query_store_options should allow you to determine if QUERY_STORE is enabled:

SELECT  desired_state_desc ,
        actual_state_desc ,
        readonly_reason, 
        current_storage_size_mb , 
        max_storage_size_mb ,
        max_plans_per_query 
FROM    sys.database_query_store_options ;

/*
Description of Actual_state_Desc states :

OFF (0)

    -Not Enabled

READ_ONLY (1)

    Query Store may operate in read-only mode even if read-write was specified by the user. 
	For example, that might happen if the database is in read-only mode or if Query Store size exceeded the quota

READ_WRITE (2)

    Query store is on and it is capturing all queries

ERROR (3)

    Extremely rarely, Query Store can end up in ERROR state because of internal errors. 
	In case of memory corruption, Query Store can be recovered by requesting READ_WRITE mode explicitly, 
	using the ALTER DATABASE SET QUERY_STORE statement. 
	In case of corruption on the disk, data must be cleared before READ_WRITE mode is requested explicitly.
*/