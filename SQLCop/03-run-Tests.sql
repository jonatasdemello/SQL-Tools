SET NOCOUNT ON;


-- All tests will run in the [SQLCop] schemma

EXEC tSQLt.RunAll

-- or
-- show all available tests in [SQLCop] schemma:

SELECT [name] FROM sys.procedures WHERE schema_id = SCHEMA_ID('SQLCop')

EXEC tSQLt.Run '[SQLCop].[test Table name problems]';

EXEC tSQLt.Run '[SQLCop].[test Procedures without SET NOCOUNT ON]';


