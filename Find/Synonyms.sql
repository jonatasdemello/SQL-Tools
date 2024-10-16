-- Synonyms
SELECT 
	Schema_name(s.schema_id) AS [Schema],
	s.NAME                   AS [Name],
	s.object_id              AS [ID],
	N''                      AS [BaseDatabase],
	N''                      AS [BaseObject],
	N''                      AS [BaseSchema],
	N''                      AS [BaseServer],
	CASE Objectpropertyex(s.object_id, 'BaseType')
	 WHEN N'U' THEN 1
	 WHEN N'V' THEN 2
	 WHEN N'P' THEN 3
	 WHEN N'FN' THEN 4
	 WHEN N'TF' THEN 5
	 WHEN N'IF' THEN 6
	 WHEN N'X' THEN 7
	 WHEN N'RF' THEN 8
	 WHEN N'PC' THEN 9
	 WHEN N'FS' THEN 10
	 WHEN N'FT' THEN 11
	 WHEN N'AF' THEN 12
	 ELSE 0
	END                      AS [BaseType],
	s.base_object_name       AS [BaseObjectName]
FROM
	sys.synonyms AS s
ORDER BY
	[schema] ASC,
	[name] ASC  
