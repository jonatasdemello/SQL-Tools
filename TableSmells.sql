/**
Heaps (Tables without Clustered Indexes)

summary:   >
 This query finds the following table smells
 1/ is a Wide table (set this to what you consider to be wide)
 2/ is a Heap - Heaps (Tables without Clustered Indexes)
 3/ is an undocumented table
 4/ Has no Primary Key
 5/ Has no index at all
 6/ No candidate key (unique constraint on column(s))
 7/ Has disabled Index(es)
 8/ Has disabled constraint(s)'
 9/ Has untrusted constraint(s)'
10/ Has a disabled Foreign Key'
11/ Has untrusted FK'
12/ Has unrelated to any other table'
13/ Has unintelligible column names'
14/ Has a foreign key that has no index'
15/ Has a GUID in a clusterd Index
16/ Has non-compliant column names'
17/ Has a trigger that has'nt got NOCOUNT ON'
18/ Is not referenced by any procedure, view or function'
19/ Has  a disabled trigger' 
20/ Can't be indexed'
Revisions:
 - Author: Phil Factor
   Version: 1.1
   Modification: Added tests as suggested by comments to blog
   date: 30 Mar 2016
 returns:   >
 single result of table name, and list of problems        
**/     

WITH TableSmells (TableName, Problem, Object_ID )AS
(
SELECT object_schema_name(Object_ID)+'.'+object_name(Object_ID), problem,Object_ID FROM
  (
  SELECT object_id, 'wide (more than 15 columns)'
    FROM sys.tables /* see whether the table has more than 15 columns */
    WHERE  max_column_id_used>15
  UNION ALL
    SELECT DISTINCT sys.tables.object_id, 'heap'
      FROM sys.indexes/* see whether the table is a heap */
      INNER JOIN sys.tables ON sys.tables.object_ID=sys.indexes.object_ID
      WHERE sys.indexes.type=0
  UNION ALL
     SELECT s.[object_ID], 'Undocumented table'
       FROM sys.objects s /* it has no extended properties */
       LEFT OUTER JOIN sys.extended_properties ep
       ON s.object_ID=ep.major_ID AND minor_ID=0
     WHERE type_desc='USER_TABLE'
       AND ep.value IS NULL
  UNION ALL
    SELECT sys.tables.object_id, 'No primary key'
      FROM sys.tables/* see whether the table has a primary key */
      WHERE objectproperty(OBJECT_ID,'TableHasPrimaryKey') = 0
  UNION ALL
    SELECT sys.tables.object_id, 'No index at all'
      FROM sys.tables /* see whether the table has any index */
      WHERE objectproperty(OBJECT_ID,'TableHasIndex') = 0
  UNION ALL
       SELECT sys.tables.object_id, 'No candidate key'
      FROM sys.tables/* if no unique constraint then it isn't relational */
      WHERE objectproperty(OBJECT_ID,'TableHasUniqueCnst') = 0
      AND   objectproperty(OBJECT_ID,'TableHasPrimaryKey') = 0
  UNION ALL
    SELECT DISTINCT object_id, 'disabled Index(es)'
      FROM sys.indexes /* don't leave these lying around */
      WHERE is_disabled=1
  UNION ALL
    SELECT DISTINCT parent_object_id, 'disabled constraint(s)'
      FROM sys.check_constraints /* hmm. i wonder why */
      WHERE is_disabled=1
  UNION ALL
    SELECT DISTINCT parent_object_id, 'untrusted constraint(s)'
      FROM sys.check_constraints /* ETL gone bad? */
      WHERE is_not_trusted=1
  UNION ALL
    SELECT DISTINCT parent_object_id, 'disabled FK'
      FROM sys.foreign_keys /* build script gone bad? */
      WHERE is_disabled=1
  UNION ALL
    SELECT DISTINCT Parent_object_id, 'untrusted FK'
      FROM sys.foreign_keys /* Why do you have untrusted FKs?       
      Constraint was enabled without checking existing rows;
      therefore, the constraint may not hold for all rows. */
      WHERE is_not_trusted=1
  UNION ALL
    SELECT  sys.tables.object_id, 'unrelated to any other table'
      FROM sys.tables /* found a simpler way! */
      WHERE objectpropertyex(OBJECT_ID,'TableHasForeignKey')=0
      AND objectpropertyex(OBJECT_ID,'TableHasForeignRef')=0
  UNION ALL
    SELECT DISTINCT object_id, 'unintelligible column names'
      FROM sys.columns /* column names with no letters in them */
      WHERE name COLLATE  Latin1_general_CI_AI
            NOT LIKE '%[A-Z]%' COLLATE Latin1_general_CI_AI
  UNION ALL
    SELECT 
    keys.parent_Object_ID,'foreign key '+ keys.Name+' has no index'
      FROM sys.foreign_keys keys
     INNER JOIN sys.foreign_key_columns TheColumns
       ON Keys.Object_ID=constraint_object_id  
     LEFT OUTER JOIN sys.index_columns ic
       ON ic.object_ID=TheColumns.parent_Object_Id
       AND ic.column_ID=TheColumns.parent_Column_Id
       AND TheColumns.constraint_column_ID=ic.key_ordinal
     WHERE ic.object_ID IS NULL
  UNION ALL
    SELECT Ic.Object_ID, 
           col_name(Ic.Object_Id, Ic.Column_Id) +
              ' is a GUID in a clustered index' /* GUID in a clusterd IX */
      FROM Sys.Index_Columns AS Ic
      INNER JOIN sys.columns c
        ON c.object_ID=ic.object_ID
        AND c.column_ID=ic.column_ID
      INNER JOIN sys.types t
        ON t.system_type_id=c.system_type_id
      INNER JOIN sys.indexes i
        ON i.object_ID=ic.object_ID
        AND i.index_ID=ic.index_ID
      WHERE t.name='uniqueidentifier'
      AND type_desc='CLUSTERED'
      AND objectproperty(ic.OBJECT_ID,'IsSystemTable') = 0
  UNION ALL
    SELECT DISTINCT object_id, 'non-compliant column names'
      FROM sys.columns /* column names that need delimiters*/
      WHERE name COLLATE  Latin1_general_CI_AI
          LIKE '%[^_@$#A-Z0-9]%' COLLATE  Latin1_general_CI_AI
  UNION ALL /* Triggers lacking `SET NOCOUNT ON`, which can cause unexpected results WHEN USING OUTPUT */
      SELECT ta.object_id, 'This table''s trigger, '+object_name(tr.object_ID)+', has''nt got NOCOUNT ON'
      FROM sys.tables ta /* see whether the table has any index */
         INNER JOIN sys.triggers tr ON tr.parent_ID = ta.object_ID
         INNER JOIN sys.sql_modules mo ON tr.object_ID=mo.object_ID
       WHERE definition NOT LIKE '%set nocount on%'
  UNION ALL /* table not referenced by any routine */
   SELECT  sys.tables.object_id, 'not referenced by procedure, view or function'
     FROM sys.tables /* found a simpler way! */
     left outer join sys.sql_expression_dependencies
       on referenced_id =sys.tables.object_id
     where referenced_id is null
  UNION ALL
    SELECT DISTINCT parent_ID, 'has a disabled trigger' 
      FROM sys.triggers
      WHERE is_disabled=1 AND parent_ID>0
  UNION ALL
    SELECT sys.tables.object_id, 'can''t be indexed'
      FROM sys.tables/* see whether the table has a primary key */
      WHERE objectproperty(OBJECT_ID,'IsIndexable') = 0
  )f(Object_ID,Problem)
)
SELECT TableName,
       CASE WHEN count(*)>1 THEN /*only do correlated subquery when necessary*/
       stuff(( SELECT ', '+problem
           FROM TableSmells t2
          WHERE t1.tableName = t2.TableName
          ORDER BY problem
           FOR XML PATH(''), TYPE).value(N'(./text())[1]',N'varchar(8000)'),1,2,'')
       ELSE max(problem) END as symptoms
  FROM TableSmells t1
  WHERE OBJECTPROPERTYEX(t1.object_ID, 'IsTable')=1
  and OBJECTPROPERTYEX(t1.object_ID, 'IsSystemTable')=0
  GROUP BY TableName;