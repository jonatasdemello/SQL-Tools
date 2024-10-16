-- Index Those Foreign Keys
-- https://jasonstrate.com/2010/06/18/index-those-foreign-keys/


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

;WITH cindexes AS 
(SELECT i.object_id,
	i.NAME,
	(SELECT Quotename(ic.column_id, '(') FROM   sys.index_columns ic
	 WHERE  i.object_id = ic.object_id 
			AND i.index_id = ic.index_id
			AND is_included_column = 0
	 ORDER  BY key_ordinal ASC
	 FOR xml path('')) AS indexed_compare
         FROM   sys.indexes i),
     cforeignkeys
     AS (SELECT fk.NAME                             AS foreign_key_name,
                'PARENT'                            AS foreign_key_type,
                fkc.parent_object_id                AS object_id,
                Stuff((SELECT ', ' + Quotename(c.NAME)
                       FROM   sys.foreign_key_columns ifkc
                              INNER JOIN sys.columns c
                                      ON ifkc.parent_object_id = c.object_id
                                         AND ifkc.parent_column_id = c.column_id
                       WHERE  fk.object_id = ifkc.constraint_object_id
                       ORDER  BY ifkc.constraint_column_id
                       FOR xml path('')), 1, 2, '') AS fk_columns,
                (SELECT Quotename(ifkc.parent_column_id, '(')
                 FROM   sys.foreign_key_columns ifkc
                 WHERE  fk.object_id = ifkc.constraint_object_id
                 ORDER  BY ifkc.constraint_column_id
                 FOR xml path(''))                  AS fk_columns_compare
         FROM   sys.foreign_keys fk
                INNER JOIN sys.foreign_key_columns fkc
                        ON fk.object_id = fkc.constraint_object_id
         WHERE  fkc.constraint_column_id = 1
         UNION ALL
         SELECT fk.NAME                             AS foreign_key_name,
                'REFERENCED'                        AS foreign_key_type,
                fkc.referenced_object_id            AS object_id,
                Stuff((SELECT ', ' + Quotename(c.NAME)
                       FROM   sys.foreign_key_columns ifkc
                              INNER JOIN sys.columns c
                                      ON ifkc.referenced_object_id = c.object_id
                                         AND ifkc.referenced_column_id =
                                             c.column_id
                       WHERE  fk.object_id = ifkc.constraint_object_id
                       ORDER  BY ifkc.constraint_column_id
                       FOR xml path('')), 1, 2, '') AS fk_columns,
                (SELECT Quotename(ifkc.referenced_column_id, '(')
                 FROM   sys.foreign_key_columns ifkc
                 WHERE  fk.object_id = ifkc.constraint_object_id
                 ORDER  BY ifkc.constraint_column_id
                 FOR xml path(''))                  AS fk_columns_compare
         FROM   sys.foreign_keys fk
                INNER JOIN sys.foreign_key_columns fkc
                        ON fk.object_id = fkc.constraint_object_id
         WHERE  fkc.constraint_column_id = 1),
     crowcount
     AS (SELECT object_id,
                Sum(row_count) AS row_count
         FROM   sys.dm_db_partition_stats ps
         WHERE  index_id IN ( 1, 0 )
         GROUP  BY object_id)
SELECT
'--Missing foreign key index for '
+ fk.foreign_key_name + Char(13) + Char(10) + 'GO'
+ Char(13) + Char(10)+
+ 'CREATE NONCLUSTERED INDEX FKIX_'
+ Object_name(fk.object_id) + '_'
+ Replace(Replace(Replace(Replace(fk.fk_columns, ',', ''), '[', ''), ']', ''), ' ', '')
+ Char(13) + Char(10)+ + 'ON [dbo].['
+ Object_name(fk.object_id) + '] ('
+ fk.fk_columns + ')' + Char(13) + Char(10)+ + 'GO'
+ Char(13) + Char(10) + Char(13) + Char(10)
FROM   cforeignkeys fk
       INNER JOIN crowcount rc ON fk.object_id = rc.object_id
       LEFT OUTER JOIN cindexes i ON fk.object_id = i.object_id AND i.indexed_compare LIKE fk.fk_columns_compare + '%'
WHERE  i.NAME IS NULL
ORDER  BY Object_name(fk.object_id), fk.fk_columns  
		  
		  
		  
