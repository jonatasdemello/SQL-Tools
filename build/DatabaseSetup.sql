SET NOCOUNT ON;
:setvar databasename "CC3"

USE [master]
GO

sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
sp_configure 'clr enabled', 1
GO
RECONFIGURE
GO

-- If the database already exists, we need to drop any active user connections and then we can drop the database itself.
IF EXISTS(SELECT *
		  FROM sys.databases
		  WHERE [name] = '$(databasename)')
BEGIN
	ALTER DATABASE $(databasename) SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE $(databasename)
END
GO

-- Create database in the default file locations.
CREATE DATABASE $(databasename)
GO


ALTER DATABASE $(databasename) MODIFY FILE(NAME = N'$(databasename)', SIZE = 100MB, MAXSIZE = UNLIMITED, FILEGROWTH = 10%)
ALTER DATABASE $(databasename) MODIFY FILE(NAME = N'$(databasename)_log', SIZE = 25MB, MAXSIZE = UNLIMITED, FILEGROWTH = 10%)
GO

ALTER DATABASE $(databasename) SET allow_snapshot_isolation ON
ALTER DATABASE $(databasename) SET read_committed_snapshot ON
GO

USE [$(databasename)]
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
BEGIN
	EXEC [dbo].[sp_fulltext_database] @action = 'enable'
END
GO
EXEC dbo.sp_changedbowner @loginame = N'sa', @map = false 
GO
ALTER DATABASE [$(databasename)] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [$(databasename)] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [$(databasename)] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [$(databasename)] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [$(databasename)] SET ARITHABORT OFF 
GO

ALTER DATABASE [$(databasename)] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [$(databasename)] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [$(databasename)] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [$(databasename)] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [$(databasename)] SET CURSOR_DEFAULT GLOBAL 
GO

ALTER DATABASE [$(databasename)] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [$(databasename)] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [$(databasename)] SET QUOTED_IDENTIFIER ON 
GO

ALTER DATABASE [$(databasename)] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [$(databasename)] SET  DISABLE_BROKER 
GO

ALTER DATABASE [$(databasename)] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [$(databasename)] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [$(databasename)] SET TRUSTWORTHY ON 
GO

EXEC dbo.sp_changedbowner @loginame = N'sa', @map = false
GO

ALTER DATABASE [$(databasename)] SET ALLOW_SNAPSHOT_ISOLATION ON
GO

ALTER DATABASE [$(databasename)] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [$(databasename)] SET READ_COMMITTED_SNAPSHOT ON 
GO

ALTER DATABASE [$(databasename)] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [$(databasename)] SET RECOVERY SIMPLE 
GO

ALTER DATABASE [$(databasename)] SET  MULTI_USER 
GO

ALTER DATABASE [$(databasename)] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [$(databasename)] SET DB_CHAINING OFF 
GO

ALTER DATABASE [$(databasename)] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [$(databasename)] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO

ALTER DATABASE [$(databasename)] SET DELAYED_DURABILITY = DISABLED 
GO

ALTER DATABASE [$(databasename)] SET READ_WRITE 
GO



