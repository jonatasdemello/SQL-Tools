
# SQL Coding Standards

## Naming Conventions

* All objects MUST be referenced with their schema name at all times (within C# code and within SQL), even if the schema is the default **dbo** schema.
	*   Failure to do so forces a performance hit because SQL to do an extra lookup on the schema during query execution.
	*   There's also a potential for SQL to reference the wrong object if there are two objects with the same name but in different schemas.
	*   For instance, `EXEC PortfolioSave` would be incorrect. The call should be `EXEC dbo.PortfolioSave`

* Table names should be **singular**;
	* for instance, name your table `dbo.Portfolio` rather than `dbo.Portfolios`.
	* Same thing goes for many-to-many tables: instead of `dbo.PortfolioRoles`, use `dbo.PortfolioRole`.

* Objects should be named using **Pascal casing** in which case the first letter of each word is uppercase, while the rest of the identifier is in lowercase.

	*  Examples of **incorrect** names:
		* dbo.portfolioRole,
		* dbo.Portfolio_Role,
		* dbo.[Portfolio Role].
	* The **correct** naming convention is `dbo.PortfolioRole`

* Underscores and spaces should **never be used** in object names with the exception of using underscores when identifying views, indexes, or functions.

* **IDENTITY** columns should always be named in the format `[Table Name]Id` where:
	* `Id` is always capitalized on the first letters and lower case on the second letter.
	* Example: `PortfolioId`, or `LanguageSkillId`

* **Foreign key** columns should always be identical to the primary key of the referenced table.
	* For instance, if `PortId` exists in the `dbo.LanguageSkill` table and references `dbo.Portfolio.PortfolioId`, it should be renamed to match `PortfolioId`.

* **Schema** names should always use **Pascal casing**.
	* Examples include `Student`, `School`, and `Report`
	* The number of schemas inside a database should not exceed 10 - don't get carried away with them.

* The following object types should be named with specific prefixes to identify their type;
	* additionally some formatting rules apply to indexes and constraints to make their meaning clear.


<br/>

| Object Type | Prefix | Naming Convention | Example |
|------------ |------- |------------------ |-------- |
| View | vw_ | vw_[ViewName] | dbo.vw_InactivePortfolios |
| User Defined Functions | udf_ | udf_[UDFName] | dbo.udf_CalculateCreditsTaken() |
| Indexes | ix_ | ix_[TableName]_[Col1]_[Col2]_[etc...] | ix_Portfolio_LastName_FirstName |
| Unique Indexes | ux_ | ux_[TableName]_[Col1]_[Col2]_[etc...] | ux_Portfolio_Email_Password |
| Primary Keys | pk_ | pk_[TableName]_[Col1]_[Col2]_[etc...] | pk_Portfolio_PortfolioID |
| Foreign Keys | fk_ | fk_[CurrentTable]_[FKTable]_[Column] | fk_Portfolio_Country_CountryId |
| Default Constraints | df_ | df_[CurrentTable]_[Column] | df_Portfolio_CreatedDate |
| Check Constraints | chk_ | chk_[CurrentTable]_[Column] | chk_Portfolio_PCSStatus |
| Stored Procedures | Nothing | - | (see below) |

<br/>

**Stored procedures should have no prefix.**

In many companies, the standard is to use "sp_" as the prefix, but this is a big performance hit because "sp_" is a naming convention SQL Server uses internally for system procedures, so by prefixing stored procedures with this prefix, SQL will first do an unnecessary look-up in system procedures folder before it's able to determine the call refers to a non-system stored procedure.

Stored procedures should be named first by the table they operate on and then a verb that describes their operation. Examples:

|Operation|RecommendedName|
|--- |--- |
|Retrieve all languages from dbo.Language|dbo.LanguageGetAll|
|Save a portfolio|dbo.PortfolioSave|
|Generate a list of 20 random interests.|dbo.InterestGetRandom|
|Generate a complex report on military careers chosen by gender.|dbo.MilitaryCareerReportByGender|

<br>

Note: Since this procedure is likely operating on a number of tables,
it's more logical to name the procedure based on the type of report it produces rather than the tables it reads from.

<br/>

## Data Types

* TEXT, NTEXT, and IMAGE is deprecated.
	* Use VARCHAR(MAX), NVARCHAR(MAX), and VARBINARY(MAX) respectively.
* DateTime is deprecated,
	* Use Date, DateTime2 or DateTimeOffset instead (_SQL 2008 and later_)
* You'll also want to swap out any GETDATE() references for SYSDATETIME() which is for DATETIME2 and has a higher precision.
* Hard-coded dates should always be expressed in an unambiguous format `yyyymmddhhmmss`.
* Any other format runs the risk of mixing up the day with the month (for instance 2014-04-02) depending on the server locale settings.

## Formatting

SQL keywords should all be in upper case and SELECT, JOIN, WHERE, GROUP BY and HAVING should all be on their own lines. Take into consideration the following query:

```sql
select p.Gender, count(*) as PortfolioCount from dbo.Portfolio p inner join dbo.LanguageSkill ls ON (ls.PortfolioId = p.PortfolioId) where p.active = 1 group by p.Gender;
```

Should be re-written as follows:

```sql
SELECT p.Gender, COUNT(*) AS PortfolioCount
FROM dbo.Portfolio p
INNER JOIN dbo.LanguageSkill ls ON (ls.PortfolioId = p.PortfolioId)
WHERE p.Active = 1
GROUP BY p.Gender;
```

Use spaces between expressions for better readability.

Instead of a WHERE clause that looks like this:

`WHERE p.status=1 AND ls.LanguageId=1234`

Use:

`WHERE p.status = 1 AND ls.LanguageId = 1234`

When declaring a stored procedure or function, each parameter should be defined on its own line.

Take into consideration the following creation script:

```sql
CREATE PROCEDURE dbo.LanguageSkillSave(@PortfolioId INTEGER, @LanguageId INTEGER, @Language VARCHAR(50)) AS
```

Should be re-written as follows:

```sql
CREATE PROCEDURE dbo.LanguageSkillSave
(
   @PortfolioId INTEGER,
   @LanguageId INTEGER,
   @Language VARCHAR(50)
)
AS
```

## Writing Robust Code

**NEVER** use `SELECT *`!!!!

`SELECT *` causes a performance hit because SQL Server first has to look-up all of the column name metadata before it can actually execute the query.

Worse still, it's non-deterministic: adding, removing, or re-ordering a column in the base table will cause the results to change and could possibly break calling code that expects a specific result set signature.

Never use column numbers in the ORDER BY clause.

Doing so means that if the SELECT list changes and you forget to change the ORDER BY clause, you'll start getting incorrect sorts.

```sql
-- Sort by LastName, then FirstName
SELECT FirstName, LastName, Gender, PortfolioId
FROM dbo.Portfolio
WHERE dbo.SchoolId = 1234
ORDER BY 2, 1
```

Instead it should be written as:

```sql
-- Sort by LastName, then FirstName
SELECT FirstName, LastName, Gender, PortfolioId
FROM dbo.Portfolio
WHERE dbo.SchoolId = 1234
ORDER BY LastName, FirstName
```

Never use query hints:

Avoid `(NOLOCK), (FORCESCAN), (FORCESEEK)` and all the rest.

Overriding the SQL Optimizer can cause huge performance bottlenecks as table sizes and cardinality change.

If you want to read uncommitted transactions use
`SET TRANSACTION ISOLATION LEVEL READ_UNCOMMITTED` instead of (NOLOCK).

No cross-database references in queries. Hard-coding cross-database references makes it much harder to move or rename a database.

Instead use `SYNONYMS` in the current database and point that synonym to the referenced database object.

This will ensure that the cross-referenced object appears in SQL code as if it exists in the current database. If a database migration needs to happen, only the synonyms need to be updated and all in one place.

Every table should have a `CreatedDate` and `ModifiedDate` column, DATETIME2, and both defaulting to SYSDATETIME().

Update: since we have clients in multiple time zones, it is better to use UTC date.

`[CreatedDateUTC] DATETIME2(7) NOT NULL DEFAULT (SYSUTCDATETIME()),`

`[ModifiedDateUTC] DATETIME2(7) NOT NULL DEFAULT (SYSUTCDATETIME()),`


This will be a huge help internally as it provides us with some simple auditing capabilities.