-- Foreign Key Monitoring

 SET TRANSACTION isolation level READ uncommitted ;WITH cindexes AS
(
       SELECT i.object_id ,
              i.NAME ,
              (
                       SELECT   Quotename(ic.column_id,'(')
                       FROM     sys.index_columns ic
                       WHERE    i.object_id = ic.object_id
                       AND      i.index_id = ic.index_id
                       AND      is_included_column = 0
                       ORDER BY key_ordinal ASC FOR xml path('')) AS indexed_compare
       FROM   sys.indexes i ), cforeignkeys AS
(
           SELECT     fk.NAME              AS foreign_key_name ,
                      'PARENT'             AS foreign_key_type ,
                      fkc.parent_object_id AS object_id ,
                      Stuff(
                      (
                                 SELECT     ', ' + Quotename(c.NAME)
                                 FROM       sys.foreign_key_columns ifkc
                                 INNER JOIN sys.columns c
                                 ON         ifkc.parent_object_id = c.object_id
                                 AND        ifkc.parent_column_id = c.column_id
                                 WHERE      fk.object_id = ifkc.constraint_object_id
                                 ORDER BY   ifkc.constraint_column_id FOR xml path('')), 1, 2, '') AS fk_columns ,
                      (
                               SELECT   Quotename(ifkc.parent_column_id,'(')
                               FROM     sys.foreign_key_columns ifkc
                               WHERE    fk.object_id = ifkc.constraint_object_id
                               ORDER BY ifkc.constraint_column_id FOR xml path('')) AS fk_columns_compare
           FROM       sys.foreign_keys fk
           INNER JOIN sys.foreign_key_columns fkc
           ON         fk.object_id = fkc.constraint_object_id
           WHERE      fkc.constraint_column_id = 1
           UNION ALL
           SELECT     fk.NAME                  AS foreign_key_name ,
                      'REFERENCED'             AS foreign_key_type ,
                      fkc.referenced_object_id AS object_id ,
                      Stuff(
                      (
                                 SELECT     ', ' + Quotename(c.NAME)
                                 FROM       sys.foreign_key_columns ifkc
                                 INNER JOIN sys.columns c
                                 ON         ifkc.referenced_object_id = c.object_id
                                 AND        ifkc.referenced_column_id = c.column_id
                                 WHERE      fk.object_id = ifkc.constraint_object_id
                                 ORDER BY   ifkc.constraint_column_id FOR xml path('')), 1, 2, '') AS fk_columns ,
                      (
                               SELECT   Quotename(ifkc.referenced_column_id,'(')
                               FROM     sys.foreign_key_columns ifkc
                               WHERE    fk.object_id = ifkc.constraint_object_id
                               ORDER BY ifkc.constraint_column_id FOR xml path('')) AS fk_columns_compare
           FROM       sys.foreign_keys fk
           INNER JOIN sys.foreign_key_columns fkc
           ON         fk.object_id = fkc.constraint_object_id
           WHERE      fkc.constraint_column_id = 1 ), crowcount AS
(
         SELECT   object_id ,
                  Sum(row_count) AS row_count
         FROM     sys.dm_db_partition_stats ps
         WHERE    index_id IN (1,0)
         GROUP BY object_id )
SELECT fk.foreign_key_name ,
       Object_name(fk.object_id) AS fk_table_name ,
       fk.fk_columns ,
       rc.row_count AS row_count ,
       cast('&lt;!--dex  &#039;+CHAR(13)+CHAR(10)+&#039;Missing foreign key index for &#039;+fk.foreign_key_name+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+&#039;USE [&#039;+DB_NAME()+&#039;]&#039;<br> +CHAR(13)+CHAR(10)+'go'+CHAR(13)+CHAR(10)+ +'go'+char(13)+char(10)+'--?>' AS xml) foreign_key_index_schema
FROM                      cforeignkeys fk
INNER JOIN                crowcount rc
ON                        fk.object_id = rc.object_id
LEFT OUTER JOIN           cindexes i
ON                        fk.object_id = i.object_id
AND                       i.indexed_compare LIKE fk.fk_columns_compare + '%'
WHERE                     i.NAME IS NULL
ORDER BY                  object_name
                          (
                                                    fk.object_id
                          )
                          ,
                          fk.fk_columns 