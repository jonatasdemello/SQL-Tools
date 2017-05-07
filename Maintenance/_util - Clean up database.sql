
USE master
GO
EXEC sp_clean_db_free_space  @dbname = N'AdventureWorks2012' ;

truncate table table_name; dbcc checkident (table_name, reseed, 0); /* next ID will be 1 */ 


USE ServiceWeb_new

select * from sys.system_objects where name like 'sp_clean_db%'

sp_clean_db_free_space
sp_clean_db_file_free_space

/* SQL Server 2005, Clean your Database Records & reset Identity Columns, all in 6 lines! */


/*Disable Constraints & Triggers*/
exec sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
exec sp_MSforeachtable 'ALTER TABLE ? DISABLE TRIGGER ALL'

/*Perform delete operation on all table for cleanup*/
exec sp_MSforeachtable 'DELETE ?'

/*Enable Constraints & Triggers again*/
exec sp_MSforeachtable 'ALTER TABLE ? CHECK CONSTRAINT ALL'
exec sp_MSforeachtable 'ALTER TABLE ? ENABLE TRIGGER ALL'

/*Reset Identity on tables with identity column*/
exec sp_MSforeachtable 'IF OBJECTPROPERTY(OBJECT_ID(''?''), ''TableHasIdentity'') = 1 BEGIN DBCC CHECKIDENT (''?'',RESEED,0) END'

