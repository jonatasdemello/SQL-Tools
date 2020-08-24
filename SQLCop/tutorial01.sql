
-- Now it is time to write unit tests against your own code. tSQLt should be installed into your development database.
-- 1. Your database must be set to trustworthy for tSQLt to run. Execute the following script in your development database:

DECLARE @cmd NVARCHAR(MAX);
SET @cmd='ALTER DATABASE ' + QUOTENAME(DB_NAME()) + ' SET TRUSTWORTHY ON;';
EXEC(@cmd);

ALTER DATABASE SQLCopTests SET TRUSTWORTHY ON;
GO

USE SQLCopTests


EXEC tsqlt.NewTestClass @ClassName = N'SQLCop'


EXEC tSQLt.RunAll


EXEC tSQLt.DropClass 'SQLCop';
GO



/* 
https://www.sqlshack.com/sql-unit-testing-with-the-tsqlt-framework-for-beginners/

	This article describes how to load tsqlt, but this is essentially running the tsqlt.sql file. 
	I’ll do that, after ensuring the CLR is enabled for my instance.

	Once this is done, I need to load the SQLCop tests. There are two steps here. 
	The first one is to create a test class that will contain the tests. 
	The project uses “SQLCop” as the test class, so we need to execute this code:
*/

EXEC tsqlt.NewTestClass @ClassName = N'SQLCop'

-- To make this easier, I will execute each .sql file in my database with this short PoSh script

foreach ($filename in Get-ChildItem -Path $FolderPath -Filter "*.sql") { Invoke-Sqlcmd -ServerInstance "Plato\SQL2017" -Database "SQLCopTests" -InputFile $filename}

-- This doesn’t report any results on the screen, though errors would be shown.


/* 2. Write your own new test

Now that all the tests are passing, it is time to try out writing your own test case.
1. Create a test class

Test procedures in tSQLt are grouped into “test classes”. A test class is a schema that is specially marked by tSQLt. That way tSQLt knows how to find your test cases.

To create a new test class, open new Query Editor window and execute the following code:
 */
EXEC tSQLt.NewTestClass 'TryItOut';
GO

/* 2. Create a test case that fails (just to see what it looks like)

Next create a test procedure on this test class.

From the same Query Editor window execute the following code:
 */
CREATE PROCEDURE TryItOut.[test this causes a failure]
AS
BEGIN
    EXEC tSQLt.Fail 'This is what a failure looks like';
END;
GO
/* 
3. Create a test case that passes (again, just to see what it looks like)
 */
CREATE PROCEDURE TryItOut.[test this one passes]
AS
BEGIN
    DECLARE @sum INT;
    SELECT @sum = 1 + 2;

    EXEC tSQLt.AssertEquals 3, @sum;
END
GO
/* 
4. Run all of the tests

Again, you can execute all the tests by using tSQLt.RunAll:
 */
EXEC tSQLt.RunAll;
GO

/* 5. When you’re done experimenting with this test class, you can easily clean it up by running the following procedure
 */
EXEC tSQLt.DropClass 'TryItOut';
GO
