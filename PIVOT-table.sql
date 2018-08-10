-- https://en.wikipedia.org/wiki/Pivot_table
-- https://docs.microsoft.com/en-us/sql/t-sql/queries/from-using-pivot-and-unpivot?view=sql-server-2017


SELECT * FROM (SELECT year(invoiceDate) as [year], left(datename(month,invoicedate),3)as [month], _
InvoiceAmount as Amount FROM Invoice) as InvoiceResult 



SELECT *
FROM (
    SELECT 
        year(invoiceDate) as [year],left(datename(month,invoicedate),3)as [month], 
        InvoiceAmount as Amount 
    FROM Invoice
) as s
PIVOT
(
    SUM(Amount)
    FOR [month] IN (jan, feb, mar, apr, 
    may, jun, jul, aug, sep, oct, nov, dec)
)AS pvt




USE AdventureWorks2014 ;  
GO  
SELECT DaysToManufacture, AVG(StandardCost) AS AverageCost   
FROM Production.Product  
GROUP BY DaysToManufacture;  
Here is the result set.


Copy
DaysToManufacture AverageCost
----------------- -----------
0                 5.0885
1                 223.88
2                 359.1082
4                 949.4105
No products are defined with three DaysToManufacture.

The following code displays the same result, pivoted so that the DaysToManufacture values become the column headings. A column is provided for three [3] days, even though the results are NULL.


Copy
-- Pivot table with one row and five columns  
SELECT 'AverageCost' AS Cost_Sorted_By_Production_Days,   
[0], [1], [2], [3], [4]  
FROM  
(SELECT DaysToManufacture, StandardCost   
    FROM Production.Product) AS SourceTable  
PIVOT  
(  
AVG(StandardCost)  
FOR DaysToManufacture IN ([0], [1], [2], [3], [4])  
) AS PivotTable;  
Here is the result set.


Copy
Cost_Sorted_By_Production_Days 0           1           2           3           4         
------------------------------ ----------- ----------- ----------- ----------- -----------
AverageCost                    5.0885      223.88      359.1082    NULL        949.4105


create table DailyIncome(VendorId nvarchar(10), IncomeDay nvarchar(10), IncomeAmount int)
--drop table DailyIncome
 
Nothing odd here, just the Vendor id, the day of the week they are referring to and what the income on that day was.
So let’s fill it with some data.
 
insert into DailyIncome values ('SPIKE', 'FRI', 100)
insert into DailyIncome values ('SPIKE', 'MON', 300)
insert into DailyIncome values ('FREDS', 'SUN', 400)
insert into DailyIncome values ('SPIKE', 'WED', 500)
insert into DailyIncome values ('SPIKE', 'TUE', 200)
insert into DailyIncome values ('JOHNS', 'WED', 900)
insert into DailyIncome values ('SPIKE', 'FRI', 100)
insert into DailyIncome values ('JOHNS', 'MON', 300)
insert into DailyIncome values ('SPIKE', 'SUN', 400)
insert into DailyIncome values ('JOHNS', 'FRI', 300)
insert into DailyIncome values ('FREDS', 'TUE', 500)
insert into DailyIncome values ('FREDS', 'TUE', 200)
insert into DailyIncome values ('SPIKE', 'MON', 900)
insert into DailyIncome values ('FREDS', 'FRI', 900)
insert into DailyIncome values ('FREDS', 'MON', 500)
insert into DailyIncome values ('JOHNS', 'SUN', 600)
insert into DailyIncome values ('SPIKE', 'FRI', 300)
insert into DailyIncome values ('SPIKE', 'WED', 500)
insert into DailyIncome values ('SPIKE', 'FRI', 300)
insert into DailyIncome values ('JOHNS', 'THU', 800)
insert into DailyIncome values ('JOHNS', 'SAT', 800)
insert into DailyIncome values ('SPIKE', 'TUE', 100)
insert into DailyIncome values ('SPIKE', 'THU', 300)
insert into DailyIncome values ('FREDS', 'WED', 500)
insert into DailyIncome values ('SPIKE', 'SAT', 100)
insert into DailyIncome values ('FREDS', 'SAT', 500)
insert into DailyIncome values ('FREDS', 'THU', 800)
insert into DailyIncome values ('JOHNS', 'TUE', 600)
 
Now, if we select out the flat data that we have, we will get the following:
 
VendorId   IncomeDay  IncomeAmount
---------- ---------- ------------
SPIKE      FRI        100
SPIKE      MON        300
FREDS      SUN        400
SPIKE      WED        500
SPIKE      TUE        200
JOHNS      WED        900
SPIKE      FRI        100
JOHNS      MON        300
SPIKE      SUN        400
...
SPIKE      WED        500
FREDS      THU        800
JOHNS      TUE        600
 
A lot of data that it is hard to make something useful of, for example, say that we would like to know what the average income is for each vendor id?
Or what the maximum income is for each day for a particular vendor? Enter the pivot table.
 
To find the average for each vendor, run this query:
 
select * from DailyIncome
pivot (avg (IncomeAmount) for IncomeDay in ([MON],[TUE],[WED],[THU],[FRI],[SAT],[SUN])) as AvgIncomePerDay
 
Outcome:
 
VendorId   MON         TUE         WED         THU         FRI         SAT         SUN
---------- ----------- ----------- ----------- ----------- ----------- ----------- -----------
FREDS      500         350         500         800         900         500         400
JOHNS      300         600         900         800         300         800         600
SPIKE      600         150         500         300         200         100         400
 
The find the max income for each day for vendor SPIKE, run this query:
 
select * from DailyIncome
pivot (max (IncomeAmount) for IncomeDay in ([MON],[TUE],[WED],[THU],[FRI],[SAT],[SUN])) as MaxIncomePerDay
where VendorId in ('SPIKE')
 
Outcome:
 
VendorId   MON         TUE         WED         THU         FRI         SAT         SUN
---------- ----------- ----------- ----------- ----------- ----------- ----------- -----------
SPIKE      900         200         500         300         300         100         400
 
The short story on how it works using the last query.
 
select * from DailyIncome                                 -- Colums to pivot
pivot (
   max (IncomeAmount)                                                    -- Pivot on this column
   for IncomeDay in ([MON],[TUE],[WED],[THU],[FRI],[SAT],[SUN]))         -- Make colum where IncomeDay is in one of these.
   as MaxIncomePerDay                                                     -- Pivot table alias
where VendorId in ('SPIKE')                               -- Select only for this vendor
 
 