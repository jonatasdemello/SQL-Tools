Msg 1934, Level 16, State 1, Server CC-SRV-25, Line 12 
November 22nd 2021 11:38:39
Error
INSERT failed because the following SET options have incorrect settings: 'ANSI_NULLS, ANSI_WARNINGS, ANSI_PADDING'. 
Verify that SET options are correct for use with indexed views 
and/or indexes on computed columns 
and/or filtered indexes 
and/or query notifications 
and/or XML data type methods 
and/or spatial index operations. 



SET ANSI_NULLS ON affects a comparison only if one of the operands of the comparison is either a variable that is NULL or a literal NULL. 
If both sides of the comparison are columns or compound expressions, the setting does not affect the comparison.

https://docs.microsoft.com/en-us/sql/t-sql/statements/set-ansi-nulls-transact-sql?view=sql-server-ver15


SET ANSI_PADDING ON;



--Defaults
SET ANSI_NULLS OFF;
SET ANSI_PADDING OFF;
SET ANSI_WARNINGS OFF;
SET QUOTED_IDENTIFIER ON;
GO


select [name],
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


 SET ANSI_NULLS { ON | OFF }

When setting ANSI_NULLS to ON, all comparisons against the NULL value will evaluate UNKNOWN; the (column_name=NULL) and (column_name<>NULL) in the WHERE clause will return no rows even there are NULL and non-NULL values in that column, with no mean of using the equality operators to compare with the NULL value.

Setting the ANSI_NULLS to OFF, the Equals (=) and Not Equal To (<>) comparison operators will not follow the ISO standard for the current session and can be used to compare with the NULL value. In this case, the (column_name=NULL) in the WHERE statement will return all rows with NULL value in that column, and the (column_name<>NULL) will exclude the rows that have NULL value in that column, considering the NULL as a valid value for comparison.

Take into consideration that, for executing distributed queries or creating or changing indexes on computed columns or indexed views, the SET ANSI_NULLS should be set to ON. Otherwise, the operation will fail and the SQL Server will return an error that lists all SET options that violate the required values. The SET ANSI_NULLS setting will be set at run time and not at parse time. 


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

