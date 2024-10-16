SET NOCOUNT ON;

USE [master]

select * from master.sys.databases order by name

select * from master.sys.databases where name like 'TEST%'

drop database IF EXISTS TEST_33a75786e31f4f4e9a9c868ce5f2ab5a


GO

SELECT @@VERSION

sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'clr enabled', 1;
GO
RECONFIGURE;
GO

select @@VERSION


-- change
-- sp_configure 'clr enabled', 1;

-- show
sp_configure 'clr enabled'

--show all
exec sp_configure

-- show one config
exec sp_configure 'show advanced options'


-- sp_configure Configs

-- get value
SELECT * FROM sys.configurations order by name

SELECT * FROM sys.configurations WHERE [name] = N'show advanced options'

SELECT [value] FROM sys.configurations WHERE [name] = N'show advanced options'

SELECT [value] FROM sys.configurations WHERE [name] = N'show advanced options' and [value] = 1
SELECT [value] FROM sys.configurations WHERE [name] = N'show advanced options' and [value] = 0


SELECT * FROM sys.configurations where name = 'clr enabled'
SELECT [value] FROM sys.configurations WHERE [name] = N'clr enabled' and [value] = 1

SELECT * FROM sys.configurations where name = 'clr strict security'
SELECT [value] FROM sys.configurations WHERE [name] = N'clr strict security' and [value] = 1


-- settings for : ALTER DATABASE [$(databasename)] SET QUOTED_IDENTIFIER ON

select top 100 * from sys.databases order by name

select top 100 * from sys.databases where name = 'migrated_Local_DB_dev'
select top 100 * from sys.databases where name = 'xots-dev-cc3-db'

drop database [TEST_12345]


-- ALTER DATABASE [$(databasename)] SET TRUSTWORTHY ON
select top 100 name, is_trustworthy_on from sys.databases order by name


--ALTER DATABASE [$(databasename)] SET QUOTED_IDENTIFIER ON
select is_quoted_identifier_on from sys.databases where name = 'Local_DB' AND is_quoted_identifier_on = 1
GO

--ALTER DATABASE [$(databasename)] SET ALLOW_SNAPSHOT_ISOLATION ON
select snapshot_isolation_state from sys.databases where name = 'Local_DB' AND snapshot_isolation_state = 1
GO

--ALTER DATABASE [$(databasename)] SET READ_COMMITTED_SNAPSHOT ON
select is_read_committed_snapshot_on from sys.databases where name = 'Local_DB' AND is_read_committed_snapshot_on = 1
GO

SELECT 'Windows' WHERE @@Version LIKE '%windows%'
select is_trustworthy_on from sys.databases where name = 'Local_DB' AND is_trustworthy_on = 1




-- Check DB owner
SELECT name, suser_sname( owner_sid ) AS DBOwnerName FROM master.sys.databases;

SELECT name, suser_sname( owner_sid ) AS DBOwnerName FROM master.sys.databases where suser_sname( owner_sid ) != 'sa'



-------------------------------------------------------------------------------------------------------------------------------
-- linked servers
SELECT * FROM sys.servers WHERE name = '127.0.0.1'
SELECT * FROM sys.servers WHERE name = 'xots-hub-sql-mi'

(SELECT 'Windows' WHERE @@Version LIKE '%windows%')
(SELECT 'Azure' WHERE @@Version LIKE '%Azure%')

SELECT name, compatibility_level FROM sys.databases;

select SERVERPROPERTY('ProductMajorVersion')



--linked servers

exec sp_dropserver @server=N'xots-hub-sql-mi', @droplogins = 'droplogins'

exec sp_linkedservers

	-- Create Azure SQL Managed Instance linked server
	EXEC master.dbo.sp_addlinkedserver
		@server = N'xots-hub-sql-mi',
		@srvproduct = N'',
		@provider = N'MSOLEDBSQL', --SQLNCLI
		@datasrc = N'xots-hub-sql-mi.a00b7c186c52.database.windows.net',
		@location = N'',
		@provstr = N'',
		@catalog = NULL;

-------------------------------------------------------------------------------------------------------------------------------
-- test timezone

select dbo.udf_ConvertTimeZone ('2023-12-01 00:00:00', 'UTC', 'Eastern Standard Time' ) --'2023-11-30 19:00:00'

select dbo.udf_ConvertTimeZone ('2023-12-01 00:00:00', 'UTC', 'Eastern Standard Time' ) --'2023-11-30 19:00:00'

    -- @datetime DATETIME,
	-- @source_time_zone NVARCHAR(255),
	-- @destination_time_zone NVARCHAR(255)


SELECT  dbo.udf_ConvertAtTimeZone('2023-12-21 18:17:57', NULL, 'Pacific Standard Time'), 'NULL as @source_time_zone'
SELECT  dbo.udf_ConvertTimeZone('2023-12-21 18:17:57', NULL, 'Pacific Standard Time')


