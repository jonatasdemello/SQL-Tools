use cc3_Debug

select [dbo].[udf_GetDbInstanceName]();

/*
SQL Server Logins

SQL Server Logins (Native SQL Logins or Windows Accounts) are stored in the master database and have a unique SID assigned to each SQL Login. You can retrieve a list of SQL Server logins when you query the system catalog view sys.server_principals.

select * from sys.server_principals where name = 'qa'

You will receive a list of SQL Server logins for your SQL Server instance.
Note: These are the SQL Server Logins and not the database users.

Database Users

Database Users can be queried by querying the system catalog view sys.database_principles of each user database by issuing the following query:

USE [<your_db>]
GO
SELECT * FROM sys.database_principals where name = 'qa'

You will receive a list of database users that have database privileges assigned to them.
Note: These are the Database Users and not SQL Server Logins.

Normal Behaviour

When you create a database and assign a "user" to the database with certain privileges you are in fact doing the following (partly in the background):

    Creating SQL Server Login with password (sys.server_principal)
    Creating a database user in the database (sys.database_principal)
    Granting permissions to the database user (in various tables, depending on the privileges)

In this case the SID of the SQL Login (sys.server_principal) will match the SID of the database user (sys.database_principal).
Restore Behaviour

When you restore a database from a source SQL Server the database users (Native SQL Server Logins and local Windows Accounts only) in the source database will have different SIDs than the SQL Server Logins on the target server. This is because the SID is unique for the source and target Native SQL Server Login or Local Windows Account.

The SQL Server Logins that are based on Windows Domain Accounts will always have the same SID, because SQL Server will retrieve these values from Active Directory.

When you restore the database from the source to the target SQL Server the SIDs of the Native SQL Server Logins will be mismatched,
even though a user might be listed in the sys.server_principals system management catalog of the SQL Server instance and in the sys.database_principals system management catalog of the restored database.


Solution

To rectify this and allow you to navigate the "SQL Server Login | permissions" and/or the "Database Properties | Permissions"
you can relink these orphaned database users to the SQL Server Login.

Switch to your user database and query the orphaned database users:

USE [your_db]
GO
sp_change_users_login 'Report'

If a user is reported as orphaned you can relink the SQL Server Login with the Database User by issuing the following command:

USE [your_db]
GO
sp_change_users_lgoin 'Update_one', '<database_user>', '<sql_server_login>'

This will relink the (Native) SQL Server Login (sys.server_principal) on your target instance, with the Database User (sys.database_principal) of the restored database.
Alternative

Seeing as sp_change_users_login is deprecated, you could achieve the same with the ALTER USER statement:

USE [<your_db>]
GO
ALTER USER <database_user>
    WITH LOGIN = <sql_server_login>

In some cases

...when you receive a database backup from a client, you might not have a corresponding SQL Server Login to link to the Database User.
In that case you can create a SQL Server Login without assigning permissions to the restored database and then link the newly
create SQL Server Login with the Database User with the above mentioned statements.

*/

-- SQL Server Logins
select * from sys.server_principals where name = 'qa'

-- Database Users
SELECT * FROM sys.database_principals where name = 'qa'

sp_change_users_login 'Report'

--exec sp_change_users_login 'Auto_Fix'

sp_change_users_login 'Update_One', 'qa', 'qa'
sp_change_users_login 'Update_One', 'User', 'User'

sp_change_users_login 'Update_One', 'reports', 'reports'

sp_change_users_login [ @Action = ] 'action'
    [ , [ @UserNamePattern = ] 'user' ]
    [ , [ @LoginName = ] 'login' ]
    [ , [ @Password = ] 'password' ]
