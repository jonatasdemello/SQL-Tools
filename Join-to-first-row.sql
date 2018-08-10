
-- SQL Server: How to Join to first row
-- https://stackoverflow.com/questions/2043259/sql-server-how-to-join-to-first-row

SELECT   Orders.OrderNumber, LineItems.Quantity, LineItems.Description
FROM     Orders
JOIN     LineItems
ON       LineItems.LineItemGUID =
         (
         SELECT  TOP 1 LineItemGUID 
         FROM    LineItems
         WHERE   OrderID = Orders.OrderID
         )

-- In SQL Server 2005 and above, you could just replace INNER JOIN with CROSS APPLY:

SELECT  Orders.OrderNumber, LineItems2.Quantity, LineItems2.Description
FROM    Orders
CROSS APPLY
        (
        SELECT  TOP 1 LineItems.Quantity, LineItems.Description
        FROM    LineItems
        WHERE   LineItems.OrderID = Orders.OrderID
        ) LineItems2
		
	