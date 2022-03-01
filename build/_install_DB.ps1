-------------------------------------------------------------------------------------------------------------------------------
Get-ExecutionPolicy -List
Set-executionpolicy -scope CurrentUser -executionPolicy Undefined
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope LocalMachine

#for the Invoke-Sqlcmd you need to Install the SQL Server PowerShell module

Get-Module SqlServer -ListAvailable

Install-Module -Name SqlServer

Install-Module -Name SqlServer -Scope CurrentUser

Install-Module -Name SqlServer -AllowClobber

-------------------------------------------------------------------------------------------------------------------------------


Invoke-Sqlcmd -ServerInstance ".\SQLEXPRESS" -Database "SQLCopTests" -Query "EXEC tsqlt.NewTestClass @ClassName = N'SQLCop'"

# -- To make this easier, I will execute each .sql file in my database with this short PoSh script

$FolderPath = Get-Location
foreach ($filename in Get-ChildItem -Path $FolderPath -Filter "*.sql") { Invoke-Sqlcmd -ServerInstance ".\SQLEXPRESS" -Database "SQLCopTests" -InputFile $filename}

# -- This doesn’t report any results on the screen, though errors would be shown.

Invoke-Sqlcmd -ServerInstance ".\SQLEXPRESS" -Database "SQLCopTests" -Query "EXEC tSQLt.RunAll"

$FolderPath = Get-Location
foreach ($filename in Get-ChildItem -Path $FolderPath -Filter "*.sql") { Invoke-Sqlcmd -ServerInstance ".\SQLEXPRESS" -Database "CC3_CMS_test" -InputFile $filename}

-OutputSqlErrors $true