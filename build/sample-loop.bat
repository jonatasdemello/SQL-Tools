IF "%~1"=="" ( GOTO InvalidParameters ) 
IF "%~2"=="" ( GOTO InvalidParameters ) 

REM Loop through each .sql file in the folder and execute it with sqlcmd 
setlocal enabledelayedexpansion

FOR %%f IN ("%~dp0*.sql") DO (

	REM If we're using SQL authentication.
	IF "%~3" NEQ "" ( IF "%~4" NEQ "" (
		rem ECHO ...... Executing file "%%f"
		sqlcmd -S %1 -i "%%f" -d%2 -v databasename=%2 -r0 -I -m11 -b -V 1  -U %3 -P %4 -f 65001
		IF !ERRORLEVEL! NEQ 0 (
			ECHO %%f Failed... 
			EXIT /B !ERRORLEVEL!
		)
	))

	REM If we're using trusted authentication.
	IF "%~3"=="" ( IF "%~4"=="" (
		rem ECHO ...... Executing file "%%f"
		sqlcmd -S %1 -i "%%f" -d%2 -v databasename=%2 -r0 -I -m11 -b -V 1 -f 65001
		IF !ERRORLEVEL! NEQ 0 (
			ECHO %%f Failed... 
			EXIT /B !ERRORLEVEL!
		)
	))	
)

GOTO Done
	
:InvalidParameters

ECHO Default Data NOT created. Syntax is CreateDefaultData.bat servername databasename [username] [password]

:Done