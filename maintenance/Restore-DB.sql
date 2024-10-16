RESTORE DATABASE Local_DB_dev_20210504
FROM DISK = 'C:\backup\Local_DB_dev-Wednesday.bak'
WITH MOVE 'Local_DB_test' TO 'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\Local_DB_dev_20210504.mdf',
     MOVE 'Local_DB_test_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\Local_DB_dev_log_20210504.ldf'

UPDATE ua 
SET ua.Active = ua2.Active 
FROM dbo.UserAccountUserType ua 
INNER JOIN Local_DB_dev_20210504.dbo.UserAccountUserType ua2 
	ON (ua2.UserAccountId = ua.UserAccountId AND ua2.UserTypeId = ua.UserTypeId)
WHERE ua.Active != ua2.Active; 
GO
