-- https://docs.microsoft.com/en-us/sql/relational-databases/policy-based-management/disable-lightweight-pooling?view=sql-server-2017
sp_configure 'show advanced options', 1;  
GO  
sp_configure 'lightweight pooling', 0;  
GO  
RECONFIGURE;  
GO  