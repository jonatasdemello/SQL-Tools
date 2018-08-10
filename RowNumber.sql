
-- The following query returns the four system tables in alphabetic order.
SELECT  
	name, recovery_model_desc
FROM sys.databases 
WHERE database_id < 5
ORDER BY name ASC;

-- To add a row number column in front of each row, add a column with the ROW_NUMBER function, in this case named Row#. 
-- You must move the ORDER BY clause up to the OVER clause.
SELECT 
  ROW_NUMBER() OVER(ORDER BY name ASC) AS Row#,
  name, recovery_model_desc
FROM sys.databases 
WHERE database_id < 5;


-- Adding a PARTITION BY clause on the recovery_model_desc column, 
--will restart the numbering when the recovery_model_desc value changes.

SELECT 
  ROW_NUMBER() OVER(PARTITION BY recovery_model_desc ORDER BY name ASC) 
    AS Row#,
  name, recovery_model_desc
FROM sys.databases WHERE database_id < 5;




B. Returning the row number for salespeople
The following example calculates a row number for the salespeople in Adventure Works Cycles based on their year-to-date sales ranking.

SQL

Copy
USE AdventureWorks2012;   
GO  
SELECT ROW_NUMBER() OVER(ORDER BY SalesYTD DESC) AS Row,   
    FirstName, LastName, ROUND(SalesYTD,2,1) AS "Sales YTD"   
FROM Sales.vSalesPerson  
WHERE TerritoryName IS NOT NULL AND SalesYTD <> 0;  
Here is the result set.


Copy

Row FirstName    LastName               SalesYTD  
--- -----------  ---------------------- -----------------  
1   Linda        Mitchell               4251368.54  
2   Jae          Pak                    4116871.22  
3   Michael      Blythe                 3763178.17  
4   Jillian      Carson                 3189418.36  
5   Ranjit       Varkey Chudukatil      3121616.32  
6   José         Saraiva                2604540.71  
7   Shu          Ito                    2458535.61  
8   Tsvi         Reiter                 2315185.61  
9   Rachel       Valdez                 1827066.71  
10  Tete         Mensa-Annan            1576562.19  
11  David        Campbell               1573012.93  
12  Garrett      Vargas                 1453719.46  
13  Lynn         Tsoflias               1421810.92  
14  Pamela       Ansman-Wolfe           1352577.13  
C. Returning a subset of rows
The following example calculates row numbers for all rows in the SalesOrderHeader table in the order of the OrderDate and returns only rows 50 to 60 inclusive.

SQL

Copy
USE AdventureWorks2012;  
GO  
WITH OrderedOrders AS  
(  
    SELECT SalesOrderID, OrderDate,  
    ROW_NUMBER() OVER (ORDER BY OrderDate) AS RowNumber  
    FROM Sales.SalesOrderHeader   
)   
SELECT SalesOrderID, OrderDate, RowNumber    
FROM OrderedOrders   
WHERE RowNumber BETWEEN 50 AND 60;  
D. Using ROW_NUMBER() with PARTITION
The following example uses the PARTITION BY argument to partition the query result set by the column TerritoryName. The ORDER BY clause specified in the OVER clause orders the rows in each partition by the column SalesYTD. The ORDER BY clause in the SELECT statement orders the entire query result set by TerritoryName.

SQL

Copy
USE AdventureWorks2012;  
GO  
SELECT FirstName, LastName, TerritoryName, ROUND(SalesYTD,2,1) AS SalesYTD,  
ROW_NUMBER() OVER(PARTITION BY TerritoryName ORDER BY SalesYTD DESC) 
  AS Row  
FROM Sales.vSalesPerson  
WHERE TerritoryName IS NOT NULL AND SalesYTD <> 0  
ORDER BY TerritoryName;  
Here is the result set.


Copy

FirstName  LastName             TerritoryName        SalesYTD      Row  
---------  -------------------- ------------------   ------------  ---  
Lynn       Tsoflias             Australia            1421810.92    1  
José       Saraiva              Canada               2604540.71    1  
Garrett    Vargas               Canada               1453719.46    2  
Jillian    Carson               Central              3189418.36    1  
Ranjit     Varkey Chudukatil    France               3121616.32    1  
Rachel     Valdez               Germany              1827066.71    1  
Michael    Blythe               Northeast            3763178.17    1  
Tete       Mensa-Annan          Northwest            1576562.19    1  
David      Campbell             Northwest            1573012.93    2  
Pamela     Ansman-Wolfe         Northwest            1352577.13    3  
Tsvi       Reiter               Southeast            2315185.61    1  
Linda      Mitchell             Southwest            4251368.54    1  
Shu        Ito                  Southwest            2458535.61    2  
Jae        Pak                  United Kingdom       4116871.22    1  
Examples: Azure SQL Data Warehouse and Parallel Data Warehouse
E. Returning the row number for salespeople
The following example returns the ROW_NUMBER for sales representatives based on their assigned sales quota.

SQL

Copy
-- Uses AdventureWorks  

