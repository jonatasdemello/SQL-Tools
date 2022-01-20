-- https://docs.microsoft.com/en-us/troubleshoot/sql/database-design/remove-duplicate-rows-sql-server-tab

create table original_table (key_value int )

insert into original_table values (1)
insert into original_table values (1)
insert into original_table values (1)

insert into original_table values (2)
insert into original_table values (2)
insert into original_table values (2)
insert into original_table values (2)

-------------------------------------------------------------------------------------------------------------------------------
-- Method 1

SELECT DISTINCT *
	INTO duplicate_table
FROM original_table
GROUP BY key_value
HAVING COUNT(key_value) > 1

DELETE original_table
WHERE key_value IN (SELECT key_value FROM duplicate_table)

INSERT original_table
SELECT *
FROM duplicate_table

DROP TABLE duplicate_table

/*
This script takes the following actions in the given order:

    Moves one instance of any duplicate row in the original table to a duplicate table.
    Deletes all rows from the original table that are also located in the duplicate table.
    Moves the rows in the duplicate table back into the original table.
    Drops the duplicate table.

This method is simple. However, it requires you to have sufficient space available in the database to temporarily build the duplicate table. This method also incurs overhead because you are moving the data.

Also, if your table has an IDENTITY column, you would have to use SET IDENTITY_INSERT ON when you restore the data to the original table.
*/

-------------------------------------------------------------------------------------------------------------------------------
-- Method 2

DELETE T
FROM
(
	SELECT *, DupRank = ROW_NUMBER() OVER 
		(PARTITION BY key_value ORDER BY (SELECT NULL))
	FROM original_table
) AS T
WHERE DupRank > 1

/*
This script takes the following actions in the given order:

    Uses the ROW_NUMBER function to partition the data based on the key_value which may be one or more columns separated by commas.
    Deletes all records that received a DupRank value that is greater than 1. This value indicates that the records are duplicates.

Because of the (SELECT NULL) expression, the script does not sort the partitioned data based on any condition. If your logic to delete duplicates requires choosing which records to delete and which to keep based on the sorting order of other columns, you could use the ORDER BY expression to do this.
*/
