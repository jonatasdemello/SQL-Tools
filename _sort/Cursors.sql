
DECLARE @TabName varchar(100)

CREATE TABLE #temp (
   TabName varchar(200), IndexName varchar(200), IndexDescr varchar(200), 
   IndexKeys varchar(200), IndexSize int
)

DECLARE cur CURSOR FAST_FORWARD LOCAL FOR
    SELECT name FROM sysobjects WHERE xtype = 'U'

OPEN cur

FETCH NEXT FROM cur INTO @TabName
WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO #temp (IndexName, IndexDescr, IndexKeys)
        EXEC sp_helpindex @TabName

        UPDATE #temp SET TabName = @TabName WHERE TabName IS NULL

        FETCH NEXT FROM cur INTO @TabName
    END

CLOSE cur
DEALLOCATE cur



/****** Cursor Sample ********/

DECLARE @schemaName VARCHAR(30)
    , @procName VARCHAR(30)
    , @fullName VARCHAR(60)

-- Cursor para percorrer os nomes dos objetos 
DECLARE cursor_objects CURSOR FOR
    SELECT
          ROUTINE_SCHEMA
        , ROUTINE_NAME
    FROM
        INFORMATION_SCHEMA.ROUTINES
    WHERE
        ROUTINE_TYPE = 'PROCEDURE'

-- Abrindo Cursor para leitura
OPEN cursor_objects

-- Lendo a próxima linha
FETCH NEXT FROM cursor_objects INTO @schemaName, @procName

-- Percorrendo linhas do cursor (enquanto houverem)
WHILE @@FETCH_STATUS = 0
BEGIN

    SELECT @fullName = @schemaName + '.' + @procName

    EXEC sp_helptext @fullName

    -- Lendo a próxima linha
    FETCH NEXT FROM cursor_objects INTO @schemaName, @procName
END

-- Fechando Cursor para leitura
CLOSE cursor_objects

-- Desalocando o cursor
DEALLOCATE cursor_objects 



