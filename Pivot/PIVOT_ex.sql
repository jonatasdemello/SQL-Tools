
-- Pivot:
USE tempdb;
GO

CREATE TABLE dbo.Products
(
  ProductID INT PRIMARY KEY,
  Name      NVARCHAR(255) NOT NULL UNIQUE
  /* other columns */
);
INSERT dbo.Products VALUES
    (1, N'foo'),
    (2, N'bar'),
    (3, N'kin');

CREATE TABLE dbo.OrderDetails
(
  OrderID INT,
  ProductID INT NOT NULL
    FOREIGN KEY REFERENCES dbo.Products(ProductID),
  Quantity INT
  /* other columns */
);
INSERT dbo.OrderDetails VALUES
    (1, 1, 1),
    (1, 2, 2),
    (2, 1, 1),
    (3, 3, 1);


SELECT p.Name, Quantity = SUM(o.Quantity)
  FROM dbo.Products AS p
  INNER JOIN dbo.OrderDetails AS o
  ON p.ProductID = o.ProductID
  GROUP BY p.Name;



SELECT p.[foo], p.[bar], p.[kin]
FROM
(
  SELECT p.Name, o.Quantity
   FROM dbo.Products AS p
   INNER JOIN dbo.OrderDetails AS o ON p.ProductID = o.ProductID
) AS j
PIVOT
(
  SUM(Quantity) FOR Name IN ([foo],[bar],[kin])
) AS p;



GO
-------------------------------------------------------------------------------------------------------------------------------


CREATE TABLE [dbo].[SalesTerritory](
   [Group] varchar(8),
   [SalesYTD] int
)
GO
INSERT INTO [dbo].[SalesTerritory] values ('Europe',10)
INSERT INTO [dbo].[SalesTerritory] values ('America',20)
INSERT INTO [dbo].[SalesTerritory] values ('Pacific',30)


SELECT  [Group], SUM([SalesYTD]) SalesYTD
FROM [dbo].[SalesTerritory]
GROUP BY [Group]

-- Pivot
SELECT 'SalesYTD' AS SalesYTD, [Europe], [America], [Pacific]
FROM  
(
    SELECT SalesYTD, [Group] FROM [dbo].[SalesTerritory] 
) AS TableToPivot 
PIVOT  
(  
  SUM(SalesYTD)  
    FOR [Group] IN ([Europe], [America], [Pacific])  
) AS PivotTable;  


SELECT territory, sales
FROM
(
    SELECT [Europe] ,[North America],[Pacific]
    FROM [dbo].[salesterritoryPivot]
) p
UNPIVOT
(
  sales for territory IN
  ([Europe],[North America],[Pacific])
) AS upvt;


-------------------------------------------------------------------------------------------------------------------------------
-- https://www.c-sharpcorner.com/UploadFile/f0b2ed/pivot-and-unpovit-in-sql-server/

CREATE TABLE Employee  
(  
    Name [nvarchar](max),  
    [Year] [int] ,  
    Sales [int]  
)  



INSERT INTO Employee  
SELECT 'Pankaj',2010,72500 UNION ALL  
SELECT 'Rahul',2010,60500 UNION ALL  
SELECT 'Sandeep',2010,52000 UNION ALL  
SELECT 'Pankaj',2011,45000 UNION ALL  
SELECT 'Sandeep',2011,82500 UNION ALL  
SELECT 'Rahul',2011,35600 UNION ALL  
SELECT 'Pankaj',2012,32500 UNION ALL  
SELECT 'Pankaj',2010,20500 UNION ALL  
SELECT 'Rahul',2011,200500 UNION ALL  
SELECT 'Sandeep',2010,32000   


SELECT * FROM Employee;  

SELECT <non-pivoted column>,  
    <list of pivoted column>  
FROM  
(<SELECT query  to produces the data>)  
AS <alias name>  
PIVOT  
(  
<aggregation function>(<column name>)  
FOR  
[<column name that  become column headers>]  
IN ( [list of  pivoted columns])  

) AS <alias name  for  pivot table>  