SELECT dbo.udf_ConvertTimeZone('2023-12-21 18:17:57', NULL, 'Pacific Standard Time'), 'NULL as @source_time_zone'
union all
SELECT dbo.udf_ConvertTimeZone ('2023-12-21 18:17:57', 'UTC', 'Pacific Standard Time' ), 'UTC as @source_time_zone'
union all
SELECT dbo.udf_ConvertTimeZoneCLR('2023-12-21 18:17:57', NULL, 'Pacific Standard Time'), 'CLR, NULL as @source_time_zone'

go
CREATE FUNCTION dbo.udf_ConvertTimeZoneCLR
(
	@datetime DATETIME,
	@source_time_zone NVARCHAR(255),
	@destination_time_zone NVARCHAR(255) 
)
RETURNS DATETIME
AS
	EXTERNAL NAME TimeZoneInfo.UserDefinedFunctions.convert_timezone;
GO

-------------------------------------------------------------------------------------------------------------------------------



-- Assemblies
exec sys.sp_add_trusted_assembly
exec sys.sp_drop_trusted_assembly

SELECT TOP (100) * FROM sys.trusted_assemblies
SELECT TOP (100) * FROM sys.assembly_files

DECLARE @Hash BINARY(64),
        @ClrName NVARCHAR(4000),
        @AssemblySize INT,
        @MvID UNIQUEIDENTIFIER;

SELECT  @Hash = HASHBYTES(N'SHA2_512', af.[content]),
        @ClrName = CONVERT(NVARCHAR(4000), ASSEMBLYPROPERTY(af.[name],
                N'CLRName')),
        @AssemblySize = DATALENGTH(af.[content]),
        @MvID = CONVERT(UNIQUEIDENTIFIER, ASSEMBLYPROPERTY(af.[name], N'MvID'))
FROM    sys.assembly_files af
WHERE   af.[name] = N'SQL2017_NeedsModuleSigning'
AND     af.[file_id] = 1;

SELECT  @ClrName, @AssemblySize, @MvID, @Hash;

-- EXEC sys.sp_add_trusted_assembly @Hash, @ClrName;
GO



-------------------------------------------------------------------------------------------------------------------------------
select top 10 * from dbo.useraccount

-- $2a$04$DoEIsEuxlPYVSjUyrCTMMO6DdOxNYW3vy83OfrBAy0ZGuZ0PC6HAi

-- CREATE FUNCTION [dbo].[BCrypt](@password [nvarchar](4000), @rounds [int])
--	RETURNS [nvarchar](4000) WITH EXECUTE AS CALLER
-- CREATE FUNCTION [dbo].[CheckPassword](@password [nvarchar](4000), @hashed [nvarchar](4000))
--	RETURNS [bit] WITH EXECUTE AS CALLER

DECLARE @Password NVARCHAR(4000)
DECLARE @oldPassword NVARCHAR(4000)
DECLARE @newPassword NVARCHAR(4000)

SET @Password = N'P@ssw0rd'
SET @newPassword= dbo.BCrypt(@Password, 4)
SET @oldPassword= dbo.BCrypt(@Password, 10)


SELECT dbo.CheckPassword(@Password, @newPassword)
SELECT dbo.CheckPassword(@Password, @oldPassword)

--select @newPassword, @oldPassword

-- $2<a/b/x/y>$[cost]$[22 character salt][31 character hash]

-- $2a$04$H/9YV5vWhMJbhG09aoZxde1mxggbjOAocW.C8TEZIGJirjRxlWb1C
-- $2a$04$T/qGn8vKpDn/XejoXn76KO4QTFhu9jokPh7sVleAdcGYm60ZyKBCO
-- $2a$04$KhblNglrmVU0jWG/3BOJ5Op2kj9Yn7CrWHVMGhYIIt2kYGOT3O2CS
-- $2a$04$Q0.L12.Fy6YV3UsPHYkFhuOlxuDm6SmrSnzZCYYtUY4lx3jCmGdn6


SELECT dbo.CheckPassword('test', '$2a$04$H/9YV5vWhMJbhG09aoZxde1mxggbjOAocW.C8TEZIGJirjRxlWb1C')


select HASHBYTES ('SHA2_256', N'seesaw')

select HASHBYTES ('bcrypt', N'seesaw')

DECLARE @HashThis NVARCHAR(32);
SET @HashThis = CONVERT(NVARCHAR(32),'dslfdkjLK85kldhnv$n000#knf');
SELECT HASHBYTES('SHA2_256', @HashThis);

