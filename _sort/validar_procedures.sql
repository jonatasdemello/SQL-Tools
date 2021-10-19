
/******************************************
	validar todas as procedures
*******************************************/


-- table variable to store procedure names
DECLARE @v TABLE (RecID INT IDENTITY(1,1), spname sysname)
-- retrieve the list of stored proceduresI
NSERT INTO @v(spname)
    SELECT         '[' + s.[name] + '].[' + sp.name + ']'
     FROM sys.procedures sp    
    INNER JOIN sys.schemas s ON s.schema_id = sp.schema_id
    WHERE is_ms_shipped = 0
-- counter variables
DECLARE @cnt INT, @Tot INT
SELECT @cnt = 1
SELECT @Tot = COUNT(*) FROM @v
DECLARE @spname sysname
-- start the loop
WHILE @Cnt <= @Tot BEGIN
    SELECT @spname = spname
        FROM @v
        WHERE RecID = @Cnt
    PRINT 'refreshing...' + @spname
    BEGIN TRY
        -- refresh the stored procedure
        EXEC sp_refreshsqlmodule @spname
    END TRY
    BEGIN CATCH
        PRINT 'Validation failed for : ' +
             @spname + ', Error:' +
             ERROR_MESSAGE()
    END CATCH
    SET @Cnt = @cnt + 1
END

/*
The first part of the code inserted the names of all stored procedures to a table variable, along with their schema names. A table variable is used just to avoid a cursor. The WHILE loop then reads each stored procedure name and passes it to the system stored procedure: sp_refreshsqlmodule. sp_refreshsqlmodule  validates the stored procedure and will throw an error if the validation fails. The CATCH block catches the error if the validation fails, and displays the error message in the output window.
*/
