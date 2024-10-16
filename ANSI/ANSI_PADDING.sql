/*
Error:
INSERT failed because the following SET options have incorrect settings: 'ANSI_NULLS, ANSI_WARNINGS, ANSI_PADDING'. 
Verify that SET options are correct for use with indexed views 
and/or indexes on computed columns 
and/or filtered indexes 
and/or query notifications 
and/or XML data type methods 
and/or spatial index operations. 

Error:
UPDATE failed because the following SET options have incorrect settings: 'ANSI_NULLS, ANSI_WARNINGS, ANSI_PADDING'. 
Verify that SET options are correct for use with indexed views and/or indexes on computed columns and/or filtered indexes and/or query notifications and/or XML data type methods and/or spatial index operations.


SET ANSI_NULLS ON affects a comparison only if one of the operands of the comparison is either a variable that is NULL or a literal NULL. 
If both sides of the comparison are columns or compound expressions, the setting does not affect the comparison.

	https://docs.microsoft.com/en-us/sql/t-sql/statements/set-ansi-nulls-transact-sql?view=sql-server-ver15
	https://docs.microsoft.com/en-us/sql/t-sql/statements/set-ansi-padding-transact-sql?view=sql-server-ver15
	https://docs.microsoft.com/en-us/sql/t-sql/statements/set-ansi-warnings-transact-sql?view=sql-server-ver15

*/
-- example:
IF NOT EXISTS ( SELECT * FROM information_schema.columns WHERE table_schema = 'CollegeSuccess'
	ALTER TABLE CollegeSuccess.Application ADD IsAppMethodReminderDisplayed BIT NOT NULL DEFAULT 1;
END

-- or 
BEGIN
	-- first add column as NULL
	ALTER TABLE CollegeSuccess.Application ADD IsAppMethodReminderDisplayed BIT NULL;

	-- then remove all null 
	UPDATE CollegeSuccess.Application SET IsAppMethodReminderDisplayed = 1 WHERE IsAppMethodReminderDisplayed IS NULL;

	-- then add constraint
	ALTER TABLE CollegeSuccess.Application
		ADD CONSTRAINT DF_CollegeSuccess_Application_IsAppMethodReminderDisplayed
		DEFAULT 1 FOR IsAppMethodReminderDisplayed;
END



--Defaults
SET ANSI_NULLS OFF;
SET ANSI_PADDING OFF;
SET ANSI_WARNINGS OFF;
SET QUOTED_IDENTIFIER ON;
GO


select name,
	is_ansi_null_default_on, 
	is_ansi_nulls_on, 
	is_ansi_padding_on,
	is_ansi_warnings_on,
	is_arithabort_on,
	is_concat_null_yields_null_on,
	is_numeric_roundabort_on,
	is_quoted_identifier_on
from
    sys.databases
where name like 'cc3%'
order by name

-- list databases and their ANSI settings
select 
	name,
	case when
	 is_ansi_null_default_on = 1
	and is_ansi_nulls_on=1
	and is_ansi_padding_on=1
	and is_ansi_warnings_on=1
	and is_arithabort_on=1
	and is_concat_null_yields_null_on=1
	and is_numeric_roundabort_on=0
	and is_quoted_identifier_on=1 then 'ANSI'
	else 'not' 
	end
from
    sys.databases
order by
	name

-- Display the current settings.  
DBCC USEROPTIONS;  
GO 
/*
-------------------------------------------------------------------------------------------------------------------------------
SET ANSI_DEFAULTS { ON | OFF }

	ANSI_DEFAULTS is a server-side setting which can enable the behavior for all client connections.

	When dealing with indexes on computed columns and indexed views, four of these defaults 
	(ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, and QUOTED_IDENTIFIER) must be set to ON.

	The other SET options are ARITHABORT (ON), CONCAT_NULL_YIELDS_NULL (ON), and NUMERIC_ROUNDABORT (OFF)
	
	When enabled (ON), this option enables the following ISO settings:

	SET ANSI_NULLS
	SET ANSI_PADDING
	SET ANSI_WARNINGS
	SET ANSI_NULL_DFLT_ON
	SET CURSOR_CLOSE_ON_COMMIT
	SET IMPLICIT_TRANSACTIONS
	SET QUOTED_IDENTIFIER

	
-------------------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS { ON | OFF }

	Specifies ISO compliant behavior of the Equals (=) and Not Equal To (<>) comparison operators when they are used with null values in SQL Server.

	When ANSI_NULLS is ON,
		a SELECT statement that uses WHERE column_name = NULL returns zero rows even if there are null values in column_name. 
		A SELECT statement that uses WHERE column_name <> NULL returns zero rows even if there are nonnull values in column_name.

When ANSI_NULLS is OFF, the Equals (=) and Not Equal To (<>) comparison operators do not follow the ISO standard. A SELECT statement that uses WHERE column_name = NULL returns the rows that have null values in column_name. A SELECT statement that uses WHERE column_name <> NULL returns the rows that have nonnull values in the column. Also, a SELECT statement that uses WHERE column_name <> XYZ_value returns all rows that are not XYZ_value and that are not NULL.


	When setting ANSI_NULLS to ON, 
		all comparisons against the NULL value will evaluate UNKNOWN; 
		the (column_name=NULL) and (column_name<>NULL) in the WHERE clause will return no rows even there are NULL and non-NULL values in that column, with no mean of using the equality operators to compare with the NULL value.

Setting the ANSI_NULLS to OFF, the Equals (=) and Not Equal To (<>) comparison operators will not follow the ISO standard for the current session and can be used to compare with the NULL value. In this case, the (column_name=NULL) in the WHERE statement will return all rows with NULL value in that column, and the (column_name<>NULL) will exclude the rows that have NULL value in that column, considering the NULL as a valid value for comparison.

Take into consideration that, for executing distributed queries or creating or changing indexes on computed columns or indexed views, the SET ANSI_NULLS should be set to ON. Otherwise, the operation will fail and the SQL Server will return an error that lists all SET options that violate the required values. The SET ANSI_NULLS setting will be set at run time and not at parse time. 


-------------------------------------------------------------------------------------------------------------------------------
SET ANSI_PADDING { ON | OFF }

When the ANSI_ PADDING option is set to ON, which is the default setting:

    The original value of the char(n) column with trailing blanks will be padded with spaces to the length of the column. The spaces will be retrieved with the column value.
    The original value of the binary(n) column with trailing zeroes will be padded with zeroes to the length of the column. The zeroes will be retrieved with the column value.
    The trailing blanks in the varchar(n) column will not be trimmed and the column original value will not be padded with spaces to the length of the column.
    The trailing zeroes in the varbinary(n) column will not be trimmed and the column original value will not be padded with zeroes to the length of the column.

Setting the ANSI_ PADDING option is set to OFF:

    The original value of the char(n) NOT NULL column with trailing blanks will be padded with spaces to the length of the column. The spaces will not be retrieved with the column value.
    The original value of the binary(n) NOT NULL column with trailing zeroes will be padded with zeroes to the length of the column. The zeroes will not be retrieved with the column value.
    The trailing blanks in the varchar(n) column will be trimmed and the column original value will not be padded with spaces to the length of the column.
    The trailing zeroes in the varbinary(n) column will be trimmed and the column original value will not be padded with zeroes to the length of the column.
    The original value of the Null-able char(n) and Null-able binary(n) columns with trailing blanks and zeroes will not be padded, and these spaces and zeroes will be trimmed from the original column value.

The SET ANSI_PADDING option is always ON for the columns with nchar, nvarchar, ntext, text, image data types. Which means that trailing spaces and zeros are not trimmed from the original value.

The SET ANSI_PADDING option affects only newly created columns. Once created, the value will be stored in the column based on the setting configured when that column was created, and this column will not be affected by any new change performed after its creation.

Again, taking into consideration that, for creating or changing indexes on computed columns or indexed views, the SET ANSI_ PADDING should be set to ON. The SET ANSI_ PADDING setting will be set at run time and not at parse time. 


-------------------------------------------------------------------------------------------------------------------------------
SET ANSI_WARNINGS { ON | OFF }

Setting the ANSI_WARNING option to ON, the SQL Server Database Engine will follow the ISO standard in:

    A warning message is generated when null values appear in aggregate functions, such as SUM, AVG, MAX, MIN or COUNT.
    The T-SQL statement is rolled back and error message is generated when the divide-by-zero and arithmetic overflow errors detected.
    The INSERT or UPDATE T-SQL statement is canceled and an error message is generated if the length of a new value specified in that statement for the string column exceeds the maximum size of the column.

Setting the ANSI_WARNING option to OFF, the SQL Server Database Engine will follow a non-standard behavior, in which:

    No warning is issued when null values appear in aggregate functions, such as SUM, AVG, MAX, MIN or COUNT.
    A Warning message is generated when the divide-by-zero and arithmetic overflow errors detected and NULL values will be returned.
    The INSERT or UPDATE T-SQL statement will succeed if the length of a new value specified in that statement for the string column exceeds the maximum size of the column, and the data inserted will be truncated to the size of that column.

Take into consideration that, for executing the distributed queries or creating or changing indexes on computed columns or indexed views, the SET ANSI_ WARNINGS should be set to ON. Otherwise, the operation will fail and the SQL Server will return an error that lists all SET options that violate the required values. The SET ANSI_ WARNINGS setting will be set at run time and not at parse time. 


-------------------------------------------------------------------------------------------------------------------------------
SET ANSI_NULL_DFLT_OFF { ON | OFF }

	This setting only affects the nullability of new columns 
		when the nullability of the column is not specified in the CREATE TABLE and ALTER TABLE statements. 
	By default, when SET ANSI_NULL_DFLT_OFF is ON, 
		new columns that are created by using the ALTER TABLE and CREATE TABLE statements are NOT NULL 
			if the nullability status of the column is not explicitly specified. 
	SET ANSI_NULL_DFLT_OFF does not affect columns that are created by using an explicit NULL or NOT NULL.

Both SET ANSI_NULL_DFLT_OFF and SET ANSI_NULL_DFLT_ON cannot be set ON at the same time. 
If one option is set ON, the other option is set OFF. 
Therefore, either ANSI_NULL_DFLT_OFF or SET ANSI_NULL_DFLT_ON can be set ON, or both can be set OFF. 
If either option is ON, that setting (SET ANSI_NULL_DFLT_OFF or SET ANSI_NULL_DFLT_ON) takes effect. 
If both options are set OFF, SQL Server uses the value of the is_ansi_null_default_on column in the sys.databases catalog view.

-------------------------------------------------------------------------------------------------------------------------------
SET ANSI_NULL_DFLT_ON {ON | OFF}

	This setting only affects the nullability of new columns 
		when the nullability of the column is not specified in the CREATE TABLE and ALTER TABLE statements. 
	When SET ANSI_NULL_DFLT_ON is ON, new columns created by using the ALTER TABLE and CREATE TABLE statements allow null values 
	if the nullability status of the column is not explicitly specified. 
	SET ANSI_NULL_DFLT_ON does not affect columns created with an explicit NULL or NOT NULL.

	When SET ANSI_DEFAULTS is ON, SET ANSI_NULL_DFLT_ON is enabled.


-------------------------------------------------------------------------------------------------------------------------------
SET CONCAT_NULL_YIELDS_NULL { ON | OFF }

* keep ON

	Controls whether concatenation results are treated as null or empty string values.
	In a future version of SQL Server CONCAT_NULL_YIELDS_NULL will always be ON
	
	When SET CONCAT_NULL_YIELDS_NULL is ON, 
		concatenating a null value with a string yields a NULL result. 
		For example, SELECT 'abc' + NULL yields NULL. 
	
	When SET CONCAT_NULL_YIELDS_NULL is OFF, 
		concatenating a null value with a string yields the string itself (the null value is treated as an empty string). 
		For example, SELECT 'abc' + NULL yields abc.

	SET CONCAT_NULL_YIELDS_NULL must be ON 
		when creating or altering indexed views, indexes on computed columns, filtered indexes or spatial indexes. 
	
	If SET CONCAT_NULL_YIELDS_NULL is OFF, 
		any CREATE, UPDATE, INSERT, and DELETE statements on tables with indexes on computed columns, filtered indexes, spatial indexes or indexed 
		views will fail. 
	
	For more information about required SET option settings with indexed views and indexes on computed columns, 
	see "Considerations When You Use the SET Statements" in SET Statements (Transact-SQL).

When CONCAT_NULL_YIELDS_NULL is set to OFF, string concatenation across server boundaries cannot occur.



-------------------------------------------------------------------------------------------------------------------------------
https://docs.microsoft.com/en-us/sql/t-sql/statements/set-statements-transact-sql?view=sql-server-ver15

Considerations When You Use the SET Statements

    All SET statements run at execute or run time, except these statements, which run at parse time:
        SET FIPS_FLAGGER
        SET OFFSETS
        SET PARSEONLY
        and SET QUOTED_IDENTIFIER

    If a SET statement runs in a stored procedure or trigger, the value of the SET option gets restored after the stored procedure or trigger returns control. Also, if you specify a SET statement in a dynamic SQL string that runs by using either sp_executesql or EXECUTE, the value of the SET option gets restored after control returns from the batch that you specified in the dynamic SQL string.

    Stored procedures execute with the SET settings specified at execute time except for SET ANSI_NULLS and SET QUOTED_IDENTIFIER. Stored procedures specifying SET ANSI_NULLS or SET QUOTED_IDENTIFIER use the setting specified at stored procedure creation time. If used inside a stored procedure, any SET setting is ignored.

    The user options setting of sp_configure allows for server-wide settings and works across multiple databases. This setting also behaves like an explicit SET statement, except that it occurs at login time.

    Database settings set by using ALTER DATABASE are valid only at the database level and take effect only if explicitly set. Database settings override instance option settings that are set by using sp_configure.

    If a SET statement uses ON and OFF, you can specify either one for multiple SET options.

    Note

    This doesn't apply to the statistics related SET options.

    For example, SET QUOTED_IDENTIFIER, ANSI_NULLS ON sets both QUOTED_IDENTIFIER and ANSI_NULLS to ON.

    SET statement settings override identical database option settings that are set by using ALTER DATABASE. For example, the value specified in a SET ANSI_NULLS statement will override the database setting for ANSI_NULLs. Additionally, some connection settings get automatically set ON when a user connects to a database based on the values that go into effect by the previous use of the sp_configure user options setting, or the values that apply to all ODBC and OLE/DB connections.

    ALTER, CREATE and DROP DATABASE statements don't honor the SET LOCK_TIMEOUT setting.

    When a global or shortcut SET statement sets several settings, issuing the shortcut SET statement resets the previous settings for all those options that the shortcut SET statement affects. If a SET option that gets affected by a shortcut SET statement gets set after the shortcut SET statement gets issued, the individual SET statement overrides the comparable shortcut settings. An example of a shortcut SET statement would be SET ANSI_DEFAULTS.

    When batches are used, the database context is determined by the batch that is established by using the USE statement. Unplanned queries and all other statements that run outside the stored procedure and that are in batches inherit the option settings of the database and connection established by the USE statement.

    Multiple Active Result Set (MARS) requests share a global state that contains the most recent session SET option settings. When each request executes, it can modify the SET options. The changes are specific to the request context in which they're set, and don't affect other concurrent MARS requests. However, after the request execution is completed, the new SET options are copied to the global session state. New requests that execute under the same session after this change will use these new SET option settings.

    When a stored procedure runs from a batch or from another stored procedure, it's run under the option values set up in the database that has the stored procedure. For example, when stored procedure db1.dbo.sp1 calls stored procedure db2.dbo.sp2, stored procedure sp1 executes under the current compatibility level setting of database db1, and stored procedure sp2 executes under the current compatibility level setting of database db2.

    When a Transact-SQL statement concerns objects that are in multiple databases, the current database context and the current connection context applies to that statement. In this case, if Transact-SQL statement is in a batch, the current connection context is the database defined by the USE statement; if the Transact-SQL statement is in a stored procedure, the connection context is the database that contains the stored procedure.

    When you're creating and manipulating indexes on computed columns or indexed views, you must set these SET options to ON: ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER, ANSI_NULLS, ANSI_PADDING, and ANSI_WARNINGS. Set the option NUMERIC_ROUNDABORT to OFF.

    If you don't set any one of these options to the required values, INSERT, UPDATE, DELETE, DBCC CHECKDB, and DBCC CHECKTABLE actions on indexed views or tables with indexes on computed columns will fail. SQL Server will raise an error listing all the options that are incorrectly set. Also, SQL Server will process SELECT statements on these tables or indexed views as if the indexes on computed columns or on the views don't exist.

    When SET RESULT_SET_CACHING is ON, it enables the result caching feature for the current client session. Result_set_caching cannot be turned ON for a session if it is turned OFF at the database level. When SET RESULT_SET_CACHING is OFF, the result set caching feature is disabled for the current client session. Changing this setting requires membership in the public role. Applies to: Azure Synapse Analytics Gen2


*/
