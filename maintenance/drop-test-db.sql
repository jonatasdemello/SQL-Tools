SELECT * FROM sys.sql_logins

SELECT * FROM sys.servers

EXEC sp_testlinkedserver [127.0.0.1];



--select @@VERSION

use master

-- select 'drop database ', [name] from sys.databases where [name] like 'TEST_%'

DECLARE @SQL VARCHAR(1000);
if exists(select top 1 [name] from sys.databases where [name] like 'TEST_%')
BEGIN

    WHILE exists(select top 1 [name] from sys.databases where [name] like 'TEST_%')
    BEGIN
    select top 1 @sql = 'drop database ' + [name] from sys.databases where [name] like 'TEST_%';
    --exec @SQL;
    print @SQL;
    END
END


-------------------------------------------------------------------------------------------------------------------------------
SELECT TOP (10) [name] FROM sys.databases

USE CC3_docker;


SELECT * FROM sys.servers

SELECT * FROM sys.sql_logins

select * from INFORMATION_SCHEMA.TABLES order by TABLE_NAME

-- linked server
SELECT TOP (10) * FROM dataservices.SchoolMapping
SELECT TOP (10) * FROM dataservices.School

SELECT TOP (10) * FROM  [127.0.0.1].DataIntegration_dev.dbo.SchoolMapping

-- both work!


