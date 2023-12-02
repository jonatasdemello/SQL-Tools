-- https://cc.davelozinski.com/sql/fastest-way-to-insert-new-records-where-one-doesnt-already-exist

INSERT INTO #table1 (Id, guidd, TimeAdded, ExtraData)
SELECT Id, guidd, TimeAdded, ExtraData
FROM #table2
WHERE NOT EXISTS (Select Id, guidd From #table1 WHERE #table1.id = #table2.id)

-----------------------------------
MERGE #table1 as [Target]

USING  
	(select Id, guidd, TimeAdded, ExtraData from #table2) as [Source]
	(id, guidd, TimeAdded, ExtraData)
	ON [Target].id =[Source].id
WHEN NOT MATCHED THEN
    INSERT (id, guidd, TimeAdded, ExtraData)
    VALUES ([Source].id, [Source].guidd, [Source].TimeAdded, [Source].ExtraData);

------------------------------ best > 5,000,000 rows
INSERT INTO #table1 (id, guidd, TimeAdded, ExtraData)
SELECT id, guidd, TimeAdded, ExtraData from #table2
EXCEPT
SELECT id, guidd, TimeAdded, ExtraData from #table1

------------------------------ best < 5,000,000 rows
INSERT INTO #table1 (id, guidd, TimeAdded, ExtraData)
SELECT #table2.id, #table2.guidd, #table2.TimeAdded, #table2.ExtraData
FROM #table2
LEFT JOIN #table1 on #table1.id = #table2.id
WHERE #table1.id is null

-------------------------------------------------------------------------------------------------------------------------------
/*
Table1       Table2
-------      -------
ID Name      ID Name
1  A         1  Z
2  B
3  C
*/

-- NOT EXISTS

INSERT INTO TABLE_2 (id, name)
	SELECT t1.id, t1.NAME  
	FROM TABLE_1 t1 
	WHERE NOT EXISTS (SELECT id FROM TABLE_2 t2 WHERE t2.id = t1.id)


-- NOT IN

INSERT INTO TABLE_2 (id, name)
	SELECT t1.id, t1.NAME 
	FROM TABLE_1 t1 
	WHERE t1.id NOT IN (SELECT id FROM TABLE_2)


-- LEFT JOIN/IS NULL

INSERT INTO TABLE_2 (id, name)
   SELECT t1.id, t1.NAME 
   FROM TABLE_1 t1 
   LEFT JOIN TABLE_2 t2 ON t2.id = t1.id 
   WHERE t2.id IS NULL
   

--Of the three options, the LEFT JOIN/IS NULL is less efficient.  

-- See <a href="http://explainextended.com/2009/09/15/not-in-vs-not-exists-vs-left-join-is-null-sql-server/"> 
-- this link for more details
