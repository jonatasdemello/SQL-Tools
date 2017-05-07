
-- 2012

USE AdventureWorks2012;
GO
SELECT p.FirstName, p.LastName
    ,ROW_NUMBER() OVER (ORDER BY a.PostalCode) AS "Row Number"
    ,RANK() OVER (ORDER BY a.PostalCode) AS Rank
    ,DENSE_RANK() OVER (ORDER BY a.PostalCode) AS "Dense Rank"
    ,NTILE(4) OVER (ORDER BY a.PostalCode) AS Quartile
    ,s.SalesYTD, a.PostalCode
FROM Sales.SalesPerson AS s 
    INNER JOIN Person.Person AS p 
        ON s.BusinessEntityID = p.BusinessEntityID
    INNER JOIN Person.Address AS a 
        ON a.AddressID = p.BusinessEntityID
WHERE TerritoryID IS NOT NULL 
    AND SalesYTD <> 0;

--2008

USE AdventureWorks2008R2;
GO
SELECT p.FirstName, p.LastName
    ,ROW_NUMBER() OVER (ORDER BY a.PostalCode) AS 'Row Number'
    ,RANK() OVER (ORDER BY a.PostalCode) AS 'Rank'
    ,DENSE_RANK() OVER (ORDER BY a.PostalCode) AS 'Dense Rank'
    ,NTILE(4) OVER (ORDER BY a.PostalCode) AS 'Quartile'
    ,s.SalesYTD, a.PostalCode
FROM Sales.SalesPerson s 
    INNER JOIN Person.Person p 
        ON s.BusinessEntityID = p.BusinessEntityID
    INNER JOIN Person.Address a 
        ON a.AddressID = p.BusinessEntityID
WHERE TerritoryID IS NOT NULL 
    AND SalesYTD <> 0;



-- 2005
USE AdventureWorks;
GO
SELECT c.FirstName, c.LastName
    ,ROW_NUMBER() OVER (ORDER BY a.PostalCode) AS 'Row Number'
    ,RANK() OVER (ORDER BY a.PostalCode) AS 'Rank'
    ,DENSE_RANK() OVER (ORDER BY a.PostalCode) AS 'Dense Rank'
    ,NTILE(4) OVER (ORDER BY a.PostalCode) AS 'Quartile'
    ,s.SalesYTD, a.PostalCode
FROM Sales.SalesPerson s 
    INNER JOIN Person.Contact c 
        ON s.SalesPersonID = c.ContactID
    INNER JOIN Person.Address a 
        ON a.AddressID = c.ContactID
WHERE TerritoryID IS NOT NULL 
    AND SalesYTD <> 0;


-- 2008
SELECT p.FirstName, p.LastName
    ,ROW_NUMBER() OVER(ORDER BY SalesYTD DESC) AS 'Row Number'
    ,s.SalesYTD, a.PostalCode
FROM Sales.SalesPerson s 
    INNER JOIN Person.Person p 
        ON s.BusinessEntityID = p.BusinessEntityID
    INNER JOIN Person.Address a 
        ON a.AddressID = p.BusinessEntityID
WHERE TerritoryID IS NOT NULL 
    AND SalesYTD <> 0;
GO



--2005
USE AdventureWorks;
GO
SELECT c.FirstName, c.LastName
    ,ROW_NUMBER() OVER(ORDER BY SalesYTD DESC) AS 'Row Number'
    ,s.SalesYTD, a.PostalCode
FROM Sales.SalesPerson s 
    INNER JOIN Person.Contact c 
        ON s.SalesPersonID = c.ContactID
    INNER JOIN Person.Address a 
        ON a.AddressID = c.ContactID
WHERE TerritoryID IS NOT NULL 
    AND SalesYTD <> 0;
GO

