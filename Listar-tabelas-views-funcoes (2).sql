-----------------------------------------
-- List only the tables in this database
-----------------------------------------
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
