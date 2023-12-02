Param(
	$Path = ".",
	$SQLServer = ".\SQLEXPRESS",
	$SQLDBName = "CC3_local",
	$uid = "ccwebadmin",
	$pwd = "Password",
	[switch]$showOutput
)
# $FolderPath = Get-Location
# Write-Host "Building srv: $SQLServer  DB: $SQLDBName"
# foreach ($filename in Get-ChildItem -Path $FolderPath -Filter "*.sql") { 
#	 Invoke-Sqlcmd -ServerInstance $SQLServer -Database $SQLDBName -InputFile $filename -OutputSqlErrors $true
# }

# $DBsetup = ".\DatabaseSetup.sql"

$BuildFolders = "Assemblies","Schemas","Synonyms","Sequences","Types","Tables","ForeignKeys","Functions","Views","StoredProcedures","Security","Data\Default","Data\TestData""UpgradeScripts"

$UpgradeFolders =  "Functions","UpgradeScripts","Views","StoredProcedures"

function run-ScriptsInFolder {
	param( $folders )
	try
	{
		write-host "... running scripts "
		foreach ($folder in $folders) {
			write-host "runing folder: " $folder
			$FolderPath = $Path + $folder

			if (Test-Path $FolderPath) {
				write-host "folder: " $FolderPath
				foreach ($filename in Get-ChildItem -Path $FolderPath -Filter "*.sql") { 
					Invoke-Sqlcmd -ServerInstance $SQLServer -Database $SQLDBName -InputFile $filename -OutputSqlErrors $true
					if (!$?) {
						exit $LASTEXITCODE
					}
				}
			}
		}
	}
	catch 
	{
		exit $LASTEXITCODE
	}
}

function run-Create-DB {
	param( $path )
	try
	{
		$dest = $path + "DatabaseSetup.sql"
		write-host "creating database: " $SQLDBname

		Invoke-Sqlcmd -InputFile $dest -ServerInstance $SQLServer `
			-Username $uid -Password $pwd -Variable "databasename=$SQLDBName" `
			-OutputSqlErrors $true -ErrorAction Stop # -Verbose
	}
	catch 
	{
		exit $LASTEXITCODE
	}
}

# Start here
write-host "Path: " $Path

#run-Create-DB $Path

#run-ScriptsInFolder $BuildFolders
run-ScriptsInFolder $UpgradeFolders


# -- Creating database %2 on %1

# ... Creating Assemblies       |	CALL "Assemblies\CreateAssemblies.bat"
# ... Creating Schemas          |	CALL "Schemas\CreateSchemas.bat"
# ... Creating Synonyms         |	CALL "Synonyms\CreateSynonyms.bat"
# ... Creating Sequences        |	CALL "Sequences\CreateSequences.bat"
# ... Creating Types            |	CALL "Types\CreateTypes.bat"
# ... Creating Tables           |	CALL "Tables\CreateTables.bat"
# ... Creating Foreign Keys     |	CALL "ForeignKeys\CreateFKs.bat"
# ... Creating UDFs             |	CALL "Functions\CreateFunctions.bat"
# ... Creating Views            |	CALL "Views\CreateViews.bat"
# ... Creating Stored Procedures|	CALL "StoredProcedures\CreateSprocs.bat"
# ... Creating Users and Logins |	CALL "Security\CreateSecurity.bat"
# ... Generating Default Data   |	CALL "Data\Default\CreateDefaultData.bat"
# ... Generating Test Data      |	CALL "Data\TestData\CreateTestData.bat"
# ... Running Unit Tests        |	CALL "StoredProcedures\UnitTests\RunUnitTests.bat"

# -- Upgrading database %2 on %1

# ... Altering UDFs             |	CALL "Functions\CreateFunctions.bat"
# ... Running Upgrade Scripts   |	CALL "UpgradeScripts\RunUpgradeScripts.bat"
# ... Altering Views            |	CALL "Views\CreateViews.bat"
# ... Altering Stored Procedures|	CALL "StoredProcedures\CreateSprocs.bat"
