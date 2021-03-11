-- Check Indexes
-- https://www.red-gate.com/simple-talk/sql/performance/identifying-and-solving-index-scan-problems/


SELECT OBJECT_SCHEMA_NAME(s.[object_id]), OBJECT_NAME(S.[OBJECT_ID]) AS [OBJECT NAME], 
	I.[NAME] AS [INDEX NAME], 
	USER_SEEKS, 
	S.USER_SCANS, 
	USER_LOOKUPS, 
	USER_UPDATES,
	last_user_scan,
	last_user_seek,
	last_user_lookup
FROM     SYS.DM_DB_INDEX_USAGE_STATS AS S 
	INNER JOIN SYS.INDEXES AS I 
	ON I.[OBJECT_ID] = S.[OBJECT_ID] 
		AND I.INDEX_ID = S.INDEX_ID 
WHERE last_user_scan IS NULL 
AND last_user_seek IS NULL
AND last_user_lookup IS NULL

