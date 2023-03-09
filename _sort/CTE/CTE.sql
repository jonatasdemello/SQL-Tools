--Common Table Expression – CTE

--Split words in a string to column values in a table
 

DECLARE @message VARCHAR(200) = 'Welcome to 15 to 20 minutes dot com '; --Input string;
WITH myCTE([start], [end]) AS
(
	SELECT 1 AS [start], CHARINDEX(' ', @message, 1) AS [end]
	 UNION all
	SELECT [end] + 1 as [start], CHARINDEX(' ', @message, [end] + 1) AS [end] FROM myCTE WHERE [end] < LEN(@message)
)
SELECT SUBSTRING(@message, [start], [end] - [start]) AS [Values] FROM myCTE;


--Calculate Factorial
DECLARE @number INT = 5;
;WITH myCTE (fact, num)
AS
(
	SELECT @number * (@number -1) AS fact, @number -1 AS num
	UNION ALL
	SELECT fact * (num -1), num -1 FROM myCTE WHERE num > 1
) 
SELECT TOP 1 fact FROM myCTE ORDER BY fact DESC;

--Write Fibonacci Numbers

DECLARE @limit INT = 20;
;WITH myCTE(a, b, cnt)
AS
(
	SELECT 0 AS a, 1 AS b, 1
	UNION ALL
	SELECT b, a + b, cnt + 1 FROM myCTE WHERE cnt < @limit
) 
SELECT a FROM myCTE