SELECT [Year], Pankaj,Rahul,Sandeep FROM   
(SELECT Name, [Year] , Sales FROM Employee )Tab1  
PIVOT  
(  
SUM(Sales) FOR Name IN (Pankaj,Rahul,Sandeep)) AS Tab2  
ORDER BY [Tab2].[Year]  


SELECT Name, 2010,2011,2012 FROM   
(SELECT Name, [Year] , Sales FROM Employee )Tab1  
PIVOT  
(  
SUM(Sales) FOR [Year] IN (2010,2011,2012)) AS Tab2  
ORDER BY Tab2.Name 


SELECT Name, [2010],[2011],[2012] FROM   
(SELECT Name, [Year] , Sales FROM Employee )Tab1  
PIVOT  
(  
SUM(Sales) FOR [Year] IN ([2010],[2011],[2012])) AS Tab2  
ORDER BY Tab2.Name  


/*Declare Variable*/  
DECLARE @Pivot_Column [nvarchar](max);  
DECLARE @Query [nvarchar](max);  
    
/*Select Pivot Column*/  
SELECT @Pivot_Column= COALESCE(@Pivot_Column+',','')+ QUOTENAME(Year) FROM  
(SELECT DISTINCT [Year] FROM Employee)Tab  
    
/*Create Dynamic Query*/  
SELECT @Query='SELECT Name, '+@Pivot_Column+'FROM   
(SELECT Name, [Year] , Sales FROM Employee )Tab1  
PIVOT  
(  
SUM(Sales) FOR [Year] IN ('+@Pivot_Column+')) AS Tab2  
ORDER BY Tab2.Name'  
    
/*Execute Query*/  
EXEC  sp_executesql  @Query  



DECLARE @Tab TABLE  
(  
    [Year] int,  
    Pankaj int,  
    Rahul int,  
    Sandeep int  
)  

Insert Value in Temp Variable

INSERT INTO @Tab  
SELECT [Year], Pankaj,Rahul,Sandeep FROM   
(SELECT Name, [Year] , Sales FROM Employee )Tab1  
PIVOT  
(  
    SUM(Sales) FOR Name IN (Pankaj,Rahul,Sandeep)) AS Tab2  
    ORDER BY [Tab2].[Year]  

Perform UNPIVOT Operation

SELECT Name,[Year] , Sales FROM @Tab t  
UNPIVOT  
(  
Sales FOR Name IN (Pankaj,Rahul,Sandeep)  
) AS TAb2 

SELECT Name,[Year] , Sales FROM   
(  
SELECT [Year], Pankaj,Rahul,Sandeep FROM   
(SELECT Name, [Year] , Sales FROM Employee )Tab1  
PIVOT  
(  
SUM(Sales) FOR Name IN (Pankaj,Rahul,Sandeep)) AS Tab2  
)Tab  
UNPIVOT  
(  
Sales FOR Name IN (Pankaj,Rahul,Sandeep)  
) AS TAb2 


SELECT Name,[Year] , Sales FROM   
(  
    SELECT [Year], Pankaj,Rahul,Sandeep FROM   
    (SELECT Name, [Year] , Sales FROM Employee )Tab1  
PIVOT  
(  
    SUM(Sales) FOR Name IN (Pankaj,Rahul,Sandeep)) AS Tab2  
)Tab  
UNPIVOT  
(  
    Sales FOR Name IN (Pankaj,Rahul,Sandeep)  
) AS TAb2  

SELECT Name,[Year] , Sales FROM   
(  
    SELECT [Year], Pankaj,Rahul,Sandeep FROM   
    (SELECT Name, [Year] , Sales FROM Employee )Tab1  
PIVOT  
(  
    SUM(Sales) FOR Name IN (Pankaj,Rahul,Sandeep)) AS Tab2  
)Tab  
UNPIVOT  
(  
    Sales FOR Name IN (Pankaj,Rahul,Sandeep)  
) AS TAb2  


