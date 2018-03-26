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

--Synchronize the target table with --refreshed data from source table
MERGE Products AS TARGET
	USING UpdatedProducts AS SOURCE 
ON (TARGET.ProductID = SOURCE.ProductID) 

--When records are matched, update --the records if there is any change
WHEN MATCHED 
	AND TARGET.ProductName <> SOURCE.ProductName 
	OR TARGET.Rate <> SOURCE.Rate THEN 
		UPDATE SET TARGET.ProductName = SOURCE.ProductName, TARGET.Rate = SOURCE.Rate 
		
--When no records are matched, insert --the incoming records from source --table to target table
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

The MERGE SQL statement requires a semicolon (;) as a statement terminator. 
Otherwise Error 10713 is raised when a MERGE statement is executed without the statement terminator.
When used after MERGE, @@ROWCOUNT returns the total number of rows inserted, updated, and deleted to the client.

At least one of the three MATCHED clauses must be specified when using MERGE statement; 
the MATCHED clauses can be specified in any order. 
However a variable cannot be updated more than once in the same MATCHED clause.

Of course it's obvious, but just to mention, the person executing the MERGE statement should have 
SELECT Permission on the SOURCE Table and INSERT, UPDATE and DELETE Permission on the TARGET Table.
MERGE SQL statement improves the performance as all the data is read and processed only once 
whereas in previous versions three different statements have to be written to process 
three different activities (INSERT, UPDATE or DELETE) in which case the data in both the source and target tables are evaluated and processed multiple times; at least once for each statement.
MERGE SQL statement takes same kind of locks minus one Intent Shared (IS) Lock that was due to the select statement in the ‘IF EXISTS' as we did in previous version of SQL Server.
For every insert, update, or delete action specified in the MERGE statement, SQL Server fires any corresponding AFTER triggers defined on the target table, but does not guarantee on which action to fire triggers first or last. Triggers defined for the same action honor the order you specify.
*/


-- https://www.red-gate.com/simple-talk/sql/learn-sql-server/the-merge-statement-in-sql-server-2008/

USE AdventureWorks2008
 
IF OBJECT_ID ('BookInventory', 'U') IS NOT NULL
DROP TABLE dbo.BookInventory;
 
 
CREATE TABLE dbo.BookInventory  -- target
(
  TitleID INT NOT NULL PRIMARY KEY,
  Title NVARCHAR(100) NOT NULL,
  Quantity INT NOT NULL
    CONSTRAINT Quantity_Default_1 DEFAULT 0
);
 
IF OBJECT_ID ('BookOrder', 'U') IS NOT NULL
DROP TABLE dbo.BookOrder;
 
CREATE TABLE dbo.BookOrder  -- source
(
  TitleID INT NOT NULL PRIMARY KEY,
  Title NVARCHAR(100) NOT NULL,
  Quantity INT NOT NULL
    CONSTRAINT Quantity_Default_2 DEFAULT 0
);
 
INSERT BookInventory VALUES
  (1, 'The Catcher in the Rye', 6),
  (2, 'Pride and Prejudice', 3),
  (3, 'The Great Gatsby', 0),
  (5, 'Jane Eyre', 0),
  (6, 'Catch 22', 0),
  (8, 'Slaughterhouse Five', 4);
 
INSERT BookOrder VALUES
  (1, 'The Catcher in the Rye', 3),
  (3, 'The Great Gatsby', 0),
  (4, 'Gone with the Wind', 4),
  (5, 'Jane Eyre', 5),
  (7, 'Age of Innocence', 8);
  
  
  
  
MERGE BookInventory bi
USING BookOrder bo ON bi.TitleID = bo.TitleID
WHEN MATCHED THEN
  UPDATE SET bi.Quantity = bi.Quantity + bo.Quantity;
 
SELECT * FROM BookInventory;



MERGE BookInventory bi
USING BookOrder bo ON bi.TitleID = bo.TitleID
WHEN MATCHED AND  bi.Quantity + bo.Quantity = 0 THEN
  DELETE
