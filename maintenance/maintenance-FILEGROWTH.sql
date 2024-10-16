-- Review the Files that need Changes and Get Their File Names
SELECT d.name as database_name,
    mf.name as file_name,
    mf.type_desc as file_type,
    mf.growth as current_percent_growth
FROM sys.master_files mf (NOLOCK)
JOIN sys.databases d (NOLOCK) on mf.database_id=d.database_id
WHERE is_percent_growth=1
GO

-- Sample TSQL to Grow Your Files

/* Sets data file growth to 256MB increments, log file growth to 128MB increments. No max file size specified for either file. */

USE [master];
GO
ALTER DATABASE SampleDB MODIFY FILE (NAME='sampledb_data', FILEGROWTH = 256MB);
ALTER DATABASE SampleDB MODIFY FILE (NAME='sampledb_log', FILEGROWTH = 128MB);
GO

ALTER DATABASE master MODIFY FILE (NAME='master', FILEGROWTH = 256MB);
ALTER DATABASE master MODIFY FILE (NAME='mastlog', FILEGROWTH = 128MB);
ALTER DATABASE model MODIFY FILE (NAME='modellog', FILEGROWTH = 128MB);
ALTER DATABASE msdb MODIFY FILE (NAME='MSDBData', FILEGROWTH = 256MB);
ALTER DATABASE msdb MODIFY FILE (NAME='MSDBLog', FILEGROWTH = 128MB);

ALTER DATABASE jenkins_cms_pullrequest MODIFY FILE (NAME='jenkins_cms_pullrequest', FILEGROWTH = 256MB);
ALTER DATABASE jenkins_cms_pullrequest MODIFY FILE (NAME='jenkins_cms_pullrequest_log', FILEGROWTH = 128MB);
ALTER DATABASE DataIntegration MODIFY FILE (NAME='DataIntegration', FILEGROWTH = 256MB);
ALTER DATABASE DataIntegration MODIFY FILE (NAME='DataIntegration_log', FILEGROWTH = 128MB);
ALTER DATABASE octopus MODIFY FILE (NAME='octopus_log', FILEGROWTH = 128MB);
ALTER DATABASE jenkins_cms_test MODIFY FILE (NAME='jenkins_cms_test', FILEGROWTH = 256MB);
ALTER DATABASE jenkins_cms_test MODIFY FILE (NAME='jenkins_cms_test_log', FILEGROWTH = 128MB);
ALTER DATABASE BOG MODIFY FILE (NAME='BOG_log', FILEGROWTH = 128MB);
ALTER DATABASE ProGet MODIFY FILE (NAME='ProGet_log', FILEGROWTH = 128MB);
ALTER DATABASE kraken MODIFY FILE (NAME='kraken_log', FILEGROWTH = 128MB);
