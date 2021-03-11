/*
DATEADD and DATEDIFF are better than CONVERTing to varchar. 
Both queries have the same execution plan, but execution plans are primarly 
about data access strategies and do not always reveal implicit costs involved 
in the CPU time taken to perform all the pieces. If both queries are run against 
a table with millions of rows, the CPU time using DateDiff can be 
 to 1/3rd of the Convert CPU time!

To see execution plans for queries:
*/
set showplan_text ON

set showplan_text OFF

-- only SQL2008
select CONVERT(date, getdate()) 

/* What's the BEST way to remove the time portion of a datetime value (SQL Server)? */

SELECT CAST(FLOOR(CAST(getdate() as FLOAT)) as DATETIME) 
SELECT CAST(FLOOR(CAST(getdate()+7 as FLOAT)) as DATETIME) 

SELECT GETDATE()

SELECT CAST( GETDATE() AS FLOAT )

SELECT FLOOR( CAST( GETDATE() AS FLOAT ) )

SELECT CAST( FLOOR( CAST( GETDATE() AS FLOAT ) ) AS DATETIME )


SELECT DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE())) 

SELECT CAST(CONVERT(char(8), GETDATE(), 112) AS datetime) 
SELECT CONVERT(varchar(10), GETDATE(), 101)


SELECT DATEDIFF(day, 0, GETDATE())
SELECT DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0) 

SELECT CAST( GETDATE() AS FLOAT)
SELECT CAST( GETDATE() AS INT)
 
SELECT CAST(CAST(GETDATE() - 0.50000004 AS int) AS datetime) 


SELECT CAST(0 as datetime);
SELECT CAST(1 as datetime);

SELECT @@VERSION

SELECT DATEPART( wk, GETDATE() )
SELECT datepart( ISO_WEEK, GETDATE())

SELECT @@DATEFIRST	--7

-- Sunday
SELECT DATEPART( wk, '2012-05-27' ) -- 22
SELECT datepart( ISO_WEEK, '2012-05-27') -- 21

		
SELECT [dbo].[udfGetDateFromWeek]('22-2012')
SELECT [dbo].[udfGetWeekNumber](GETDATE())

SELECT dbo.udfGetDateOnly(GETDATE())




-- Date greater than or equal to Monday of last week
	MyDate >= dateadd(dd,((datediff(dd,'17530101',getdate())/7)*7)-7,'17530101')
	and
	-- Date before Saturday of last week
	Mydate < dateadd(dd,((datediff(dd,'17530101',getdate())/7)*7)-2,'17530101')


-- First Day of Month
select DATEADD(mm, DATEDIFF(mm,0,getdate()), 0)

		/* For the first example, let me show you how to get the first day of the month from the current date. Remember now, this example and all the other examples in this article will only be using the DATEADD and DATEDIFF functions to calculate our desired date. Each example will do this by calculating date intervals from the current date, and then adding or subtracting intervals to arrive at the desired calculated date. Here is the code to calculate the first day of the month: */
		/* Let me review how this works, by breaking this statement apart. The inner most function call "getdate()", as most of you probably already know, returns the current date and time. Now the next executed function call "DATEDIFF(mm,0,getdate())" calculates the number of months between the current date and the date "1900-01-01 00:00:00.000". Remember date and time variables are stored as the number of milliseconds since "1900-01-01 00:00:00.000"; this is why you can specify the first datetime expression of the DATEDIFF function as "0." Now the last function call, DATEADD, adds the number of months between the current date and '1900-01-01". By adding the number of months between our pre-determined date '1900-01-01' and the current date, I am able to arrive at the first day of the current month. In addition, the time portion of the calculated date will be "00:00:00.000."*/
		/* The technique shown here for calculating a date interval between the current date and the year "1900-01-01," and then adding the calculated number of interval to "1900-01-01," to calculate a specific date, can be used to calculate many different dates. The next four examples use this same technique to generate different dates based on the current date.*/

