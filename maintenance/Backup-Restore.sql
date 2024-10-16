BACKUP DATABASE AdventureWorks2022   
   TO DISK = '\\BackupSystem\BackupDisk1\AW_backups\AdventureWorksData.Bak';  
GO

RESTORE DATABASE AdventureWorks2022   
   FROM DISK = 'Z:\SQLServerBackups\AdventureWorks2022.bak';   
