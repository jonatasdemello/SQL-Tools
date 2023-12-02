-- Update logical Name

SELECT file_id, name as [logical_file_name],physical_name from sys.database_files

USE [master];
GO
ALTER DATABASE CMS_dev MODIFY FILE ( NAME = CC3_CMS, NEWNAME = CMS_dev );
ALTER DATABASE CMS_dev MODIFY FILE ( NAME = CC3_CMS_log, NEWNAME = CMS_dev_log );
GO

use CMS_dev;
SELECT file_id, name as [logical_file_name],physical_name from sys.database_files


-------------------------------------------------------------------------------------------------------------------------------

CREATE DATABASE [Manvendra]
	CONTAINMENT = NONE
	ON  PRIMARY
	( NAME = N'Manvendra', FILENAME = N'C:\MSSQL\DATA\Manvendra.mdf',SIZE = 5MB , MAXSIZE = UNLIMITED, FILEGROWTH = 10MB ),
	( NAME = N'Manvendra_1', FILENAME = N'C:\MSSQL\DATA\Manvendra_1.ndf',SIZE = 5MB , MAXSIZE = UNLIMITED, FILEGROWTH = 10MB ),
	( NAME = N'Manvendra_2', FILENAME = N'C:\MSSQL\DATA\Manvendra_2.ndf' ,SIZE = 5MB , MAXSIZE = UNLIMITED, FILEGROWTH = 10MB )
	LOG ON
	( NAME = N'Manvendra_log', FILENAME = N'C:\MSSQL\DATA\Manvendra_log.ldf',SIZE = 10MB , MAXSIZE = 1GB , FILEGROWTH = 10%)
GO

BACKUP DATABASE [Manvendra] TO DISK = 'C:\MSSQL\Backup\Manvendra.bak'
GO

RESTORE DATABASE [Manvendra_Test] FROM DISK = 'C:\MSSQL\Backup\Manvendra.bak'
GO

USE MANVENDRA
GO
SELECT file_id, name as [logical_file_name],physical_name from sys.database_files

USE MANVENDRA_Test
GO
SELECT file_id, name as [logical_file_name],physical_name from sys.database_files

USE [master];
GO
ALTER DATABASE [Manvendra] MODIFY FILE ( NAME = Manvendra, NEWNAME = Manvendra_Data );
GO

USE [Manvendra];
GO
SELECT file_id, name AS logical_name, physical_name FROM sys.database_files


USE [master];
GO
ALTER DATABASE [Manvendra] MODIFY FILE ( NAME = Manvendra_Data, NEWNAME = Manvendra );
GO
ALTER DATABASE [Manvendra] MODIFY FILE ( NAME = Manvendra_1, NEWNAME = Manvendra_Data1 );
GO
ALTER DATABASE [Manvendra] MODIFY FILE ( NAME = Manvendra_2, NEWNAME = Manvendra_Data2 );
GO
ALTER DATABASE [Manvendra] MODIFY FILE ( NAME = Manvendra_Log, NEWNAME = Manvendra_Log1 );
GO

