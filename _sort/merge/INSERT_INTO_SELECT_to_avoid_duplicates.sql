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

