-- FIND IDENTITY COLUMN:

select * from CollegeSuccess.ApplicationMethod

SELECT * FROM information_schema.columns
	WHERE table_schema = 'CollegeSuccess'
	  AND table_name = 'ApplicationMethod'
      AND column_name = 'ApplicationMethodId'

SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE TABLE_NAME = 'ApplicationMethod';

SELECT top 5 * FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS

-------------------------------------------------------------------------------------------------------------------------------
-- Method 1 : (sys.columns)
SELECT OBJECT_NAME([object_id]) AS [Table_Name], [name] AS [Column_Name], is_identity
FROM sys.columns
WHERE is_identity = 1 AND OBJECTPROPERTY(object_id, 'IsUserTable') = 1 AND OBJECT_NAME([object_id]) = 'ApplicationMethod'

-------------------------------------------------------------------------------------------------------------------------------
-- Method 2 : (sys.objects & sys.all_columns) 
SELECT A.[name] AS [Table_Name], B.[name] AS [Column_Name], B.is_identity
FROM sys.objects A
     INNER JOIN sys.all_columns B ON A.[object_id] = B.[object_id]
WHERE A.type = 'U' AND is_identity = 1 AND A.[name] = 'ApplicationMethod'

-------------------------------------------------------------------------------------------------------------------------------
-- Method 3 : (sys.tables & sys.all_columns)
SELECT A.[name] AS [Table_Name], B.[name] AS [Column_Name], B.is_identity
FROM sys.tables A
     INNER JOIN sys.all_columns B ON A.[object_id] = B.[object_id]
WHERE A.type = 'U' AND is_identity = 1 AND A.name = 'ApplicationMethod'

-------------------------------------------------------------------------------------------------------------------------------
-- Method 4 : (sys.objects & sys.identity_columns)
SELECT A.[name] AS [Table_Name], B.[name] AS [Column_Name], B.is_identity
FROM sys.objects A
     INNER JOIN sys.identity_columns B ON A.[object_id] = B.[object_id]
WHERE A.type = 'U' AND A.name = 'ApplicationMethod'

-------------------------------------------------------------------------------------------------------------------------------
--Method 5 : (sys.tables & sys.identity_columns)
SELECT A.[name] AS [Table_Name], B.[name] AS [Column_Name], B.is_identity
FROM sys.tables A
     INNER JOIN sys.identity_columns B ON A.[object_id] = B.[object_id]
WHERE A.type = 'U' AND is_identity = 1 AND A.name = 'ApplicationMethod'

-------------------------------------------------------------------------------------------------------------------------------
--Method 6 : (INFORMATION_SCHEMA.COLUMNS)
;With CTE AS (Select Table_Schema+'.'+Table_Name as [Table_Name],[Column_name] from
INFORMATION_SCHEMA.COLUMNS)
Select Table_Name,[Column_name],COLUMNPROPERTY(OBJECT_ID(Table_Name),[Column_name],'IsIdentity')AS 'IsIdentity'
from CTE Where COLUMNPROPERTY( OBJECT_ID(Table_Name),[Column_name],'IsIdentity')=1

-------------------------------------------------------------------------------------------------------------------------------