WHEN MATCHED THEN
  UPDATE   SET bi.Quantity = bi.Quantity + bo.Quantity;
 
SELECT * FROM BookInventory;

/*
NOTE: The examples in this article are independent of one another. 
That is, for each example you run, you should first rerun the table creation 
script if you want your results to match the ones shown here.
*/


MERGE BookInventory bi
USING BookOrder bo ON bi.TitleID = bo.TitleID
WHEN MATCHED AND  bi.Quantity + bo.Quantity = 0 THEN
  DELETE
WHEN MATCHED THEN
  UPDATE   SET bi.Quantity = bi.Quantity + bo.Quantity
WHEN NOT MATCHED BY TARGET THEN
  INSERT (TitleID, Title, Quantity)
  VALUES (bo.TitleID, bo.Title,bo.Quantity);
 
SELECT * FROM BookInventory;


/*
NOTE: Like the WHEN MATCHED clause, you can include up to two WHEN NOT MATCHED BY SOURCE clauses in your MERGE statement. 
If you include two, the first clause must include the AND keyword followed by a search condition.
*/

MERGE BookInventory bi
USING BookOrder bo ON bi.TitleID = bo.TitleID
WHEN MATCHED AND bi.Quantity + bo.Quantity = 0 THEN
  DELETE
WHEN MATCHED THEN
  UPDATE   SET bi.Quantity = bi.Quantity + bo.Quantity
WHEN NOT MATCHED BY TARGET THEN
  INSERT (TitleID, Title, Quantity)
  VALUES (bo.TitleID, bo.Title,bo.Quantity)
WHEN NOT MATCHED BY SOURCE
  AND bi.Quantity = 0 THEN
  DELETE;
 
SELECT * FROM BookInventory;





DECLARE @MergeOutput TABLE
(
  ActionType NVARCHAR(10),
  DelTitleID INT,
  InsTitleID INT,
  DelTitle NVARCHAR(50),
  InsTitle NVARCHAR(50),
  DelQuantity INT,
  InsQuantity INT
);
 
MERGE BookInventory bi
USING BookOrder bo ON bi.TitleID = bo.TitleID
WHEN MATCHED AND bi.Quantity + bo.Quantity = 0 THEN
  DELETE
WHEN MATCHED THEN
  UPDATE
  SET bi.Quantity = bi.Quantity + bo.Quantity
WHEN NOT MATCHED BY TARGET THEN
  INSERT (TitleID, Title, Quantity)
  VALUES (bo.TitleID, bo.Title,bo.Quantity)
WHEN NOT MATCHED BY SOURCE AND bi.Quantity = 0 THEN
  DELETE
OUTPUT
    $action,
    DELETED.TitleID,
    INSERTED.TitleID,
    DELETED.Title,
    INSERTED.Title,
    DELETED.Quantity,
    INSERTED.Quantity
  INTO @MergeOutput;
 
SELECT * FROM BookInventory;
 
SELECT * FROM @MergeOutput;


/*
Notice that I first declare the @MergeOutput table variable. In the variable, I include a column for the action type plus three additional sets of column. Each set corresponds to the columns in the target table and includes a column that shows the deleted data and one that shows the inserted data. For example, the DelTitleID and InsTitleID columns correspond to the deleted and inserted values, respectively, in the target table.

The OUTPUT clause itself first specifies the built-in $action variable, which returns one of three nvarchar(10) values-INSERT, UPDATE, or DELETE. The variable is available only to the MERGE statement. I follow the variable with a set of column prefixes (DELETED and INSERTED) for each column in the target table. The column prefixes are followed by the name of the column they’re related to. For example, I include DELETED.TitleID and INSERTED.TitleID for the TitleID column in the target table. After I specify the column prefixes, I then include an INTO subclause, which specifies that the outputted values should be saved to the @MergeOutput variable.
*/