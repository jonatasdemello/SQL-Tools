USE AdventureWorks2012;  
GO  
UPDATE Sales.SalesPerson  
	SET SalesYTD = SalesYTD + SubTotal  
	FROM Sales.SalesPerson AS sp  
		JOIN Sales.SalesOrderHeader AS so  ON sp.BusinessEntityID = so.SalesPersonID  
			AND so.OrderDate = (SELECT MAX(OrderDate) FROM Sales.SalesOrderHeader WHERE SalesPersonID = sp.BusinessEntityID);
GO  


USE AdventureWorks2012;  
GO  
UPDATE Sales.SalesPerson  
SET SalesYTD = SalesYTD +   
    (SELECT SUM(so.SubTotal)   
     FROM Sales.SalesOrderHeader AS so  
     WHERE so.OrderDate = (SELECT MAX(OrderDate)  
                           FROM Sales.SalesOrderHeader AS so2  
                           WHERE so2.SalesPersonID = so.SalesPersonID)  
     AND Sales.SalesPerson.BusinessEntityID = so.SalesPersonID  
     GROUP BY so.SalesPersonID);  
GO  

USE tempdb;  
GO  
-- UPDATE statement with CTE references that are correctly matched.  
DECLARE @x TABLE (ID int, Value int);  
DECLARE @y TABLE (ID int, Value int);  
INSERT @x VALUES (1, 10), (2, 20);  
INSERT @y VALUES (1, 100),(2, 200);  

WITH cte AS (SELECT * FROM @x)  
UPDATE x -- cte is referenced by the alias.  
	SET Value = y.Value  
	FROM cte AS x  -- cte is assigned an alias.  
	INNER JOIN @y AS y ON y.ID = x.ID;  
SELECT * FROM @x;  
GO  

USE tempdb;  
GO  
DECLARE @x TABLE (ID int, Value int);  
DECLARE @y TABLE (ID int, Value int);  
INSERT @x VALUES (1, 10), (2, 20);  
INSERT @y VALUES (1, 100),(2, 200);  

WITH cte AS (SELECT * FROM @x)  
	UPDATE cte   -- cte is not referenced by the alias.  
	SET Value = y.Value  
	FROM cte AS x  -- cte is assigned an alias.  
	INNER JOIN @y AS y ON y.ID = x.ID;   
SELECT * FROM @x;   
GO  
