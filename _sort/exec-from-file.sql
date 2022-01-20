-- On
SET NOCOUNT ON  
EXEC master.dbo.sp_configure 'show advanced options', 1 
RECONFIGURE 
EXEC master.dbo.sp_configure 'xp_cmdshell', 1 
RECONFIGURE 

-- Off
EXEC master.dbo.sp_configure 'xp_cmdshell', 0 
RECONFIGURE 
EXEC master.dbo.sp_configure 'show advanced options', 0 
RECONFIGURE  
SET NOCOUNT OFF 

EXEC xp_cmdshell  'sqlcmd -S ' + @DBServerName + ' -d  ' + @DBName + ' -i ' + @FilePathName


-- Or just use openrowset to read your script into a variable and execute it 
DECLARE @SQL varchar(MAX)
SELECT @SQL = BulkColumn
FROM OPENROWSET ( BULK 'MeinPfad\MeinSkript.sql' ,   SINGLE_BLOB ) AS MYTABLE
--PRINT @sql
EXEC (@sql)




-- recreate table
DECLARE @SQL varchar(MAX)
SELECT @SQL = BulkColumn
	FROM OPENROWSET ( BULK '..\Tables\Family_EmailLog.sql' , SINGLE_BLOB ) AS MYTABLE
--PRINT @sql
EXEC (@sql)

