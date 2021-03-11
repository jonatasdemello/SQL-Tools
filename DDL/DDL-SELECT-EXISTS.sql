-- EXISTS ( subquery )
-- https://docs.microsoft.com/en-us/sql/t-sql/language-elements/exists-transact-sql?view=sql-server-ver15

USE AdventureWorks2012;

-- A. Using NULL in a subquery to still return a result set
-- The following example returns a result set with NULL specified in the subquery and still evaluates to TRUE by using EXISTS.

SELECT DepartmentID, Name   FROM HumanResources.Department   ORDER BY Name ASC ;

SELECT DepartmentID, Name
FROM HumanResources.Department
WHERE EXISTS (SELECT NULL)
ORDER BY Name ASC ;

-- B. Comparing queries by using EXISTS and IN
-- The following example compares two queries that are semantically equivalent.

-- The first query uses EXISTS

SELECT a.FirstName, a.LastName
FROM Person.Person AS a
WHERE EXISTS
    (SELECT * FROM HumanResources.Employee AS b
    WHERE a.BusinessEntityID = b.BusinessEntityID AND a.LastName = 'Johnson') ;
GO

-- The following query uses IN.

SELECT a.FirstName, a.LastName
FROM Person.Person AS a
WHERE a.LastName IN
    (SELECT a.LastName
    FROM HumanResources.Employee AS b
    WHERE a.BusinessEntityID = b.BusinessEntityID AND a.LastName = 'Johnson') ;
GO

-- C. Comparing queries by using EXISTS and = ANY
-- The following example shows two queries to find stores whose name is the same name as a vendor.
-- The first query uses EXISTS and the second uses =``ANY.

SELECT DISTINCT s.Name
FROM Sales.Store AS s
WHERE EXISTS
    (SELECT *
    FROM Purchasing.Vendor AS v
    WHERE s.Name = v.Name) ;
GO

-- The following query uses = ANY.

SELECT DISTINCT s.Name
FROM Sales.Store AS s
WHERE s.Name = ANY
    (SELECT v.Name
    FROM Purchasing.Vendor AS v ) ;
GO

-- D. Comparing queries by using EXISTS and IN
-- The following example shows queries to find employees of departments that start with P.

SELECT p.FirstName, p.LastName, e.JobTitle
FROM Person.Person AS p
JOIN HumanResources.Employee AS e ON e.BusinessEntityID = p.BusinessEntityID
WHERE EXISTS
    (SELECT *
    FROM HumanResources.Department AS d
    JOIN HumanResources.EmployeeDepartmentHistory AS edh ON d.DepartmentID = edh.DepartmentID
    WHERE e.BusinessEntityID = edh.BusinessEntityID AND d.Name LIKE 'P%') ;
GO

-- The following query uses IN.

SELECT p.FirstName, p.LastName, e.JobTitle
FROM Person.Person AS p JOIN HumanResources.Employee AS e ON e.BusinessEntityID = p.BusinessEntityID
JOIN HumanResources.EmployeeDepartmentHistory AS edh ON e.BusinessEntityID = edh.BusinessEntityID
WHERE edh.DepartmentID IN
    (SELECT DepartmentID
   FROM HumanResources.Department
   WHERE Name LIKE 'P%') ;
GO

-- E. Using NOT EXISTS
-- NOT EXISTS works the opposite of EXISTS.
-- The WHERE clause in NOT EXISTS is satisfied if no rows are returned by the subquery.
-- The following example finds employees who are not in departments which have names that start with P.

SELECT p.FirstName, p.LastName, e.JobTitle
FROM Person.Person AS p
JOIN HumanResources.Employee AS e ON e.BusinessEntityID = p.BusinessEntityID
WHERE NOT EXISTS
    (SELECT *
   FROM HumanResources.Department AS d
   JOIN HumanResources.EmployeeDepartmentHistory AS edh ON d.DepartmentID = edh.DepartmentID
   WHERE e.BusinessEntityID = edh.BusinessEntityID AND d.Name LIKE 'P%')
ORDER BY LastName, FirstName
GO



-- The first example shows queries that are semantically equivalent to illustrate the difference between using the EXISTS keyword and the IN keyword.
-- Both are examples of a valid subquery that retrieves one instance of each product name for which the product model is a long sleeve logo jersey,
-- and the ProductModelID numbers match between the Product and ProductModel tables.

SELECT DISTINCT Name
FROM Production.Product AS p
WHERE EXISTS
    (SELECT *
     FROM Production.ProductModel AS pm
     WHERE p.ProductModelID = pm.ProductModelID AND pm.Name LIKE 'Long-Sleeve Logo Jersey%');
GO

SELECT DISTINCT p.Name
FROM Production.Product as p
WHERE ProductModelID IN
    (SELECT ProductModelID
     FROM Production.ProductModel AS pm
     WHERE p.ProductModelID = pm.ProductModelID AND Name LIKE 'Long-Sleeve Logo Jersey%');
GO

-- The next example uses IN and retrieves one instance of the first and last name of each employee
-- for which the bonus in the SalesPerson table is 5000.00
-- and for which the employee identification numbers match in the Employee and SalesPerson tables.

SELECT DISTINCT p.LastName, p.FirstName
FROM Person.Person AS p
JOIN HumanResources.Employee AS e ON e.BusinessEntityID = p.BusinessEntityID
WHERE 5000.00 IN
    (SELECT Bonus
     FROM Sales.SalesPerson AS sp
     WHERE e.BusinessEntityID = sp.BusinessEntityID);
GO

-- The previous subquery in this statement cannot be evaluated independently of the outer query.
-- It requires a value for Employee.EmployeeID, but this value changes as the SQL Server Database Engine examines different rows in Employee.
-- A correlated subquery can also be used in the HAVING clause of an outer query.
-- This example finds the product models for which the maximum list price is more than twice the average for the model.

SELECT p1.ProductModelID
FROM Production.Product AS p1
GROUP BY p1.ProductModelID
HAVING MAX(p1.ListPrice) >=
    (SELECT AVG(p2.ListPrice) * 2
     FROM Production.Product AS p2
     WHERE p1.ProductModelID = p2.ProductModelID);
GO

--This example uses two correlated subqueries to find the names of employees who have sold a particular product.

SELECT DISTINCT pp.LastName, pp.FirstName
FROM Person.Person pp JOIN HumanResources.Employee e ON e.BusinessEntityID = pp.BusinessEntityID
WHERE pp.BusinessEntityID IN
    (SELECT SalesPersonID
    FROM Sales.SalesOrderHeader
    WHERE SalesOrderID IN
        (SELECT SalesOrderID
        FROM Sales.SalesOrderDetail
        WHERE ProductID IN
            (SELECT ProductID
            FROM Production.Product p
            WHERE ProductNumber = 'BK-M68B-42')
        )
    );
GO
