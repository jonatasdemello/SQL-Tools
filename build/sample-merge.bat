IF "%~1"=="" ( GOTO InvalidParameters )
IF "%~2"=="" ( GOTO InvalidParameters ) 

SETLOCAL EnableDelayedExpansion

REM *** create master file
type nul > %~dp0_tempbatch.cmd
for %%G in ("%~dp0*.sql") do ( echo :r "%%G" >> "%~dp0_tempbatch.cmd" & echo GO >> "%~dp0_tempbatch.cmd" ) >nul 2>&1

IF "%~3" NEQ "" ( IF "%~4" NEQ "" (
	sqlcmd -S %1 -i "%~dp0_tempbatch.cmd" -d %2 -v databasename=%2 -r0 -I -m11 -b -V 1 -U %3 -P %4 -f 65001 -a 16384
	IF !ERRORLEVEL! NEQ 0 ( EXIT /B !ERRORLEVEL! )
)) ELSE (
	sqlcmd -S %1 -i "%~dp0_tempbatch.cmd" -d %2 -v databasename=%2 -r0 -I -m11 -b -V 1 -E -f 65001 -a 16384
	IF !ERRORLEVEL! NEQ 0 ( EXIT /B !ERRORLEVEL! )
)

DEL /F /Q "%~dp0_tempbatch.cmd" >nul 2>&1

GOTO Done

:InvalidParameters

ECHO Tables NOT created. Syntax is CreateTables.bat servername databasename [username] [password]

:Done