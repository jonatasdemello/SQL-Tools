
-- Create Case Sensitive Database
CREATE DATABASE CaseSensitive 
COLLATE SQL_Latin1_General_CP1_CS_AS
GO
USE CaseSensitive
GO
SELECT *
FROM sys.types
GO
-- Create Case In-Sensitive Database
CREATE DATABASE CaseInSensitive 
COLLATE SQL_Latin1_General_CP1_CI_AS
GO
USE CaseInSensitive
GO
SELECT *
FROM sys.types
GO

