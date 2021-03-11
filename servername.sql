-- ger server name

SELECT
 @@servername AS 'Server Name' -- The database server's machine name
,@@servicename AS 'Instance Name' -- e.g.: MSSQLSERVER
,DB_NAME() AS 'Database Name'
,HOST_NAME() AS 'Host Name' -- The database client's machine name

