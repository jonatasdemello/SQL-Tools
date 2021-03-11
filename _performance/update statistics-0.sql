-- update statistics

--I ran into this issue on a specific copy of a database. 
--After poking at it, I came to the conclusion that it was a bad query plan accessing the system tables. 
--sp_updatestats doesn't update stats on system tables. So here's my quick hack:

SELECT 'UPDATE STATISTICS ' + QUOTENAME(S.[name], '[') + '.' + QUOTENAME(O.[name], '[') + ' WITH FULLSCAN;' AS [SQL]
FROM sys.objects AS O JOIN sys.schemas AS S ON O.[schema_id] = S.[schema_id]
WHERE O.[type_desc] = 'SYSTEM_TABLE';

--Take the output from that, paste it into a query window, and run it. 
--That will update statistics on all of the system tables in the affected database. 
--Voila - the offending query now has good statistics, generates a better query plan, 
-- and runs in a second or two (instead of timing out after 15 minutes).

