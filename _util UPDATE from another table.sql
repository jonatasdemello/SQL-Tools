/*

A. Using the UPDATE statement with information from another table

The following example modifies the SalesYTD column in the SalesPerson table
 to reflect the most recent sales recorded in the SalesOrderHeader table.

Transact-SQL Copy Code 
*/
USE AdventureWorks2008R2;
GO
UPDATE Sales.SalesPerson
SET SalesYTD = SalesYTD + SubTotal
FROM Sales.SalesPerson AS sp
JOIN Sales.SalesOrderHeader AS so
    ON sp.BusinessEntityID = so.SalesPersonID
    AND so.OrderDate = (SELECT MAX(OrderDate)
                        FROM Sales.SalesOrderHeader
                        WHERE SalesPersonID = sp.BusinessEntityID);
GO


