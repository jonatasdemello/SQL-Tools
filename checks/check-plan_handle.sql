-- 
SELECT plan_handle, execution_count, query_plan
INTO #tmpPlan
FROM sys.dm_exec_query_stats
     CROSS APPLY sys.dm_exec_query_plan(plan_handle);
GO

WITH XMLNAMESPACES('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS sp)
SELECT plan_handle, stmt.stmt_details.value('@Database', 'varchar(max)') 'Database', stmt.stmt_details.value('@Schema', 'varchar(max)') 'Schema', stmt.stmt_details.value('@Table', 'varchar(max)') 'table'
INTO #tmp2
FROM(SELECT CAST(query_plan AS XML) sqlplan, plan_handle FROM #tmpPlan) AS p
    CROSS APPLY sqlplan.nodes('//sp:Object') AS stmt(stmt_details);
GO

SELECT t.plan_handle, [Database], [Schema], [table], execution_count
FROM(SELECT DISTINCT plan_handle, [Database], [Schema], [table]
     FROM #tmp2
     WHERE [table] LIKE '%@%' OR [table] LIKE '%#%') AS t
    JOIN #tmpPlan AS t2 ON t.plan_handle=t2.plan_handle;

-- return this:
/*
sql_handle	statement_start_offset	statement_end_offset	plan_generation_num	plan_handle	creation_time	last_execution_time	execution_count	total_worker_time	last_worker_time	min_worker_time	max_worker_time	total_physical_reads	last_physical_reads	min_physical_reads	max_physical_reads	total_logical_writes	last_logical_writes	min_logical_writes	max_logical_writes	total_logical_reads	last_logical_reads	min_logical_reads	max_logical_reads	total_clr_time	last_clr_time	min_clr_time	max_clr_time	total_elapsed_time	last_elapsed_time	min_elapsed_time	max_elapsed_time	query_hash	query_plan_hash	total_rows	last_rows	min_rows	max_rows	statement_sql_handle	statement_context_id	total_dop	last_dop	min_dop	max_dop	total_grant_kb	last_grant_kb	min_grant_kb	max_grant_kb	total_used_grant_kb	last_used_grant_kb	min_used_grant_kb	max_used_grant_kb	total_ideal_grant_kb	last_ideal_grant_kb	min_ideal_grant_kb	max_ideal_grant_kb	total_reserved_threads	last_reserved_threads	min_reserved_threads	max_reserved_threads	total_used_threads	last_used_threads	min_used_threads	max_used_threads	total_columnstore_segment_reads	last_columnstore_segment_reads	min_columnstore_segment_reads	max_columnstore_segment_reads	total_columnstore_segment_skips	last_columnstore_segment_skips	min_columnstore_segment_skips	max_columnstore_segment_skips	total_spills	last_spills	min_spills	max_spills	total_num_physical_reads	last_num_physical_reads	min_num_physical_reads	max_num_physical_reads	total_page_server_reads	last_page_server_reads	min_page_server_reads	max_page_server_reads	total_num_page_server_reads	last_num_page_server_reads	min_num_page_server_reads	max_num_page_server_reads
0x0300050000D22B22B7192B0078AC000001000000000000000000000000000000000000000000000000000000	176	386	1	0x0500050000D22B2230F99668B701000001000000000000000000000000000000000000000000000000000000	2020-11-19 02:39:38.283	2020-11-20 15:49:22.720	10751	1110671	50	28	3513	4383	0	0	48	0	0	0	0	33510	3	3	6	0	0	0	0	21152995	50	28	1141307	0x07C4D9485C5F730F	0x8167A6FC1691E1C6	10751	1	1	1	0x0900B6F7745173F7991BC49F9DBF6F79E4260000000000000000000000000000000000000000000000000000	3	10751	1	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1621	0	0	6	0	0	0	0	0	0	0	0
*/
