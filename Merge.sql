
CREATE TABLE ##t1
(
  digit INT,
  name NVARCHAR(10)
);
GO  

CREATE PROCEDURE ##insert_to_t1
(
  @digit INT,
  @name NVARCHAR(10)
)
AS 
BEGIN
	MERGE ##t1 AS tgt
	USING ( SELECT @digit, @name ) AS src ( digit, name ) ON  ( tgt.digit = src.digit )
	WHEN MATCHED 
		THEN 
			UPDATE SET name = src.name
	WHEN NOT MATCHED 
		THEN 
			INSERT ( digit, name ) VALUES ( src.digit, src.name ) ;
END ;
GO  

--execute this next bit in a different window (i.e. a different connection)
EXEC ##insert_to_t1 1,'One';  
EXEC ##insert_to_t1 2,'Two';  
EXEC ##insert_to_t1 3,'Three';  
EXEC ##insert_to_t1 4,'Not Four';  
EXEC ##insert_to_t1 4,'Four'; --update previous record!  

SELECT  * FROM  ##t1 ; 
 --this returned the expected 4 rows by the way!!! 

DROP TABLE ##t1
DROP PROC ##insert_to_t1



/***************************************/

USE AdventureWorks2008R2;
GO
CREATE PROCEDURE dbo.InsertUnitMeasure
    @UnitMeasureCode nchar(3),
    @Name nvarchar(25)
AS 
BEGIN
    SET NOCOUNT ON;
-- Update the row if it exists.    
    UPDATE Production.UnitMeasure
	SET Name = @Name
	WHERE UnitMeasureCode = @UnitMeasureCode
-- Insert the row if the UPDATE statement failed.	
	IF (@@ROWCOUNT = 0 )
	BEGIN
	    INSERT INTO Production.UnitMeasure (UnitMeasureCode, Name)
	    VALUES (@UnitMeasureCode, @Name)
	END
END;
GO
-- Test the procedure and return the results.
EXEC InsertUnitMeasure @UnitMeasureCode = 'ABC', @Name = 'Test Value';
SELECT UnitMeasureCode, Name FROM Production.UnitMeasure
WHERE UnitMeasureCode = 'ABC';
GO

-- Rewrite the procedure to perform the same operations using the MERGE statement.
-- Create a temporary table to hold the updated or inserted values from the OUTPUT clause.
CREATE TABLE #MyTempTable
    (ExistingCode nchar(3),
     ExistingName nvarchar(50),
     ExistingDate datetime,
     ActionTaken nvarchar(10),
     NewCode nchar(3),
     NewName nvarchar(50),
     NewDate datetime
    );
GO
ALTER PROCEDURE dbo.InsertUnitMeasure
    @UnitMeasureCode nchar(3),
    @Name nvarchar(25)
AS 
BEGIN
    SET NOCOUNT ON;

    MERGE Production.UnitMeasure AS target
    USING (SELECT @UnitMeasureCode, @Name) AS source (UnitMeasureCode, Name)
    ON (target.UnitMeasureCode = source.UnitMeasureCode)
    WHEN MATCHED THEN 
        UPDATE SET Name = source.Name
	WHEN NOT MATCHED THEN	
	    INSERT (UnitMeasureCode, Name)
	    VALUES (source.UnitMeasureCode, source.Name)
	    OUTPUT deleted.*, $action, inserted.* INTO #MyTempTable;
END;
GO
-- Test the procedure and return the results.
EXEC InsertUnitMeasure @UnitMeasureCode = 'ABC', @Name = 'New Test Value';
EXEC InsertUnitMeasure @UnitMeasureCode = 'XYZ', @Name = 'Test Value';
EXEC InsertUnitMeasure @UnitMeasureCode = 'ABC', @Name = 'Another Test Value';

SELECT * FROM #MyTempTable;
-- Cleanup 
DELETE FROM Production.UnitMeasure WHERE UnitMeasureCode IN ('ABC','XYZ');
DROP TABLE #MyTempTable;
GO