/*
Bcrypt

https://github.com/CareerCruising/Xello.Common/blob/e3e817a2a1fd0013b8b211c116c76a56feabb18c/Xello.Common.Hashing/Hash.cs
https://github.com/BcryptNet/bcrypt.net/tree/main
https://en.wikipedia.org/wiki/Bcrypt

$2<a/b/x/y>$[cost]$[22 character salt][31 character hash]
$2a$12$R9h/cIPz0gi.URNNX3kh2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUW
\__/\/ \____________________/\_____________________________/
Alg Cost      Salt                        Hash


https://www.c-sharpcorner.com/article/assembly-in-ms-sql-server/

ALTER DATABASE (Transact-SQL) compatibility level
https://learn.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql-compatibility-level?view=azuresqldb-mi-current

SET Statements (Transact-SQL)
https://learn.microsoft.com/en-us/sql/t-sql/statements/set-statements-transact-sql?view=sql-server-ver16&viewFallbackFrom=azuresqldb-mi-current

ALTER DATABASE SET options (Transact-SQL) * SQL Managed Instance *
https://learn.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql-set-options?view=azuresqldb-mi-current

ALTER DATABASE SET options (Transact-SQL) * SQL Server *
https://learn.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql-set-options?view=sql-server-ver16

SET Options
https://learn.microsoft.com/en-us/previous-versions/sql/sql-server-2008-r2/ms190707(v=sql.105)?redirectedfrom=MSDN

sp_configure
https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-configure-transact-sql?view=sql-server-ver16

Server configuration options
https://learn.microsoft.com/en-us/sql/database-engine/configure-windows/server-configuration-options-sql-server?view=sql-server-ver16


https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-trusted-assemblies-transact-sql?view=sql-server-ver16
https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sys-sp-add-trusted-assembly-transact-sql?view=sql-server-ver16
https://learn.microsoft.com/en-us/sql/database-engine/configure-windows/clr-strict-security?view=sql-server-ver16
https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-configure-transact-sql?view=sql-server-ver16
https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-configure-time-zone?view=sql-server-ver16
https://learn.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/performance-guidelines-best-practices-checklist?view=azuresql

https://learn.microsoft.com/en-us/sql/t-sql/statements/create-login-transact-sql?view=azuresqldb-mi-current
https://straightpathsql.com/archives/2009/10/how-to-use-sp_configure-in-sql-server/

DATABASEPROPERTYEX (Transact-SQL)
https://learn.microsoft.com/en-us/sql/t-sql/functions/databasepropertyex-transact-sql?view=sql-server-ver16

sys.databases (Transact-SQL)
https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-databases-transact-sql?view=sql-server-ver16


https://stackoverflow.com/questions/44083098/clr-strict-security-on-sql-server-2017
https://stackoverflow.com/questions/41446819/signing-unsafe-assemblies-with-asymmetric-key

CLR strict security
https://learn.microsoft.com/en-us/sql/database-engine/configure-windows/clr-strict-security?view=sql-server-ver16


https://www.sqlservercentral.com/stairways/stairway-to-sqlclr

https://sqlquantumleap.com/2017/08/07/sqlclr-vs-sql-server-2017-part-1-clr-strict-security/
https://sqlquantumleap.com/2017/08/09/sqlclr-vs-sql-server-2017-part-2-clr-strict-security-solution-1/
https://sqlquantumleap.com/2017/08/16/sqlclr-vs-sql-server-2017-part-3-clr-strict-security-solution-2/
https://sqlquantumleap.com/2017/08/28/sqlclr-vs-sql-server-2017-part-4-trusted-assemblies-the-disappointment/
https://sqlquantumleap.com/2017/09/04/sqlclr-vs-sql-server-2017-part-5-trusted-assemblies-valid-use-cases/
https://sqlquantumleap.com/2017/09/29/sqlclr-vs-sql-server-2017-part-6-trusted-assemblies-cant-do-module-signing/
https://sqlquantumleap.com/2018/02/23/sqlclr-vs-sql-server-2012-2014-2016-part-7-clr-strict-security-the-problem-continues-in-the-past-wait-what/
https://sqlquantumleap.com/2018/08/09/sqlclr-vs-sql-server-2017-part-8-is-sqlclr-deprecated-in-favor-of-python-or-r-sp_execute_external_script/
https://sqlquantumleap.com/2018/10/30/sqlclr-vs-sql-server-2017-part-9-does-permission_set-still-matter-or-is-everything-now-unsafe/




BCrypt
https://github.com/BcryptNet/bcrypt.net

SQL
https://blog.tcs.de/using-the-bcrypt-hash-algorithm-in-ms-sql-server/

Hashbytes
https://www.sqlshack.com/the-hashbytes-function-in-t-sql/
https://blog.sqlauthority.com/2023/10/20/sql-server-best-practices-for-securely-storing-passwords/


https://learn.microsoft.com/en-us/sql/t-sql/functions/hashbytes-transact-sql?view=sql-server-ver16

https://learn.microsoft.com/en-us/sql/relational-databases/security/encryption/choose-an-encryption-algorithm?view=sql-server-ver16

SQL Server, including DES, Triple DES, TRIPLE_DES_3KEY, RC2, RC4, 128-bit RC4, DESX, 128-bit AES, 192-bit AES, and 256-bit AES.

Beginning with SQL Server 2016 (13.x), all algorithms other than AES_128, AES_192, and AES_256 are deprecated. To use older algorithms (not recommended), you must set the database to database compatibility level 120 or lower.


*/