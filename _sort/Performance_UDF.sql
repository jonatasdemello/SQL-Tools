


CREATE TABLE States(Code CHAR(2), [Name] VARCHAR(40), CONSTRAINT PK_States PRIMARY KEY(Code))
GO
INSERT States(Code, [Name]) VALUES('IL', 'Illinois')
INSERT States(Code, [Name]) VALUES('WI', 'Wisconsin')
INSERT States(Code, [Name]) VALUES('IA', 'Iowa')
INSERT States(Code, [Name]) VALUES('IN', 'Indiana')
INSERT States(Code, [Name]) VALUES('MI', 'Michigan')
GO
CREATE TABLE Observations(ID INT NOT NULL, StateCode CHAR(2), CONSTRAINT PK_Observations PRIMARY KEY(ID))
GO
SET NOCOUNT ON
DECLARE @i INT
SET @i=0
WHILE @i<100000 BEGIN
  SET @i = @i + 1
  INSERT Observations(ID, StateCode)
  SELECT @i, CASE WHEN @i % 5 = 0 THEN 'IL'
    WHEN @i % 5 = 1 THEN 'IA'
    WHEN @i % 5 = 2 THEN 'WI'
    WHEN @i % 5 = 3 THEN 'IA'
    WHEN @i % 5 = 4 THEN 'MI'
    END
END
GO

SELECT * FROM STATES
SELECT * FROM Observations

--When a query involving a UDF is rewritten as an outer join.
--Consider the following query:

SELECT o.ID, s.[name] AS StateName
  INTO dbo.ObservationsWithStateNames_Join
  FROM dbo.Observations o LEFT OUTER JOIN dbo.States s ON o.StateCode = s.Code
/*
SQL Server parse and compile time:
   CPU time = 0 ms, elapsed time = 1 ms.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Observations'. Scan count 1, logical reads 188, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'States'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
 
SQL Server Execution Times:
   CPU time = 187 ms,  elapsed time = 188 ms.
*/

--And compare it to a query involving an inline table valued UDF:

GO 

CREATE FUNCTION dbo.GetStateName_Inline(@StateCode CHAR(2))
RETURNS TABLE
AS
RETURN(SELECT [Name] FROM dbo.States WHERE Code = @StateCode);
GO
SELECT ID, (SELECT [name] FROM dbo.GetStateName_Inline(StateCode)) AS StateName
  INTO dbo.ObservationsWithStateNames_Inline
  FROM dbo.Observations
GO

--Both its execution plan and its execution costs are the same 
-- the optimizer has rewritten it as an outer join. Don’t underestimate the power of the optimizer!
 
--A query involving a scalar UDF is much slower.
 
--Here is a scalar UDF:

CREATE FUNCTION dbo.GetStateName(@StateCode CHAR(2))
RETURNS VARCHAR(40)
AS
BEGIN
  DECLARE @ret VARCHAR(40)
  SET @ret = (SELECT [Name] FROM dbo.States WHERE Code = @StateCode)
  RETURN @ret
END
GO

-- Clearly the query using this UDF provides the same results but it has a different 
-- execution plan and it is dramatically slower:
/*
SQL Server parse and compile time:
   CPU time = 0 ms, elapsed time = 3 ms.
Table 'Worktable'. Scan count 1, logical reads 202930, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Observations'. Scan count 1, logical reads 188, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
 
SQL Server Execution Times:
   CPU time = 11890 ms,  elapsed time = 38585 ms.
*/
/*
As you have seen, the optimizer can rewrite and optimize queries involving inline table valued UDFs. 
On the other hand, queries involving scalar UDFs are not rewritten by the optimizer 
– the execution of the last query includes one function call per row, which is very slow.
Also thank you Peter and Adam for setting me up as a blogger on this wonderful site!
*/

DROP TABLE States
DROP TABLE Observations
DROP TABLE ObservationsWithStateNames_Join

DROP FUNCTION dbo.GetStateName_Inline
DROP FUNCTION dbo.GetStateName


