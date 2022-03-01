Get-History
Clear-History

ALT+F7

(Get-PSReadlineOption).HistorySavePath
[Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory()

C:\Users\jonatasd\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
-------------------------------------------------------------------------------------------------------------------------------


Get-ChildItem . | Unblock-File

-------------------------------------------------------------------------------------------------------------------------------

.gitignore
.DS_Store

#show path
$env:PSModulePath -split ";"
 
-------------------------------------------------------------------------------------------------------------------------------
https://stackoverflow.com/questions/40286458/combine-multiple-text-files-and-produce-a-new-single-text-file-using-powershell


gci *.log | sort LastWriteTime | % {$(Get-Content $_)} | Set-Content result.log

Get-ChildItem -Recurse *.cs | ForEach-Object { Get-Content $_ } | Out-File -Path .\all.txt

Get-Content c:\FileToAppend_*.log | Out-File -FilePath C:\DestinationFile.log -Encoding ASCII -Append

Get-Content inputFile*.txt | Set-Content joinedFile.txt

Get-Content .\File?.txt | Out-File .\Combined.txt

Get-Content .\dataset*.sql | Out-File .\Combined.sql

Get-Content .\School_UG*.sql | Out-File C:\temp\Combined.sql

# Here is a solution that will generate a combined file with a blank line separating the contents of each file. 
# If you'd prefer you can include any character you want within the "" in the foreach-object loop.

Get-ChildItem d:\scripts -include *.txt -rec | ForEach-Object {Get-Content $_; ""} | Out-File d:\scripts\test.txt

-------------------------------------------------------------------------------------------------------------------------------

cd C:\Workspace\CMS\CMS_Database\StoredProcedures
Get-Content .\dataset*.sql | Out-File C:\temp\dataset-sprocs.sql


cd C:\Workspace\CMS\CMS_Database\Tables
Get-Content .\dataset*.sql | Out-File C:\temp\dataset-tables.sql


-------------------------------------------------------------------------------------------------------------------------------

The fourth example under help -Examples Move-Item is close to what you need. 
To move all files under the source directory to the dest directory you can do this:

Get-ChildItem -Path source -Recurse -File | Move-Item -Destination dest

If you want to clear out the empty directories afterwards, you can use a similar command:

Get-ChildItem -Path source -Recurse -Directory | Remove-Item

Get-ChildItem -Force  -recurse -filter .DS_STORE   | Remove-Item -Force -ErrorAction SilentlyContinue 

-------------------------------------------------------------------------------------------------------------------------------


Get-ChildItem -Force  -recurse -filter .DS_STORE | Remove-Item -Force -ErrorAction SilentlyContinue

Get-ChildItem -Path C:\Temp -Include *.* -File -Recurse | foreach { $_.Delete()}
Get-ChildItem -Path . -Include .DS_Store -File -Recurse | foreach { $_.Delete()}
Get-ChildItem -recurse -filter .DS_STORE | Remove-Item -WhatIf
Remove-Item .DS_Store -Recurse -Force -ErrorAction SilentlyContinue

find . -name '.DS_Store' -type f -delete
find . -name '.DS_Store' -type f -delete 

rm -v **/.DS_Store
del /s /q /f /a .DS_STORE
del /s /q /f /a:h .DS_STORE
del /s /q /f /a:h ._*

-------------------------------------------------------------------------------------------------------------------------------

find ~ -name '*jpg'

# Change line endings:
find . -type f -exec dos2unix {} \;
find . -type f -exec unix2dos {} \;

find . -name '*.xml' -type f -exec dos2unix {} \;

# -------------------------------------------------------------------------------------------------------------------------------
find /path/to/directory/ -name *.csv -print0 | xargs -0 -I file cat file > merged.file
find /path/to/directory/ -name *.csv -exec cat {} + > merged.file

$ cat *pattern* >> mergedfile

$ cat * > merged-file

# actually has the undesired side-effect of including 'merged-file' 
# in the concatenation, creating a run-away file. 
# To get round this, either write the merged file to a different directory;

$ cat * > ../merged-file

# or use a pattern match that will ignore the merged file;

$ cat *.txt > merged-file

Lets say you have:

~/file01
~/file02
~/file03
~/file04
~/fileA
~/fileB
~/fileC
~/fileD

And you want only file01 to file03 and fileA to fileC:

cat ~/file01 ~/file02 ~/file03 ~/fileA ~/fileB ~/fileC > merged-file

Or, using brace expansion:

cat ~/file0{1..3} ~/file{A..C} > merged-file

Or, using fancier brace expansion:

cat ~/file{0{1..3},{A..C}} > merged-file

Or you can use for loop:

for i in file0{1..3} file{A..C}; do cat ~/"$i"; done > merged-file


-------------------------------------------------------------------------------------------------------------------------------

# Remove all *.swp files underneath the current directory, use the find command in one of the following forms:

find /path -type f -name "*.swp" -delete
find /path -type f -name "*.swp" -exec rm -f "{}" +;

find . -name '*.swp' -delete
find . -name \*.swp -type f -delete

# The -delete option means find will directly delete the matching files. This is the best match to OP's actual question.
# Using -type f means find will only process files.

find . -name \*.swp -type f -exec rm -f {} \;
find . -name \*.swp -type f -exec rm -f {} +

# Option -exec allows find to execute an arbitrary command per file. 
# The first variant will run the command once per file, 
# and the second will run as few commands as possible by replacing {} with as many parameters as possible.

find . -name \*.swp -type f -print0  | xargs -0 rm -f

# Piping the output to xargs is used form more complex per-file commands than is possible with -exec. 
# The option -print0 tells find to separate matches with ASCII NULL instead of a newline, 
# and -0 tells xargs to expect NULL-separated input. 
# This makes the pipe construct safe for filenames containing whitespace. 

