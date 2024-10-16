SET NOCOUNT ON;

IF 1=0
BEGIN 
    DECLARE @SQL NVARCHAR(255)
    DECLARE @NumberofIntType int
    DECLARE @RowCount int

    -- get the number of items
    SET @NumberofIntType = (SELECT count(*) FROM INFORMATION_SCHEMA.ROUTINES)
    SET @RowCount = 0           -- set the first row to 0

    -- loop through the records 
    -- loop until the rowcount = number of records in your table
    WHILE @RowCount <= @NumberofIntType
    BEGIN
        -- do your process here
        SELECT top 1 @SQL = 'drop procedure '+ ROUTINE_SCHEMA +'.'+ ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES
        PRINT @SQL
        EXEC @SQL
        SET @RowCount = @RowCount + 1
    END
END
GO
-- USING CURSOR

DECLARE @NAME nVARCHAR(255)

DECLARE MY_CURSOR CURSOR 
  LOCAL STATIC READ_ONLY FORWARD_ONLY
FOR 
SELECT 'DROP PROCEDURE '+ ROUTINE_SCHEMA +'.'+ ROUTINE_NAME 
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_SCHEMA not in ('utility', 'dbo') 
ORDER BY ROUTINE_SCHEMA, ROUTINE_NAME 

OPEN MY_CURSOR
FETCH NEXT FROM MY_CURSOR INTO @NAME
WHILE @@FETCH_STATUS = 0
BEGIN 
    --Do something with Id here
    PRINT @NAME
    EXEC sp_executesql @NAME
    FETCH NEXT FROM MY_CURSOR INTO @NAME
END
CLOSE MY_CURSOR
DEALLOCATE MY_CURSOR
GO


IF 1=0
BEGIN 
    select * from INFORMATION_SCHEMA.ROUTINES
    select * from INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'FUNCTION'
    select * from INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE'

    select count(*) as total FROM INFORMATION_SCHEMA.ROUTINES -- 2884
        WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_SCHEMA not in ('utility', 'dbo') 
        --2639
END