-- Monday of the Current Week
select DATEADD(wk, DATEDIFF(wk,0,getdate()), 0)

		/* Here I use the week interval (wk) to calculate what date is Monday of the current week. This example assumes Sunday is the first day of the week. */
		/* If you don't want Sunday to be the first day of the week, then you will need to use a different method. Here is a method that David O Malley showed me that uses the DATEFIRST setting to set the first day of the week. This example sets Monday as the first day of the week. */

set DATEFIRST 1
select DATEADD(dd, 1 - DATEPART(dw, getdate()), getdate())

/* But now if you want to change this example to calculate a different first day of the week like “First Tuesday of the Week” you can change the set command above to “set DATEFIRST 2”. */

-- First Day of the Year
select DATEADD(yy, DATEDIFF(yy,0,getdate()), 0)

		/* Now I use the year interval (yy) to display the first day of the year.*/

-- First Day of the Quarter
select DATEADD(qq, DATEDIFF(qq,0,getdate()), 0)

		/* If you need to calculate the first day of the current quarter then here is an example of how to do that. */

--Midnight for the Current Day
select DATEADD(dd, DATEDIFF(dd,0,getdate()), 0)

		/* Ever need to truncate the time portion for the datetime value returned from the getdate() function, so it reflects the current date at midnight? If so then here is an example that uses the DATEADD and DATEDIFF functions to get the midnight timestamp.*/

	/*
	Expanding on the DATEADD and DATEDIFF Calculation
	As you can see, by using this simple DATEADD and DATEDIFF calculation you can come up with many different dates that might be valuable. 
	All of the examples so far only calculated the current number of date intervals between the current date and "1900-01-01," and then added the number of intervals to "1900-01-01" to arrive at the calculated date. Say you modify the number of intervals to be added, or added additional DATEADD functions that used different time intervals, or subtracted intervals instead of adding intervals; by making these minor changes you can come up with many different dates. 
	Here are four examples that add an additional DATEADD function to calculate the last day dates for both the current and prior intervals. 
	*/

-- Last Day of Prior Month
select dateadd(ms,-3,DATEADD(mm, DATEDIFF(mm,0,getdate()  ), 0))

	/* Here is an example that calculates the last day of the prior month. It does this by subtracting 3 milliseconds from the first day of the month example. Now remember the time portion in SQL Server is only accurate to 3 milliseconds. This is why I needed to subtract 3 milliseconds to arrive at my desired date and time. */
	/* The time portion of the calculated date contains a time that reflects the last millisecond of the day ("23:59:59.997") that SQL Server can store. */

--Last Day of Prior Year
select dateadd(ms,-3,DATEADD(yy, DATEDIFF(yy,0,getdate()  ), 0))

	/* Like the prior example to get the last date of the prior year you need to subtract 3 milliseconds from the first day of year.*/

--Last Day of Current Month
select dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,getdate()  )+1, 0))

	/* Now to get the last day of the current month I need to modify slightly the query that returns the last day of the prior month. The modification needs to add one to the number of intervals return by DATEDIFF when comparing the current date with "1900-01-01." By adding 1 month, I am calculating the first day of next month and then subtraction 3 milliseconds, which allows me to arrive at the last day of the current month. Here is the TSQL to calculate the last day of the current month. */

--Last Day of Current Year
select dateadd(ms,-3,DATEADD(yy, DATEDIFF(yy,0,getdate()  )+1, 0))

	/*You should be getting the hang of this by now. Here is the code to calculate the last day of the current year.*/

-- First Monday of the Month
select DATEADD(wk, DATEDIFF(wk,0,
            dateadd(dd,6-datepart(day,getdate()),getdate())
                               ), 0)

	/*Ok, I am down to my last example. Here I am going to calculate the first Monday of the current month. Here is the code for that calculation.*/
	/*In this example, I took the code for "Monday of the Current Week," and modified it slightly. The modification was to change the "getdate()" portion of the code to calculate the 6th day of the current month. Using the 6th day of the month instead of the current date in the formula allows this calculation to return the first Monday of the current month.*/
	/* Conclusion 
		I hope that these examples have given you some ideas on how to use the DATEADD and DATEDIFF functions to calculate dates. When using this date interval math method of calculating dates I have found it valuable to have a calendar available to visualize the intervals between two different dates. Remember this is only one way to accomplish these date calculations. Keep in mind there are most likely a number of other methods to perform the same calculations. If you know of another way, great, although if you do not, I hope these examples have given you some ideas of how to use DATEADD and DATEDIFF to calculate dates your applications might need. */


