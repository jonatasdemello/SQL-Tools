
select * from INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_SCHEMA = 'family'order by SPECIFIC_NAME

SELECT 'DROP PROCEDURE [' + SCHEMA_NAME(p.schema_id) + '].[' + p.NAME + '];'
FROM sys.procedures p 

SELECT 'PROCEDURE [' + SCHEMA_NAME(p.schema_id) + '].[' + p.NAME + '];', *
FROM sys.procedures p 

go

DECLARE @sql VARCHAR(MAX)
SET @sql=''
SELECT @sql=@sql+'DROP PROCEDURE [' + SCHEMA_NAME(p.schema_id) + '].[' + p.NAME + '];'
FROM sys.procedures p 
exec(@sql)

GO

DECLARE @sql VARCHAR(MAX)
SET @sql=''
SELECT @sql=@sql+'drop procedure ['+name +'];' FROM sys.objects
WHERE type = 'p' AND  is_ms_shipped = 0
exec(@sql);

SELECT 'drop procedure ['+name +'];' FROM sys.objects
WHERE type = 'p' AND  is_ms_shipped = 0

GO

declare @procName varchar(500)
declare cur cursor 

for select [name] from sys.objects where type = 'p'
open cur
fetch next from cur into @procName
while @@fetch_status = 0
begin
    exec('drop procedure [' + @procName + ']')
    fetch next from cur into @procName
end
close cur
deallocate cur

go


create Procedure [dbo].[DeleteAllProcedures]
As 
declare @schemaName varchar(500)    
declare @procName varchar(500)
declare cur cursor
for select s.Name, p.Name from sys.procedures p
INNER JOIN sys.schemas s ON p.schema_id = s.schema_id
WHERE p.type = 'P' and is_ms_shipped = 0 and p.name not like 'sp[_]%diagram%'
ORDER BY s.Name, p.Name
open cur

fetch next from cur into @schemaName,@procName
while @@fetch_status = 0
begin
if @procName <> 'DeleteAllProcedures'
exec('drop procedure ' + @schemaName + '.' + @procName)
fetch next from cur into @schemaName,@procName
end
close cur
deallocate cur
