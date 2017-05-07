--Create a target table
CREATE TABLE Products
(
ProductID INT PRIMARY KEY,
ProductName VARCHAR(100),
Rate MONEY
) 
GO
--Insert records into target table
INSERT INTO Products
VALUES
(1, 'Tea', 10.00),
(2, 'Coffee', 20.00),
(3, 'Muffin', 30.00),
(4, 'Biscuit', 40.00)
GO
--Create source table
CREATE TABLE UpdatedProducts
(
ProductID INT PRIMARY KEY,
ProductName VARCHAR(100),
Rate MONEY
) 
GO
--Insert records into source table
INSERT INTO UpdatedProducts
VALUES
(1, 'Tea', 10.00),
(2, 'Coffee', 25.00),
(3, 'Muffin', 35.00),
(5, 'Pizza', 60.00)
GO
SELECT * FROM Products
SELECT * FROM UpdatedProducts
GO

--Next I will use the MERGE SQL command to synchronize the target table with the refreshed data coming from the source table.

-- MERGE SQL statement - Part 2

--Synchronize the target table with
--refreshed data from source table
MERGE Products AS TARGET
USING UpdatedProducts AS SOURCE 
ON (TARGET.ProductID = SOURCE.ProductID) 
--When records are matched, update 
--the records if there is any change
WHEN MATCHED AND TARGET.ProductName <> SOURCE.ProductName 
OR TARGET.Rate <> SOURCE.Rate THEN 
UPDATE SET TARGET.ProductName = SOURCE.ProductName, 
TARGET.Rate = SOURCE.Rate 
--When no records are matched, insert
--the incoming records from source
--table to target table
WHEN NOT MATCHED BY TARGET THEN 
INSERT (ProductID, ProductName, Rate) 
VALUES (SOURCE.ProductID, SOURCE.ProductName, SOURCE.Rate)
--When there is a row that exists in target table and
--same record does not exist in source table
--then delete this record from target table
WHEN NOT MATCHED BY SOURCE THEN 
DELETE
--$action specifies a column of type nvarchar(10) 
--in the OUTPUT clause that returns one of three 
--values for each row: 'INSERT', 'UPDATE', or 'DELETE', 
--according to the action that was performed on that row
OUTPUT $action, 
DELETED.ProductID AS TargetProductID, 
DELETED.ProductName AS TargetProductName, 
DELETED.Rate AS TargetRate, 
INSERTED.ProductID AS SourceProductID, 
INSERTED.ProductName AS SourceProductName, 
INSERTED.Rate AS SourceRate; 
SELECT @@ROWCOUNT;
GO


/*
Notes

The MERGE SQL statement requires a semicolon (;) as a statement terminator. Otherwise Error 10713 is raised when a MERGE statement is executed without the statement terminator.
When used after MERGE, @@ROWCOUNT returns the total number of rows inserted, updated, and deleted to the client.
At least one of the three MATCHED clauses must be specified when using MERGE statement; the MATCHED clauses can be specified in any order. However a variable cannot be updated more than once in the same MATCHED clause.
Of course it's obvious, but just to mention, the person executing the MERGE statement should have SELECT Permission on the SOURCE Table and INSERT, UPDATE and DELETE Permission on the TARGET Table.
MERGE SQL statement improves the performance as all the data is read and processed only once whereas in previous versions three different statements have to be written to process three different activities (INSERT, UPDATE or DELETE) in which case the data in both the source and target tables are evaluated and processed multiple times; at least once for each statement.
MERGE SQL statement takes same kind of locks minus one Intent Shared (IS) Lock that was due to the select statement in the ‘IF EXISTS' as we did in previous version of SQL Server.
For every insert, update, or delete action specified in the MERGE statement, SQL Server fires any corresponding AFTER triggers defined on the target table, but does not guarantee on which action to fire triggers first or last. Triggers defined for the same action honor the order you specify.
*/