SELECT ROW_NUMBER() OVER(ORDER BY SUM(SalesAmountQuota) DESC) 
    AS RowNumber,  
    FirstName, LastName,   
    CONVERT(varchar(13), SUM(SalesAmountQuota),1) AS SalesQuota   
FROM dbo.DimEmployee AS e  
INNER JOIN dbo.FactSalesQuota AS sq  
    ON e.EmployeeKey = sq.EmployeeKey  
WHERE e.SalesPersonFlag = 1  
GROUP BY LastName, FirstName;  
Here is a partial result set.


Copy

RowNumber  FirstName  LastName            SalesQuota  
---------  ---------  ------------------  -------------  
1          Jillian    Carson              12,198,000.00  
2          Linda      Mitchell            11,786,000.00  
3          Michael    Blythe              11,162,000.00  
4          Jae        Pak                 10,514,000.00  
F. Using ROW_NUMBER() with PARTITION
The following example shows using the ROW_NUMBER function with the PARTITION BY argument. This causes the ROW_NUMBER function to number the rows in each partition.

SQL

Copy
-- Uses AdventureWorks  

SELECT ROW_NUMBER() OVER(PARTITION BY SalesTerritoryKey 
        ORDER BY SUM(SalesAmountQuota) DESC) AS RowNumber,  
    LastName, SalesTerritoryKey AS Territory,  
    CONVERT(varchar(13), SUM(SalesAmountQuota),1) AS SalesQuota   
FROM dbo.DimEmployee AS e  
INNER JOIN dbo.FactSalesQuota AS sq  
    ON e.EmployeeKey = sq.EmployeeKey  
WHERE e.SalesPersonFlag = 1  
GROUP BY LastName, FirstName, SalesTerritoryKey;  
Here is a partial result set.


Copy

RowNumber  LastName            Territory  SalesQuota  
---------  ------------------  ---------  -------------  
1          Campbell            1           4,025,000.00  
2          Ansman-Wolfe        1           3,551,000.00  
3          Mensa-Annan         1           2,275,000.00  
1          Blythe              2          11,162,000.00  
1          Carson              3          12,198,000.00  
1          Mitchell            4          11,786,000.00  
2          Ito                 4           7,804,000.00  




ROW_NUMBER – How To Use It
February 11, 2015 by robert
Facebooktwittergoogle_plusredditpinterestlinkedinmail

ROW_NUMBER is a function built-in to SQL Server that will return a row number for each record in your result set. You can further change resulting row number to reset the row number based on some value in the result set. I will show you examples of both below.

ROW_NUMBER Basics
To show the row number in SQL Server, you need to use the ROW_NUMBER function. This function is broken down in to two parts.

PARTITION BY – If you supply this parameter, then the row number will reset based on the value changing in the columns supplied. This is kinda like using a GROUP BY.
ORDER BY – This is the specified order of the row number that you would like. If you wanted the order of the row number to increment by an employee name (alphabetically), you do that here.
 
With this function I think examples will help paint the full picture.

In the following query, the results will show a row number with each record. The number will start at 1 and increment for every record in order of AnimalName. You can see that that the order of the row number increment is specified as a parameter in to the ROW_NUMBER() function.

1
2
3
4
5
SELECT	AnimalID,
	AnimalName,
	AnimalType,
	ROW_NUMBER() OVER(ORDER BY AnimalName) AS RowNumber
FROM	Animal
AnimalID	AnimalName	AnimalType	RowNumber
166	Alpaca	Mammal	1
168	Camel	Mammal	2
162	Carabao	Mammal	3
171	Cat	Mammal	4
163	Cattle	Mammal	5
184	Chicken	Bird	6
182	Deer	Mammal	7
185	Duck	Bird	8
186	Goose	Bird	9
189	Pigeon	Bird	10
188	Quail	Bird	11
187	Turkey	Bird	12
 
In the above example, the row number never resets. It started at 1 and kept going through all the records. But what if you wanted to reset the row number back to 1 based on a value changing in your result set. In the following example, every time that the AnimalType changes we will reset the row number back to 1. This way, each AnimalType would have it’s own set of row numbers. We accomplish this by listing the columns that we want to group the row numbers by in the PARTITION BY parameter.

1
2
3
4
5
6
SELECT	AnimalID,
	AnimalName,
	AnimalType,
	ROW_NUMBER() OVER(PARTITION BY AnimalType ORDER BY AnimalName) AS RowNumber
FROM	Animal A
ORDER	BY AnimalType, AnimalName
AnimalID	AnimalName	AnimalType	RowNumber
184	Chicken	Bird	1
185	Duck	Bird	2
186	Goose	Bird	3
189	Pigeon	Bird	4
188	Quail	Bird	5
187	Turkey	Bird	6
166	Alpaca	Mammal	1
168	Camel	Mammal	2
162	Carabao	Mammal	3
171	Cat	Mammal	4
163	Cattle	Mammal	5
182	Deer	Mammal	6
 
 
Good Things To Know
You can specify multiple columns in the PARTITION BY and ORDER BY parameters by separating them with a comma.

You can specify ASC or DESC in the ORDER BY parameter if you like as well.

 
Reference: http://msdn.microsoft.com/en-us/library/ms186734.aspx

Categories syntax