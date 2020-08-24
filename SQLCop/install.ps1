# C:\Workspace\_code\SQL-cop\SQLCop\Current


Invoke-Sqlcmd -ServerInstance ".\SQLEXPRESS" -Database "SQLCopTests" -Query "EXEC tsqlt.NewTestClass @ClassName = N'SQLCop'"

# -- To make this easier, I will execute each .sql file in my database with this short PoSh script

foreach ($filename in Get-ChildItem -Path $FolderPath -Filter "*.sql") { Invoke-Sqlcmd -ServerInstance ".\SQLEXPRESS" -Database "SQLCopTests" -InputFile $filename}

# -- This doesn’t report any results on the screen, though errors would be shown.


Invoke-Sqlcmd -ServerInstance ".\SQLEXPRESS" -Database "SQLCopTests" -Query "EXEC tSQLt.RunAll"





foreach ($filename in Get-ChildItem -Path $FolderPath -Filter "*.sql") { Invoke-Sqlcmd -ServerInstance ".\SQLEXPRESS" -Database "SQLCopTests" -InputFile $filename}


Get-ChildItem d:\scripts -include *.txt -Recurse  | ForEach-Object {Get-Content $_; ""} | out-file d:\scripts\test.txt


# -- Here is a solution that will generate a combined file with a blank line separating the contents of each file. 
# -- If you'd prefer you can include any character you want within the "" in the foreach-object loop.

Get-ChildItem d:\scripts -include *.txt -Recurse  | ForEach-Object {Get-Content $_; ""} | out-file d:\scripts\test.txt

# -- And FTR there is no need to worry about putting the file you are creating in the same directory that you are scanning. 
# -- It is being created after the Get-ChildItem cmdlet has run in the pipeline and so will not create problems 
# -- (although its contents will be included in subsequent runs of your script if you do not remove it).


$yourdir = "c:\temp\"
Get-ChildItem $yourdir -File -Filter *.txt | gc | out-file -FilePath ([Environment]::GetFolderPath("Desktop") + "\totalresult.txt")

# -- If you want add file name for header you can do it:

$yourdir="c:\temp\"
$destfile= ([Environment]::GetFolderPath("Desktop") + "\totalresult.txt")
Get-ChildItem $yourdir -File -Filter *.txt | %{"________________________" |out-file  $destfile -Append; $_.Name  | Out-File  $destfile -Append; gc $_.FullName | Out-File  $destfile -Append}

$directory = "C:\tmp"

$resultFile = $env:USERPROFILE + "\Desktop\result.txt"

Get-ChildItem -Path $directory -Include *.txt -Recurse | Get-Content | Out-File -FilePath $resultFile -NoClobber