/*
For MS SQL, the function use in this article is DATEPART, 
which uses Sunday to Saturday as a week. 
I believe this is not the ISO-8601 standard. 
Any idea how to get the ISO-8601 standard Week Number in MS SQL (SQL Server)
*/

SELECT DATEDIFF(year, '1976-06-22', GETDATE())
SELECT DATEDIFF(month, '1976-06-22', GETDATE())
SELECT DATEDIFF(day, '1976-06-22', GETDATE())
SELECT DATEDIFF(hour, '1976-06-22', GETDATE())

SELECT DATEPART(DAY, GETDATE())
SELECT DATEPART(month, GETDATE())
SELECT DATEPART(Year, GETDATE())


SELECT DATENAME(month,'2007-10-30 12:15:32.1234567 +05:10') 

SELECT DATENAME(month,'2007-10-30') 

/*
datepart 	 Return value	 
year, yyyy, yy 	 2007
quarter, qq, q 	 4
month, mm, m 	 October
dayofyear, dy, y 	 303
day, dd, d 	 30
week, wk, ww 	 44
weekday, dw 	 Tuesday
hour, hh 	 12
minute, n 	 15
second, ss, s 	 32
millisecond, ms 	 123
microsecond, mcs 	 123456
nanosecond, ns 	 123456700
TZoffset, tz 	 310	 
*/





declare @d datetime; 
set @d = '2010-09-12 00:00:00.003'; 
select Convert(datetime, Convert(float, @d));
 -- result: 2010-09-12 00:00:00.000 -- oops 

select Convert(datetime, DateDiff(dd, 0, Tm)) 
from (select '2010-09-12 00:00:00.003') X (Tm) 
group by DateDiff(dd, 0, Tm) 





-- Enclose in transaction so we can roll back changes for the next test
BEGIN TRANSACTION;
go
 
-- Keep track of execution time
DECLARE @start datetime;
SET @start = CURRENT_TIMESTAMP;
 
-- Do what has to be done...
DECLARE @date DATETIME
DECLARE @cnt INT
SET @cnt = 0

WHILE @cnt < 100000
BEGIN
	-- float
	--SELECT @date = CAST(FLOOR(CAST(getdate() as FLOAT)) as DATETIME) 
	-- char
	SELECT @date = CAST(CONVERT(char(8), GETDATE(), 112) AS datetime) 
	SELECT @cnt = @cnt + 1 
END
 
-- Display duration
SELECT DATEDIFF(ms, @start, CURRENT_TIMESTAMP);
go
 
-- Rollback changes for the next test
ROLLBACK TRANSACTION;
GO




-- dbo.udfGetDateFromWeek(@WeekNum)

SELECT dbo.udfGetDateFromWeek('22-2012')
SELECT dbo.udfGetDateFromWeek('21-2012')

SELECT MONTH(dbo.udfGetDateFromWeek('21-2012')) , 
	DAY(dbo.udfGetDateFromWeek('21-2012')),
	YEAR(dbo.udfGetDateFromWeek('21-2012'))
	


/*******************************************************/
CREATE FUNCTION [dbo].[udfGetDateOnly]
(
	@inDate DATETIME
)
RETURNS DATETIME
AS
BEGIN
	/* Return only DATE - without time (00:00:00) */
	DECLARE @outDate DATETIME
	
	SELECT @outDate = CAST(FLOOR(CAST(@inDate as FLOAT)) as DATETIME) 
	
	RETURN @outDate
END