https://docs.microsoft.com/en-us/sql/t-sql/queries/update-transact-sql?view=sql-server-ver15


USE AdventureWorks2012;  
GO  
WITH Parts (AssemblyID, ComponentID, PerAssemblyQty, EndDate, ComponentLevel) AS  
(  
    SELECT b.ProductAssemblyID, b.ComponentID, b.PerAssemblyQty, b.EndDate, 0 AS ComponentLevel  
    FROM Production.BillOfMaterials AS b  
    WHERE b.ProductAssemblyID = 800  AND b.EndDate IS NULL  
    UNION ALL  
    SELECT bom.ProductAssemblyID, bom.ComponentID, p.PerAssemblyQty, bom.EndDate, ComponentLevel + 1  
    FROM Production.BillOfMaterials AS bom 
    INNER JOIN Parts AS p ON bom.ProductAssemblyID = p.ComponentID AND bom.EndDate IS NULL  
)  
UPDATE Production.BillOfMaterials  
SET 
	PerAssemblyQty = c.PerAssemblyQty * 2  
FROM 
	Production.BillOfMaterials AS c  
	JOIN Parts AS d ON c.ProductAssemblyID = d.AssemblyID  
WHERE
	d.ComponentLevel = 0;


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