USE AdventureWorks;
GO
SELECT SalesOrderID, ProductID, OrderQty
    ,SUM(OrderQty) OVER(PARTITION BY SalesOrderID) AS 'Total'
    ,AVG(OrderQty) OVER(PARTITION BY SalesOrderID) AS 'Avg'
    ,COUNT(OrderQty) OVER(PARTITION BY SalesOrderID) AS 'Count'
    ,MIN(OrderQty) OVER(PARTITION BY SalesOrderID) AS 'Min'
    ,MAX(OrderQty) OVER(PARTITION BY SalesOrderID) AS 'Max'
FROM Sales.SalesOrderDetail 
WHERE SalesOrderID IN(43659,43664);
GO

GO
SELECT SalesOrderID, ProductID, OrderQty
    ,SUM(OrderQty) OVER(PARTITION BY SalesOrderID) AS 'Total'
    ,CAST(1. * OrderQty / SUM(OrderQty) OVER(PARTITION BY SalesOrderID) 
        *100 AS DECIMAL(5,2))AS 'Percent by ProductID'
FROM Sales.SalesOrderDetail 
WHERE SalesOrderID IN(43659,43664);
GO



USE AdventureWorks2008R2;
GO
SELECT i.ProductID, p.Name, i.LocationID, i.Quantity
    ,RANK() OVER 
    (PARTITION BY i.LocationID ORDER BY i.Quantity DESC) AS 'RANK'
FROM Production.ProductInventory i 
    INNER JOIN Production.Product p 
        ON i.ProductID = p.ProductID
ORDER BY p.Name;
GO



-- Basic PIVOT Example


USE AdventureWorks ;
GO
SELECT DaysToManufacture, AVG(StandardCost) AS AverageCost 
FROM Production.Product
GROUP BY DaysToManufacture

/*
Here is the result set. 

DaysToManufacture          AverageCost 
0                          5.0885 
1                          223.88 
2                          359.1082 
4                          949.4105 

No products are defined with three DaysToManufacture.
The following code displays the same result, pivoted so that the 
DaysToManufacture values become the column headings. 
A column is provided for three [3] days, even though the results are NULL.
*/

-- Pivot table with one row and five columns
SELECT 'AverageCost' AS Cost_Sorted_By_Production_Days, [0], [1], [2], [3], [4]
FROM
(SELECT DaysToManufacture, StandardCost FROM Production.Product) AS SourceTable
PIVOT
( AVG(StandardCost) FOR DaysToManufacture IN ([0], [1], [2], [3], [4]) ) AS PivotTable

/*
Cost_Sorted_By_Production_Days    0         1         2           3       4        
AverageCost                       5.0885    223.88    359.1082    NULL    949.4105 
*/
/*
A common scenario where PIVOT can be useful is when you want to generate 
cross-tabulation reports to summarize data. 
For example, suppose you want to query the PurchaseOrderHeader table in the
AdventureWorks sample database to determine the number of purchase orders 
placed by certain employees. The following query provides this report, ordered by vendor.

*/


USE AdventureWorks;
GO
SELECT VendorID, [164] AS Emp1, [198] AS Emp2, [223] AS Emp3, [231] AS Emp4, [233] AS Emp5
FROM 
(SELECT PurchaseOrderID, EmployeeID, VendorID FROM Purchasing.PurchaseOrderHeader) p
PIVOT
( COUNT (PurchaseOrderID)
FOR EmployeeID IN ( [164], [198], [223], [231], [233] ) 
) AS pvt
ORDER BY VendorID








/*
The APPLY operator allows you to invoke a table-valued function for each row returned 
by an outer table expression of a query. The table-valued function acts as the 
,right input and the outer table expression acts as the left input. 
The right input is evaluated for each row from the left input and the rows 
produced are combined for the final output. The list of columns produced by 
the APPLY operator is the set of columns in the left input followed by the 
list of columns returned by the right input. 

Note 
To use APPLY, the database compatibility level must be at least 90.
 

There are two forms of APPLY: CROSS APPLY and OUTER APPLY. 
CROSS APPLY returns only rows from the outer table that produce a result 
set from the table-valued function. 
OUTER APPLY returns both rows that produce a result set, and rows that do not, 
with NULL values in the columns produced by the table-valued function.

As an example, consider the following tables, Employees and Departments:


*/

