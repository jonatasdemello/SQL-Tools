
Undeterministic methods

(in the event that many rows in table 2 match one in table 1)

UPDATE T1
SET    address = T2.address,
       phone2 = T2.phone
FROM   #Table1 T1
JOIN #Table2 T2 ON T1.gender = T2.gender AND T1.birthdate = T2.birthdate

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
	   
-------------------------------------------------------------------------------------------------------------------------------
-- UPDATE USING CTE

ALTER TABLE tbAlmondData ADD Timeframe VARCHAR(9)
 
;WITH UpdateAll AS(
	SELECT Timeframe
	FROM tbAlmondData
)
UPDATE UpdateAll
SET Timeframe = ''


CREATE TABLE QuarterTable(
	QuarterId TINYINT IDENTITY(1,1),
	QuarterValue VARCHAR(2)
)
 
INSERT INTO QuarterTable
VALUES ('Q1')
	, ('Q2')
	, ('Q3')
	, ('Q4')
 
;WITH UpdateTimeframe AS(
	SELECT
		t.Timeframe 
		, tt.QuarterValue + ' ' + CAST(YEAR(AlmondDate) AS VARCHAR(4)) NewTimeframe
	FROM tbAlmondData t
		INNER JOIN QuarterTable tt ON tt.QuarterId = DATEPART(QUARTER,t.AlmondDate)
)
UPDATE UpdateTimeframe
SET Timeframe = NewTimeframe

-- Updates you make to the CTE will be cascaded to the source table.

;WITH T AS
(   
	SELECT  InvoiceNumber, 
            DocTotal, 
            SUM(Sale + VAT) OVER(PARTITION BY InvoiceNumber) AS NewDocTotal
    FROM    PEDI_InvoiceDetail
)
UPDATE  T
SET     DocTotal = NewDocTotal


;WITH CTE_DocTotal  AS
 (
   SELECT SUM(Sale + VAT) AS DocTotal_1
   FROM PEDI_InvoiceDetail
   GROUP BY InvoiceNumber
 )

UPDATE CTE_DocTotal
SET DocTotal = CTE_DocTotal.DocTotal_1


UPDATE PEDI_InvoiceDetail
SET
    DocTotal = v.DocTotal
FROM
     PEDI_InvoiceDetail
INNER JOIN 
(
   SELECT InvoiceNumber, SUM(Sale + VAT) AS DocTotal
   FROM PEDI_InvoiceDetail
   GROUP BY InvoiceNumber
) v
   ON PEDI_InvoiceDetail.InvoiceNumber = v.InvoiceNumber
   