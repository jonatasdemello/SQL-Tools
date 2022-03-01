# Build all scripst in Folder

Invoke-Sqlcmd -ServerInstance ".\SQLEXPRESS" -Database "SQLCopTests" -Query "EXEC tsqlt.NewTestClass @ClassName = N'SQLCop'"

# -- To make this easier, I will execute each .sql file in my database with this short PoSh script

$FolderPath = Get-Location
foreach ($filename in Get-ChildItem -Path $FolderPath -Filter "*.sql") { Invoke-Sqlcmd -ServerInstance ".\SQLEXPRESS" -Database "SQLCopTests" -InputFile $filename}

# -- This doesn’t report any results on the screen, though errors would be shown.

Invoke-Sqlcmd -ServerInstance ".\SQLEXPRESS" -Database "SQLCopTests" -Query "EXEC tSQLt.RunAll" -OutputSqlErrors $true
