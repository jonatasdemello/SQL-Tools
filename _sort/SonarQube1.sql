/*
A WHERE clause condition that uses NOT IN with a subquery 
will have unexpected results if that subquery returns NULL. 

On the other hand, NOT EXISTS subqueries work reliably under the same conditions.

This rule raises an issue when NOT IN is used with a subquery. 
This rule doesn’t check if the selected column is a nullable column because the rules engine 
has no information about the table definition. 
It’s up to the developer to review manually if the column is nullable.

*/
-- Noncompliant Code Example

SELECT *
FROM my_table
WHERE my_column NOT IN (SELECT nullable_column FROM another_table)
-- Noncompliant; "nullable_column" may contain 'NULL' value and the whole SELECT query will return nothing

-- Compliant Solution

SELECT *
FROM my_table
WHERE NOT EXISTS (SELECT 1 FROM another_table WHERE nullable_column = my_table.my_column)

SELECT *
FROM my_table
WHERE my_column NOT IN (SELECT nullable_column FROM another_table WHERE nullable_column IS NOT NULL)

-----------------------------------------------------------------------
GO

CREATE TABLE my_table (
	my_column int,
	my_text VARCHAR(10)
)
CREATE TABLE another_table (
	my_column int,
	my_text VARCHAR(10),
	nullable_column int NULL
)

insert into my_table (my_column, my_text) values (1, 'val 1')
insert into my_table (my_column, my_text) values (2, 'val 2')
insert into my_table (my_column, my_text) values (3, 'val 3')
insert into my_table (my_column, my_text) values (4, 'val 4')
insert into my_table (my_column, my_text) values (5, 'val 5')

insert into another_table (my_column, my_text, nullable_column) values (1, 'val 1', 1)
insert into another_table (my_column, my_text, nullable_column) values (2, 'val 2', 2)
insert into another_table (my_column, my_text, nullable_column) values (3, 'val 3', NULL)
insert into another_table (my_column, my_text, nullable_column) values (4, 'val 4', NULL)
--insert into another_table (my_column, my_text, nullable_column) values (5, 'val 5', NULL)
--delete from another_table where my_column in (4,5)

SELECT TOP (100) * FROM my_table
SELECT TOP (100) * FROM another_table

-- Noncompliant Code Example
SELECT * FROM my_table WHERE my_column IN (SELECT nullable_column FROM another_table)
-- IN return the correct values 1,2
SELECT * FROM my_table WHERE my_column NOT IN (SELECT nullable_column FROM another_table)
-- Noncompliant; "nullable_column" may contain 'NULL' value and the whole SELECT query will return nothing

-- Compliant Solution
SELECT * FROM my_table WHERE NOT EXISTS (SELECT 1 FROM another_table WHERE nullable_column = my_table.my_column)

SELECT * FROM my_table WHERE my_column NOT IN (SELECT nullable_column FROM another_table WHERE nullable_column IS NOT NULL)

