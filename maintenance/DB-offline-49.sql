USE [master]
GO

ALTER DATABASE CC3 SET  OFFLINE

alter database migrated_Local_DB_dev set single_user with rollback immediate
ALTER DATABASE migrated_Local_DB_dev SET  OFFLINE

ALTER DATABASE [migrated_Local_DB_dev] SET  OFFLINE
ALTER DATABASE [migrated_Local_DB_test] SET  OFFLINE
ALTER DATABASE [migrated_Local_DB_uat] SET  OFFLINE
GO
ALTER DATABASE jenkins_cms_test SET  OFFLINE

ALTER DATABASE CMS_Dev_XillaBlueTemp SET  OFFLINE
ALTER DATABASE CMS_Dev_XillaTemp SET  OFFLINE

ALTER DATABASE feed_dev_20230113 SET  OFFLINE

ALTER DATABASE distribution SET  OFFLINE

select name, state_desc, create_date from sys.databases where state_desc='ONLINE' order by name

select name, state_desc, create_date from sys.databases where state_desc='ONLINE' order by name

select * from sys.databases where state_desc='OFFLINE' order by name

select * from sys.databases where state_desc='ONLINE' order by name


sp_who2

alter database tmp_CMS_Local_jm set single_user with rollback immediate
drop database tmp_CMS_Local_jm
