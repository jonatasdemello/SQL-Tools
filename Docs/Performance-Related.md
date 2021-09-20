
# Performance Related

## General Performance Guidelines
<br/>

Here are some performance related suggestions / best practices:

Never create a CLUSTERED key on a UNIQUEIDENTIFIER as the random nature of UNIQUEIDENTIFIERs will result in a lot of disk fragmentation.

**Never use triggers**.

Triggers hurt performance, cause deadlocks, and worst of all, cause unintended side-effects on DML operations. Triggers are often used as hacks where the code would be better suited to be within a stored procedure or in calling code directly.

Every table **must have a primary key and a clustered index** (they can be the one and the same).

Avoid dynamic SQL and cursors whenever possible.

Never use the Data Tuning Advisor. It has no context about database workload outside of what you provide it and most of the time makes poor index suggestions. Indexes should be carefully considered by a human based on the understanding of the entire database workload.

If a table has more than 5 indexes or has a number of wide indexes, the code should probably be refactored such that extraneous indexes can be dropped. **Too many indexes hurt DML performance**.

Avoid excessive use of temp tables. They make for difficult to read code and they generally perform worse than CTE's.

Place `SET NOCOUNT ON` at the top of every stored procedure.

Fully qualify calls to stored procedures with their schema name. This saves SQL Server from having to perform a look-up on the schema when it's generating an execution plan.

`exec dbo.UserAccountGetByUserAccountId`

Avoid `ORDER BY` operations in stored procedures where possible. ORDER BY is a heavy operation and better suited for the application or report to handle.


## Avoid Function Operations on Columns in the WHERE clause

One very common performance related issue is when functions wrap columns in the WHERE clause. As soon as a column is wrapped by a function, any index on that column cannot be used.

**Example #1**

```sql
-- Courses selected in July 2014
SELECT PortfolioID, CourseCode, CourseSelectionTime
FROM dbo.CourseSelections
WHERE YEAR(CourseSelectionTime) = 2014 AND MONTH(CourseSelectionTime) = 7
```

Assuming there's an index on `CourseSelectionTime` column, the query could be improved by re-writing it as follows:

```sql
-- Courses selected in July 2014
SELECT PortfolioId, CourseCode, CourseSelectionTime
FROM dbo.CourseSelections
WHERE CourseSelectionTime >= '20140701' AND CourseSelectdionTime < '20140801'
```

**Example #2**

```sql
-- Filter students by status (which is an INT)
DECLARE @Status TINYINT = 1
SELECT PortfolioId, FirstName, LastName
FROM dbo.Portfolio
WHERE CONVERT(TINYINT, Status) = @Status
```

Assuming there's an index on `Status` column, the query could be improved by re-writing it as follows:

```sql
-- Filter students by status (which is an INT)
DECLARE @Status TINYINT = 1
SELECT PortfolioId, FirstName, LastName
FROM dbo.Portfolio
WHERE Status = CONVERT(INTEGER, @Status)
```

## Avoid udf Calls that Perform a Query

It's often tempting to encapsulate logic within a UDF and use that UDF in a SELECT statement to perform a calculation for each row.

While this creates clean code, it also performs horribly because it's effectively doing a subquery for every row returned by the SELECT statement.

For instance:

```sql
-- Calculate revenue in USD for customer ID 1234 in 2014
SELECT ProductId, SUM(Amount * dbo.udf_ExchangeRate(OrderDate, Currency, 'USD')) AS AmountUSD
FROM dbo.Orders o
WHERE o.CustomerId = 1234 AND o.OrderDate >= '20140101' AND o.OrderDate < '20150101'
GROUP BY ProductId
```

This query makes sense, however, it's going to be very inefficient because of the subqueries.
In this case, the function will be applied to every row in the result set.

This can be even worse if we use a function in a `WHERE` clause. In this case, the function has to be applied to all rows in order to decide if it must be included in the result.

```sql
-- Calculate revenue in USD for customer ID 1234 in 2014
SELECT ProductId, SUM(Amount * dbo.udf_ExchangeRate(OrderDate, Currency, 'USD')) AS AmountUSD
FROM dbo.Orders o
WHERE dbo.udf_ExchangeRate(OrderDate, Currency, 'USD') > 100
GROUP BY ProductId
```

This can be significantly improved by doing a JOIN instead. Here we are using a view instead:

```sql
-- Calculate revenue in USD for customer ID 1234 in 2014
SELECT ProductId, SUM(Amount * r.ExchangeRate) AS AmountUSD
FROM dbo.Orders o
INNER JOIN dbo.vw_ExchangeRates r ON (r.ExchangeDate = o.OrderDate AND r.FromCurrency = o.Currency AND r.ToCurrency = 'USD')
WHERE o.CustomerId = 1234 AND o.OrderDate >= '20140101' AND o.OrderDate < '20150101'
GROUP BY ProductId
```

Note that udf's do perform well in the SELECT clause if they do a calculation but **DO NOT** access any tables.


## Use Temp Tables to Pass Arrays to SQL

Many times a program needs to perform an operation on a number of records;
for instance, saving all 40 matchmaker answers.

Typical ways to handle this include:

1.  Looping in C# and calling the stored procedure 40 times.
2.  Passing through a comma delimited string of values and splitting those values in the stored procedure.

Option #1 is very poor performing because it requires 40 round-trips to the SQL Server.

Option #2 can sometimes work well, but when there are multiple values per row (for instance AnswerId and AnswerTime) the comma delimited string becomes much harder to parse in the stored procedure.

The best performing and cleanest method is to pass a table-valued parameter to the stored procedure.

This is supported by Dapper: [https://gist.github.com/taylorkj/9012616](https://gist.github.com/taylorkj/9012616)

The stored procedure might look like this:

```sql
-- First create the type
CREATE TYPE MatchmakerAnswer AS TABLE
(
   AnswerId INTEGER NOT NULL,
   AnswerTime DATETIME2 NOT NULL
)
-- Create the stored procedure
CREATE PROCEDURE dbo.MatchmakerSave
(
   @PortfolioId INTEGER,
   @Answers MatchmakerAnswer READONLY
)
AS
INSERT INTO dbo.MatchmakerAnswers(PortfolioId, AnswerId, AnswerTime)
SELECT @PortfolioId, AnswerId, AnswerTime
FROM @Answers
GO
```

For more information about Dapper ORM:

https://dapper-tutorial.net/

