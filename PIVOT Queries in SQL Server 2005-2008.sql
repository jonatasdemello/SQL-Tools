/*
Getting started with PIVOT Queries in SQL Server 2005/2008
*/

CREATE TABLE invoice (
    InvoiceNumber VARCHAR(20),
    invoiceDate DATETIME,
    InvoiceAmount MONEY 
)


INSERT INTO invoice
SELECT 'INV001', '2005-01-01', 100 UNION ALL
SELECT 'INV002', '2005-02-01', 40 UNION ALL
SELECT 'INV003', '2005-03-01', 60 UNION ALL
SELECT 'INV004', '2005-03-10', 15 UNION ALL
SELECT 'INV005', '2005-04-01', 50 UNION ALL
SELECT 'INV006', '2005-05-01', 77 UNION ALL
SELECT 'INV007', '2005-06-01', 12 UNION ALL
SELECT 'INV008', '2005-06-05', 56 UNION ALL
SELECT 'INV009', '2005-07-01', 34 UNION ALL
SELECT 'INV010', '2005-08-01', 76 UNION ALL
SELECT 'INV011', '2005-09-01', 24 UNION ALL
SELECT 'INV012', '2005-09-20', 10 UNION ALL
SELECT 'INV013', '2005-10-01', 15 UNION ALL
SELECT 'INV014', '2005-11-01', 40 UNION ALL
SELECT 'INV015', '2005-11-15', 21 UNION ALL
SELECT 'INV016', '2005-12-01', 17 UNION ALL
SELECT 'INV017', '2006-01-01', 34 UNION ALL
SELECT 'INV018', '2006-02-01', 24 UNION ALL
SELECT 'INV019', '2006-03-01', 56 UNION ALL
SELECT 'INV020', '2006-03-10', 43 UNION ALL
SELECT 'INV021', '2006-04-01', 24 UNION ALL
SELECT 'INV022', '2006-05-01', 11 UNION ALL
SELECT 'INV023', '2006-06-01', 6 UNION ALL
SELECT 'INV024', '2006-06-05', 13

/********************************/

SELECT *
FROM (
    SELECT 
        year(invoiceDate) as [year], 
        left(datename(month,invoicedate),3)as [month], 
        InvoiceAmount as Amount 
    FROM Invoice
) as s
PIVOT
(
    SUM(Amount) FOR [month] IN (
        jan, feb, mar, apr, 
        may, jun, jul, aug, sep, oct, nov, dec
    )
)AS p


/********************************/

SELECT *
FROM (
    SELECT 
        year(invoiceDate) as [year], 
        left(datename(month,invoicedate),3)as [month], 
        InvoiceAmount as Amount 
    FROM Invoice
) as s 

/********************************/

SELECT *
FROM (
    SELECT 
        year(invoiceDate) as [year], 
        left(datename(month,invoicedate),3)as [month], 
        InvoiceAmount as Amount 
    FROM Invoice
) as s
PIVOT
(
    SUM(Amount)
    FOR [month] IN (jan, feb, mar, apr, 
    may, jun, jul, aug, sep, oct, nov, dec)
)AS p

/********************************/



SELECT TOP(50000)
    'Customer' + CAST(ROW_NUMBER() OVER(ORDER BY (SELECT(1))) AS VARCHAR),
    'NY'
FROM sys.all_objects o1
CROSS JOIN sys.all_objects o2


SELECT * FROM sys.all_objects 
-- CROSS JOIN sys.all_objects o2


SELECT TOP(50000) 'Customer' + CAST(ROW_NUMBER() OVER(ORDER BY (SELECT(1))) AS VARCHAR)
