

select * from sys.databases

select name, SUSER_NAME(owner_sid) from sys.databases order by name

drop database tmp_jm_Local_DB

-- onwer_sid
-- 0x0105000000000005150000004CDE928ED09F06F2099660225F0D0000

use master

DROP Login 'domain\jonatas.demello'

select * from sys.syslogins where name like '%jonatas%'

select * from sys.sql_logins

select SUSER_SID('domain\jonatas.demello')

SELECT name,* FROM msdb..sysjobs WHERE owner_sid = SUSER_SID('domain\jonatas.demello')

-- create user
USE [master]
GO
-- domain\jonatas.demello

CREATE LOGIN [domain\jonatasd] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO

ALTER SERVER ROLE [sysadmin] ADD MEMBER [domain\jonatas.demello]
GO


