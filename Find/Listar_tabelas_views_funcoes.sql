-----------------------------------------
-- List only the tables in this database
-----------------------------------------
SELECT [NAME], [type_desc], [object_id]  FROM sys.Tables

-- all tables
SELECT 
 o.name AS [Table Name], 
 o.type, 
 c.name AS [Col Name], 
 s.name AS [Col Type], 
 c.prec, 
 c.scale, 
 c.isnullable
FROM dbo.sysobjects AS o 
INNER JOIN dbo.syscolumns AS c ON c.id = o.id 
INNER JOIN dbo.systypes AS s ON c.xtype = s.xtype
WHERE ( o.type = 'U' )


SELECT DISTINCT	o.name AS [Table Name], o.type
FROM dbo.sysobjects AS o 
INNER JOIN dbo.syscolumns AS c ON c.id = o.id 
INNER JOIN dbo.systypes AS s ON c.xtype = s.xtype
WHERE ( o.type = 'U' )

-----------------------------------------
-- List only the views in this database
-----------------------------------------
SELECT 
 o.name AS [View Name], 
 o.type, 
 c.name AS [Col Name], 
 s.name AS [Col Type], 
 c.prec, 
 c.scale, 
 c.isnullable
FROM dbo.sysobjects AS o 
INNER JOIN dbo.syscolumns AS c ON c.id = o.id 
INNER JOIN dbo.systypes AS s ON c.xtype = s.xtype
WHERE ( o.type = 'V' )


SELECT DISTINCT	o.name AS [View Name], o.type
FROM dbo.sysobjects AS o 
INNER JOIN dbo.syscolumns AS c ON c.id = o.id 
INNER JOIN dbo.systypes AS s ON c.xtype = s.xtype
WHERE ( o.type = 'V' )

-----------------------------------------
-- List only the functions in this database
-----------------------------------------
SELECT 
 o.name AS [Funtion Name], 
 o.type, 
 c.name AS [Col Name], 
 s.name AS [Col Type], 
 c.prec, 
 c.scale, 
 c.isnullable
FROM dbo.sysobjects AS o 
INNER JOIN dbo.syscolumns AS c ON c.id = o.id 
INNER JOIN dbo.systypes AS s ON c.xtype = s.xtype
WHERE ( o.type = 'TF' )


SELECT DISTINCT	o.name AS [Function Name], o.type
FROM dbo.sysobjects AS o 
INNER JOIN dbo.syscolumns AS c ON c.id = o.id 
INNER JOIN dbo.systypes AS s ON c.xtype = s.xtype
WHERE ( o.type = 'TF' )

-----------------------------------------
-- List only the stored procedures in this database
-----------------------------------------
SELECT 
 o.name AS [Funtion Name], 
 o.type, 
 c.name AS [Col Name], 
 s.name AS [Col Type], 
 c.prec, 
 c.scale, 
 c.isnullable
FROM dbo.sysobjects AS o 
INNER JOIN dbo.syscolumns AS c ON c.id = o.id 
INNER JOIN dbo.systypes AS s ON c.xtype = s.xtype
WHERE ( o.type = 'P' )


SELECT DISTINCT	o.name AS [Procedure Name], o.type
FROM dbo.sysobjects AS o 
INNER JOIN dbo.syscolumns AS c ON c.id = o.id 
INNER JOIN dbo.systypes AS s ON c.xtype = s.xtype
WHERE ( o.type = 'P' )


/*-----------------------------------------
xtype:
	AF = Aggregate function (CLR)
	C = CHECK constraint 
	D = Default or DEFAULT constraint 
	F = FOREIGN KEY constraint 
	L = Log 
	FN = Scalar function
	FS = Assembly (CLR) scalar-function
	FT = Assembly (CLR) table-valued function
	IF = In-lined table-function 
	IT = Internal table
	P = Stored procedure 
	PC = Assembly (CLR) stored-procedure
	PK = PRIMARY KEY constraint (type is K) 
	RF = Replication filter stored procedure
	S = System table 
	SN = Synonym
	SQ = Service queue
	TA = Assembly (CLR) DML trigger
	TF = Table function 
	TR = SQL DML Trigger 
	TT = Table type
	U = User table 
	UQ = UNIQUE constraint (type is K) 
	V = View 
	X = Extended stored procedure
-----------------------------------------*/

-- All tables and columns

Using OBJECT CATALOG VIEWS

SELECT  T.NAME AS [TABLE NAME], C.NAME AS [COLUMN NAME], P.NAME AS [DATA TYPE], P.MAX_LENGTH AS[SIZE],   
CAST(P.PRECISION AS VARCHAR) +'/'+ CAST(P.SCALE AS VARCHAR) AS [PRECISION/SCALE]
FROM ADVENTUREWORKS.SYS.OBJECTS AS T
JOIN ADVENTUREWORKS.SYS.COLUMNS AS C
ON T.OBJECT_ID=C.OBJECT_ID
JOIN ADVENTUREWORKS.SYS.TYPES AS P
ON C.SYSTEM_TYPE_ID=P.SYSTEM_TYPE_ID
WHERE T.TYPE_DESC='USER_TABLE';
Using INFORMATION SCHEMA VIEWS

-- All tables and columns
SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, ORDINAL_POSITION, /*COLUMN_DEFAULT,*/ DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
       /* , NUMERIC_PRECISION, NUMERIC_PRECISION_RADIX, NUMERIC_SCALE,  DATETIME_PRECISION */
      FROM Pbp_Educ.INFORMATION_SCHEMA.COLUMNS


SELECT t.name AS [TABLE Name],
c.name AS [COLUMN Name],
p.name AS [DATA Type],
p.max_length AS[SIZE],
CAST(p.PRECISION AS VARCHAR)+'/' + CAST(p.scale AS VARCHAR) AS [PRECISION/Scale]
FROM sys.objects AS t
	JOIN sys.columns AS c ON t.OBJECT_ID=c.OBJECT_ID
	JOIN sys.types AS p ON c.system_type_id=p.system_type_id
WHERE t.type_desc='USER_TABLE'
ORDER BY T.NAME;