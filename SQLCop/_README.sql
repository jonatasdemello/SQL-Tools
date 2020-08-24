/*
tSQLt test framework:
---------------------
	https://tsqlt.org/
	
	Download here:
	https://tsqlt.org/downloads/
	
		https://tsqlt.org/user-guide/quick-start/
		https://tsqlt.org/user-guide/tsqlt-tutorial/
		https://tsqlt.org/full-user-guide/
	
	https://github.com/tSQLt-org/tSQLt

		https://tsqlt.org/after-running-the-examples-smss/
		https://tsqlt.org/after-running-the-examples-sql-test/
	
SQLCop:
-------
	https://github.com/red-gate/SQLCop


Links:
	http://sqlcop.lessthandot.com/

	https://www.red-gate.com/simple-talk/sql/sql-tools/sql-cop-review/
	https://www.red-gate.com/simple-talk/sql/database-administration/brads-sure-dba-checklist/
	https://www.red-gate.com/simple-talk/sql/sql-tools/using-sql-test-database-unit-testing-with-teamcity-continuous-integration/
	https://www.red-gate.com/blog/database-development/dont-unit-test-sql-server-code
	https://www.sqlservercentral.com/articles/installing-tsqlt
	https://www.sqlservercentral.com/articles/contribute-to-the-sqlcop-project

GitHub:
	https://github.com/tSQLt-org/tSQLt
	https://github.com/red-gate/SQLCop

	https://github.com/jonatasdemello/tSQLt
	https://github.com/jonatasdemello/SQLCop

*/
select [name] from sys.procedures where schema_id = SCHEMA_ID('tSQLt')
select [name] from sys.procedures where schema_id = SCHEMA_ID('SQLCop')

