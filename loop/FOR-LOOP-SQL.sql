-- FOR LOOP 

DECLARE @i int = 0

WHILE @i < 20
BEGIN
    SET @i = @i + 1
    /* do some work */
END

-------------------------------------------------------------------------------------------------------------------------------
DECLARE @cnt INT = 0;

WHILE @cnt < 10
BEGIN
   PRINT 'Inside FOR LOOP';
   SET @cnt = @cnt + 1;
END;

PRINT 'Done FOR LOOP';

-------------------------------------------------------------------------------------------------------------------------------
DECLARE @X INT=1;

WAY:  --> Here the  DO statement

  PRINT @X;

  SET @X += 1;

IF @X <= 10 GOTO WAY;


-------------------------------------------------------------------------------------------------------------------------------
-- WHILE :

DECLARE @a INT = 10

WHILE @a <= 20
BEGIN
    PRINT @a
    SET @a = @a + 1
END

-- GOTO :

DECLARE @a INT = 10
a:
PRINT @a
SET @a = @a + 1
IF @a < = 20
BEGIN
    GOTO a
END

-------------------------------------------------------------------------------------------------------------------------------

DECLARE @i INT = 0;
SELECT @count=  Count(*) FROM {TABLE}

WHILE @i <= @count
BEGIN
       
    SELECT * FROM {TABLE}
    ORDER BY {COLUMN}
    OFFSET @i ROWS   
    FETCH NEXT 1 ROWS ONLY  

    SET @i = @i + 1;

END

