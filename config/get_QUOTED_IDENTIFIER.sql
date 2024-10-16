/*
https://www.mssqltips.com/sqlservertip/6314/sql-server-set-quotedidentifier-and-set-ansipadding-proper-usage-examples/

https://www.sqlserver-dba.com/2017/02/how-to-find-of-the-quoted_identifier-used-for-stored-procedure.html


Msg 1934, Level 16, State 1, Procedure CollegeApplicationDeleteByPortfolioId, Line 17

DELETE failed because the following SET options have incorrect settings: 'QUOTED_IDENTIFIER'. 
Verify that SET options are correct for use 
	with indexed views 
	and/or indexes on computed columns 
	and/or filtered indexes 
	and/or query notifications 
	and/or XML data type methods 
	and/or spatial index operations.

Executing through the SSMS will pick up the value set at the SSMS level. Unless you override the setting by using SET QUOTED_IDENTIFIER OFF | ON at the top of your sql batch statement

These settings won’t apply if you are executing a stored procedure , for example : exec mySP1 . 
It uses the QUOTED_IDENTIFIER setting used when the stored procedure was created . 
How can you find out the QUOTED_IDENTIFIER value used when the stored procedure was created. ?

Query to find objects using QUOTED_IDENTIFIER ON
	
SELECT OBJECT_NAME(object_id) 
    FROM sys.sql_modules 
    WHERE uses_quoted_identifier = 1

Query to find objects using QUOTED_IDENTIFIER OFF
	
SELECT OBJECT_NAME(object_id) 
    FROM sys.sql_modules 
    WHERE uses_quoted_identifier = 0
*/
ALTER DATABASE [$(databasename)] 

SET ANSI_NULL_DEFAULT OFF;
GO
SET ANSI_NULLS OFF;
GO
SET QUOTED_IDENTIFIER ON;
GO


-- EXEC sp_MSForEachTable 'SET QUOTED_IDENTIFIER ON; SELECT TOP 1 FROM ?'
-- EXEC sp_MSForEachTable 'SET QUOTED_IDENTIFIER ON;'

-- drop procedure [qa].[CollegeApplicationDeleteByPortfolioId1]
-- exec [qa].[CollegeApplicationDeleteByPortfolioId1] 123

-- was 0
SET QUOTED_IDENTIFIER OFF;

exec [qa].[CollegeApplicationDeleteByPortfolioId] 123

SET QUOTED_IDENTIFIER ON;

SELECT sessionproperty('QUOTED_IDENTIFIER')


select top 10 OBJECT_NAME([object_id]), * from sys.sql_modules
where OBJECT_NAME([object_id]) IN ('CollegeApplicationDeleteByPortfolioId', 'CollegeApplicationDeleteByPortfolioId1');

select top 10 * from sys.sql_modules
where OBJECT_NAME([object_id]) IN ('CollegeApplicationDeleteByPortfolioId1');


select top 10 OBJECT_NAME([object_id]), * from sys.sql_modules where uses_quoted_identifier = 1
select top 10 OBJECT_NAME([object_id]), * from sys.sql_modules where uses_quoted_identifier = 0

-- databases
    select * From sys.databases where is_quoted_identifier_on = 1

    select is_quoted_identifier_on, * From sys.databases where is_quoted_identifier_on = 1
    select is_quoted_identifier_on, * From sys.databases where is_quoted_identifier_on = 0

select top 10 * From sys.procedures 
select top 10 * From sys.tables




select
    'Object created with dangerous SET Option' [Finding]
    ,o.[type_desc] [Type]
    ,QUOTENAME( SCHEMA_NAME( o.[schema_id] ) ) [Schema]
    ,QUOTENAME( OBJECT_NAME( sm.[object_id] ) ) [Name]
    ,sm.[uses_ansi_nulls] [ANSI NULL]
    ,sm.[uses_quoted_identifier] [QUOTED]
    ,sm.[definition]
from [sys].[sql_modules] sm
join [sys].[objects] o on o.[object_id] = sm.[object_id]
    and (
        sm.[uses_ansi_nulls] != 1
        or sm.[uses_quoted_identifier] != 1
        )
    and o.[is_ms_shipped] = 0;



SELECT @@OPTIONS

