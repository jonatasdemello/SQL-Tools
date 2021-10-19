-- https://cc.davelozinski.com/sql/fastest-way-to-insert-new-records-where-one-doesnt-already-exist

INSERT INTO #table1 (Id, guidd, TimeAdded, ExtraData)
SELECT Id, guidd, TimeAdded, ExtraData
FROM #table2
WHERE NOT EXISTS (Select Id, guidd From #table1 WHERE #table1.id = #table2.id)

-----------------------------------
MERGE #table1 as [Target]
USING  (select Id, guidd, TimeAdded, ExtraData from #table2) as [Source]
(id, guidd, TimeAdded, ExtraData)
    on [Target].id =[Source].id
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


