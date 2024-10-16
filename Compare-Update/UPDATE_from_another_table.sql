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


-------------------------------------------------------------------------------------------------------------------------------
Undeterministic methods

(in the event that many rows in table 2 match one in table 1)

UPDATE T1
SET    address = T2.address,
       phone2 = T2.phone
FROM   #Table1 T1
       JOIN #Table2 T2
         ON T1.gender = T2.gender
            AND T1.birthdate = T2.birthdate

Or a slightly more concise form

UPDATE #Table1
SET    address = #Table2.address,
       phone2 = #Table2.phone
FROM   #Table2
WHERE  #Table2.gender = #Table1.gender
       AND #Table2.birthdate = #Table1.birthdate 

Or with a CTE

WITH CTE
     AS (SELECT T1.address AS tgt_address,
                T1.phone2  AS tgt_phone,
                T2.address AS source_address,
                T2.phone   AS source_phone
         FROM   #Table1 T1
                INNER JOIN #Table2 T2
                  ON T1.gender = T2.gender
                     AND T1.birthdate = T2.birthdate)
UPDATE CTE
SET    tgt_address = source_address,
       tgt_phone = source_phone 

Deterministic methods

MERGE would throw an error rather than accept non deterministic results

MERGE #Table1 T1
USING #Table2 T2
ON T1.gender = T2.gender
   AND T1.birthdate = T2.birthdate
WHEN MATCHED THEN
  UPDATE SET address = T2.address,
             phone2 = T2.phone; 

Or you could pick a specific record if there is more than one match

With APPLY

UPDATE T1
SET    address = T2.address,
       phone2 = T2.phone
FROM   #Table1 T1
       CROSS APPLY (SELECT TOP 1 *
                    FROM   #Table2 T2
                    WHERE  T1.gender = T2.gender
                           AND T1.birthdate = T2.birthdate
                    ORDER  BY T2.PrimaryKey) T2 

.. Or a CTE

WITH T2
     AS (SELECT *,
                ROW_NUMBER() OVER (PARTITION BY gender, birthdate ORDER BY primarykey) AS RN
         FROM   #Table2)
UPDATE T1
SET    address = T2.address,
       phone2 = T2.phone
FROM   #Table1 T1
       JOIN T2
         ON T1.gender = T2.gender
            AND T1.birthdate = T2.birthdate
            AND T2.RN = 1;

