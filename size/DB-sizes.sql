select name from sys.databases where name like '%cc3%'

use [xots-dev-cc3-db]
SELECT
    DB_NAME() AS [database_name],
    CONCAT(CAST(SUM( CAST( (size * 8.0/1024) AS DECIMAL(15,2) ) ) AS VARCHAR(20)),' MB') AS [database_size_MB],
	CONCAT(CAST(SUM( CAST( (size * 8.0/1024/1024) AS DECIMAL(15,2) ) ) AS VARCHAR(20)),' GB') AS [database_size_GB]
FROM sys.database_files;


use [xots-test-cc3-db]
SELECT
    DB_NAME() AS [database_name],
    CONCAT(CAST(SUM( CAST( (size * 8.0/1024) AS DECIMAL(15,2) ) ) AS VARCHAR(20)),' MB') AS [database_size_MB],
	CONCAT(CAST(SUM( CAST( (size * 8.0/1024/1024) AS DECIMAL(15,2) ) ) AS VARCHAR(20)),' GB') AS [database_size_GB]
FROM sys.database_files;


use [xots-uat-cc3-db]
SELECT
    DB_NAME() AS [database_name],
    CONCAT(CAST(SUM( CAST( (size * 8.0/1024) AS DECIMAL(15,2) ) ) AS VARCHAR(20)),' MB') AS [database_size_MB],
	CONCAT(CAST(SUM( CAST( (size * 8.0/1024/1024) AS DECIMAL(15,2) ) ) AS VARCHAR(20)),' GB') AS [database_size_GB]
FROM sys.database_files;

/*
xots-dev-cc3-db	15779.94 MB	15.41 GB
xots-test-cc3-db	19478.63 MB	19.02 GB
xots-uat-cc3-db	18058.38 MB	17.63 GB
*/