go
DECLARE @options INT SELECT @options = @@OPTIONS 
PRINT @options
IF ( (1 & @options) = 1 ) PRINT 'DISABLE_DEF_CNST_CHK' 
IF ( (2 & @options) = 2 ) PRINT 'IMPLICIT_TRANSACTIONS' 
IF ( (4 & @options) = 4 ) PRINT 'CURSOR_CLOSE_ON_COMMIT' 
IF ( (8 & @options) = 8 ) PRINT 'ANSI_WARNINGS' 
IF ( (16 & @options) = 16 ) PRINT 'ANSI_PADDING' 
IF ( (32 & @options) = 32 ) PRINT 'ANSI_NULLS' 
IF ( (64 & @options) = 64 ) PRINT 'ARITHABORT' 
IF ( (128 & @options) = 128 ) PRINT 'ARITHIGNORE'
IF ( (256 & @options) = 256 ) PRINT 'QUOTED_IDENTIFIER' 
IF ( (512 & @options) = 512 ) PRINT 'NOCOUNT' 
IF ( (1024 & @options) = 1024 ) PRINT 'ANSI_NULL_DFLT_ON' 
IF ( (2048 & @options) = 2048 ) PRINT 'ANSI_NULL_DFLT_OFF' 
IF ( (4096 & @options) = 4096 ) PRINT 'CONCAT_NULL_YIELDS_NULL' 
IF ( (8192 & @options) = 8192 ) PRINT 'NUMERIC_ROUNDABORT' 
IF ( (16384 & @options) = 16384 ) PRINT 'XACT_ABORT' 
GO



with OPTION_VALUES as (
    select
    optionValues.id,
    optionValues.name,
    optionValues.description,
    row_number() over (partition by 1 order by id) as bitNum
    from (values
    (1, 'DISABLE_DEF_CNST_CHK', 'Controls interim or deferred constraint checking.'),
    (2, 'IMPLICIT_TRANSACTIONS', 'For dblib network library connections, controls whether a transaction is started implicitly when a statement is executed. The IMPLICIT_TRANSACTIONS setting has no effect on ODBC or OLEDB connections.'),
    (4, 'CURSOR_CLOSE_ON_COMMIT', 'Controls behavior of cursors after a commit operation has been performed.'),
    (8, 'ANSI_WARNINGS', 'Controls truncation and NULL in aggregate warnings.'),
    (16, 'ANSI_PADDING', 'Controls padding of fixed-length variables.'),
    (32, 'ANSI_NULLS', 'Controls NULL handling when using equality operators.'),
    (64, 'ARITHABORT', 'Terminates a query when an overflow or divide-by-zero error occurs during query execution.'),
    (128, 'ARITHIGNORE', 'Returns NULL when an overflow or divide-by-zero error occurs during a query.'),
    (256, 'QUOTED_IDENTIFIER', 'Differentiates between single and double quotation marks when evaluating an expression.'),
    (512, 'NOCOUNT', 'Turns off the message returned at the end of each statement that states how many rows were affected.'),
    (1024, 'ANSI_NULL_DFLT_ON', 'Alters the session'+char(39)+'s behavior to use ANSI compatibility for nullability. New columns defined without explicit nullability are defined to allow nulls.'),
    (2048, 'ANSI_NULL_DFLT_OFF', 'Alters the session'+char(39)+'s behavior not to use ANSI compatibility for nullability. New columns defined without explicit nullability do not allow nulls.'),
    (4096, 'CONCAT_NULL_YIELDS_NULL', 'Returns NULL when concatenating a NULL value with a string.'),
    (8192, 'NUMERIC_ROUNDABORT', 'Generates an error when a loss of precision occurs in an expression.'),
    (16384, 'XACT_ABORT', 'Rolls back a transaction if a Transact-SQL statement raises a run-time error.')
    ) as optionValues(id, name, description)
)
select *, case when (@@options & id) = id then 1 else 0 end as setting
from OPTION_VALUES;



SELECT name = OBJECT_NAME([object_id]), uses_quoted_identifier, uses_ansi_nulls
FROM sys.sql_modules
    --where uses_quoted_identifier =0
    where OBJECT_NAME([object_id]) IN ('CollegeApplicationDeleteByPortfolioId');

    --or OBJECT_NAME([object_id]) IN (N',mysp1', N'mysp2');

SELECT QUOTED_IDENTIFIER, ANSI_PADDING FROM sys.dm_exec_sessions



SELECT QUOTED_IDENTIFIER, ANSI_PADDING FROM sys.dm_exec_sessions where session_id = @@SPID 


DECLARE @QUOTED_IDENTIFIER VARCHAR (3) = 'OFF'; 
IF ( (256 & @@OPTIONS) = 256 ) SET @QUOTED_IDENTIFIER = 'ON'; 
SELECT @QUOTED_IDENTIFIER AS QUOTED_IDENTIFIER; 
  
DECLARE @ANSI_PADDING VARCHAR (3) = 'OFF';  
IF ((16 & @@OPTIONS) = 16) SET @ANSI_PADDING = 'ON';  
SELECT @ANSI_PADDING AS ANSI_PADDING; 

SELECT name = OBJECT_NAME([object_id]), ,uses_quoted_identifier
FROM sys.sql_modules
WHERE OBJECT_NAME([object_id]) IN (N',mysp1', N'mysp2');

