Set-executionpolicy -scope CurrentUser -executionPolicy Undefined
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
Get-ExecutionPolicy -List
Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope LocalMachine

#for the Invoke-Sqlcmd you need to Install the SQL Server PowerShell module

Get-Module SqlServer -ListAvailable

Install-Module -Name SqlServer

Install-Module -Name SqlServer -Scope CurrentUser

Install-Module -Name SqlServer -AllowClobber