--Create Employees table and insert values.
CREATE TABLE Employees
(
    empid   int         NOT NULL
    ,mgrid   int         NULL
    ,empname varchar(25) NOT NULL
    ,salary  money       NOT NULL
    CONSTRAINT PK_Employees PRIMARY KEY(empid)
);
GO
INSERT INTO Employees VALUES(1 , NULL, 'Nancy'   , $10000.00);
INSERT INTO Employees VALUES(2 , 1   , 'Andrew'  , $5000.00);
INSERT INTO Employees VALUES(3 , 1   , 'Janet'   , $5000.00);
INSERT INTO Employees VALUES(4 , 1   , 'Margaret', $5000.00);
INSERT INTO Employees VALUES(5 , 2   , 'Steven'  , $2500.00);
INSERT INTO Employees VALUES(6 , 2   , 'Michael' , $2500.00);
INSERT INTO Employees VALUES(7 , 3   , 'Robert'  , $2500.00);
INSERT INTO Employees VALUES(8 , 3   , 'Laura'   , $2500.00);
INSERT INTO Employees VALUES(9 , 3   , 'Ann'     , $2500.00);
INSERT INTO Employees VALUES(10, 4   , 'Ina'     , $2500.00);
INSERT INTO Employees VALUES(11, 7   , 'David'   , $2000.00);
INSERT INTO Employees VALUES(12, 7   , 'Ron'     , $2000.00);
INSERT INTO Employees VALUES(13, 7   , 'Dan'     , $2000.00);
INSERT INTO Employees VALUES(14, 11  , 'James'   , $1500.00);
GO
--Create Departments table and insert values.
CREATE TABLE Departments
(
    deptid    INT NOT NULL PRIMARY KEY
    ,deptname  VARCHAR(25) NOT NULL
    ,deptmgrid INT NULL REFERENCES Employees
);
GO
INSERT INTO Departments VALUES(1, 'HR',           2);
INSERT INTO Departments VALUES(2, 'Marketing',    7);
INSERT INTO Departments VALUES(3, 'Finance',      8);
INSERT INTO Departments VALUES(4, 'R&D',          9);
INSERT INTO Departments VALUES(5, 'Training',     4);
INSERT INTO Departments VALUES(6, 'Gardening', NULL);

Most departments in the Departments table have a manager ID that corresponds to an employee in the Employees table. The following table-valued function accepts an employee ID as an argument and returns that employee and all of his or her subordinates.

Copy
 CREATE FUNCTION dbo.fn_getsubtree(@empid AS INT) 
    RETURNS @TREE TABLE
(
    empid   INT NOT NULL
    ,empname VARCHAR(25) NOT NULL
    ,mgrid   INT NULL
    ,lvl     INT NOT NULL
)
AS
BEGIN
  WITH Employees_Subtree(empid, empname, mgrid, lvl)
  AS
  ( 
    -- Anchor Member (AM)
    SELECT empid, empname, mgrid, 0
    FROM Employees
    WHERE empid = @empid

    UNION all
    
    -- Recursive Member (RM)
    SELECT e.empid, e.empname, e.mgrid, es.lvl+1
    FROM Employees AS e
      JOIN Employees_Subtree AS es
        ON e.mgrid = es.empid
  )
  INSERT INTO @TREE
    SELECT * FROM Employees_Subtree;

  RETURN
END
GO
To return all of the subordinates in all levels for the manager of each department, use the following query.

Copy
 SELECT D.deptid, D.deptname, D.deptmgrid
    ,ST.empid, ST.empname, ST.mgrid
FROM Departments AS D
    CROSS APPLY fn_getsubtree(D.deptmgrid) AS ST;
Here is the result set.

