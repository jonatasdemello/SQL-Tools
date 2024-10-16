-- https://sqlundercover.com/2019/12/03/troubleshooting-resource-semaphore-and-memory-grants/

SELECT * 
FROM sys.dm_exec_query_memory_grants
ORDER BY granted_memory_kb DESC

	
SELECT text FROM sys.dm_exec_sql_text(<plan handle>)
	
SELECT query_plan FROM sys.dm_exec_query_plan(<plan handle>)

-- https://www.mssqltips.com/sqlservertip/2827/troubleshooting-sql-server-resourcesemaphore-waittype-memory-issues/

-- Identify RESOURCE_SEMAPHORE Waits

--Step 1

SELECT * FROM SYSPROCESSES ORDER BY lastwaittype

-- Step 2

SELECT * FROM sys.dm_exec_query_resource_semaphores

-- Step 3

SELECT * FROM sys.dm_exec_query_memory_grants

-- Step 4

select top 10 * from sys.dm_exec_query_memory_grants

-- Step 5

SELECT * FROM sys.dm_exec_sql_text(sql_handle)


-- Find the SQL code
-- We can also get the SQL plan using the plan_handle from the query in Step 4.

SELECT * FROM sys.dm_exec_sql_plan(plan_handle)

