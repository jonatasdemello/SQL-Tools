/*
	Implementing the OUTPUT Clause in SQL Server 2008
	
https://www.red-gate.com/simple-talk/sql/learn-sql-server/implementing-the-output-clause-in-sql-server-2008/
*/

IF OBJECT_ID ('Books', 'U') IS NOT NULL
DROP TABLE dbo.Books;
 
CREATE TABLE dbo.Books
(
  BookID int NOT NULL PRIMARY KEY,
  BookTitle nvarchar(50) NOT NULL,
  ModifiedDate datetime NOT NULL
);

-- declare @InsertOutput1 table variable 
DECLARE @InsertOutput1 table
(
  BookID int,
  BookTitle nvarchar(50),
  ModifiedDate datetime
);
 
-- insert new row into Books table
INSERT INTO Books
	OUTPUT INSERTED.* INTO @InsertOutput1
VALUES(101, 'One Hundred Years of Solitude', GETDATE());
 
-- view inserted row in Books table
SELECT * FROM Books;
 
-- view output row in @InsertOutput1 variable
SELECT * FROM @InsertOutput1;



-- declare @InsertOutput2 table variable 
DECLARE @InsertOutput2 table
(
  BookID int,
  BookTitle nvarchar(50),
  ModifiedDate datetime
);
 
-- insert new row into Books table
INSERT INTO Books
OUTPUT 
    INSERTED.BookID, 
    INSERTED.BookTitle, 
    INSERTED.ModifiedDate
  INTO @InsertOutput2
VALUES(102, 'Pride and Prejudice', GETDATE());
 
-- view inserted row in Books table
SELECT * FROM Books;
 
-- view output row in @InsertOutput2 variable
SELECT * FROM @InsertOutput2;


-- declare @InsertOutput2 table variable 
DECLARE @InsertOutput3 table
(
  BookID int,
  BookTitle nvarchar(50)
);
 
-- insert new row into Books table
INSERT INTO Books
OUTPUT 
    INSERTED.BookID, 
    INSERTED.BookTitle
  INTO @InsertOutput3
VALUES(103, 'The Great Gatsby', GETDATE());
 
-- view inserted row in Books table
SELECT * FROM Books;
 
-- view output row in @InsertOutput3 variable
SELECT * FROM @InsertOutput3;




-- declare @InsertOutput4 table variable 
DECLARE @InsertOutput4 table
(
  Title nvarchar(50),
  TitleID int,
  TitleAddDate datetime
);
 
-- insert new row into Books table
INSERT INTO Books
OUTPUT 
    INSERTED.BookID, 
    INSERTED.BookTitle, 
    INSERTED.ModifiedDate
  INTO @InsertOutput4
		(TitleID, Title, TitleAddDate)
VALUES  (104, 'Mrs. Dalloway', GETDATE());
 
-- view inserted row in Books table
SELECT * FROM Books;
 
-- view output row in @InsertOutput4 variable
SELECT * FROM @InsertOutput4;



/*
In the previous examples, the OUTPUT clause includes the INSERTED column prefix in the OUTPUT subclause. However, the OUTPUT clause supports a second column prefix-DELETED. The DELETED prefix returns the values that have been deleted from a table.

This is important because an UPDATE operation is actually two operations-a deletion and an insertion. As a result, you use both the INSERTED and DELETED column prefixes when adding an OUTPUT clause to an UPDATE statement. Let’s look at a few examples to demonstrate how this works.
*/

-- declare @UpdateOutput1 table variable  
DECLARE @UpdateOutput1 table
(
  OldBookID int,
  NewBookID int,
  BookTitle nvarchar(50),
  OldModifiedDate datetime,
  NewModifiedDate datetime
);
 
-- update row in Books table
UPDATE Books
SET 
  BookID = 105,
  ModifiedDate = GETDATE()
OUTPUT
    DELETED.BookID,
    INSERTED.BookID,
    INSERTED.BookTitle,
    DELETED.ModifiedDate,
    INSERTED.ModifiedDate
  INTO @UpdateOutput1
WHERE BookTitle = 'Mrs. Dalloway';
 
-- view updated row in Books table
SELECT * FROM Books;
 
-- view output row in @UpdateOutput1 variable
SELECT * FROM @UpdateOutput1;



-- declare @UpdateOutput1 table variable  
DECLARE @UpdateOutput2 table
(
  OldBookID int,
  NewBookID int,
  BookTitle nvarchar(50),
  OldModifiedDate datetime,
  NewModifiedDate datetime,
  DiffInSeconds int
);
 
-- update row in Books table
UPDATE Books
SET 
  BookID = BookID + 1,
  ModifiedDate = GETDATE()
OUTPUT
    DELETED.BookID,
    INSERTED.BookID,
    INSERTED.BookTitle,
    DELETED.ModifiedDate,
    INSERTED.ModifiedDate,
    DATEDIFF(ss, DELETED.ModifiedDate, INSERTED.ModifiedDate)
  INTO @UpdateOutput2
WHERE BookTitle = 'Mrs. Dalloway';
 
-- view updated row in Books table
SELECT * FROM Books;
 
-- view output row in @UpdateOutput2 variable
SELECT * FROM @UpdateOutput2;



-- declare @DeleteOutput1 table variable  
DECLARE @DeleteOutput1 table
(
  BookID int,
  BookTitle nvarchar(50),
  ModifiedDate datetime
);
 
-- delete row in Books table
DELETE Books
OUTPUT DELETED.*
  INTO @DeleteOutput1
WHERE BookID = 106;
 
-- view updated row in Books table
SELECT * FROM Books;
 
-- view output row in @DeleteOutput1 variable
SELECT * FROM @DeleteOutput1;



-- declare @DeleteOutput2 table variable  
DECLARE @DeleteOutput2 table
(
  BookID int,
  BookTitle nvarchar(50),
  ModifiedDate datetime
);
 
-- delete row in Books table
DELETE Books
OUTPUT 
    DELETED.BookID,
    DELETED.BookTitle,
    DELETED.ModifiedDate
  INTO @DeleteOutput2
WHERE BookID = 103;
 
-- view updated row in Books table
SELECT * FROM Books;
 
-- view output row in @DeleteOutput2 variable
SELECT * FROM @DeleteOutput2;





-- declare @DeleteOutput2 table variable  
DECLARE @DeleteOutput3 table
(
  BookID int,
  BookTitle nvarchar(50),
  ModifiedDate datetime
);
 
-- delete row in Books table
DELETE Books
OUTPUT 
    DELETED.BookID,
    DELETED.BookTitle,
    DELETED.ModifiedDate
  INTO @DeleteOutput3
OUTPUT 
    DELETED.BookID,
    DELETED.BookTitle
WHERE BookID = 103;
 
-- view updated row in Books table
SELECT * FROM Books;
 
-- view output row in @DeleteOutput3 variable
SELECT * FROM @DeleteOutput3;





-- create second table and populate  
IF OBJECT_ID ('Books2', 'U') IS NOT NULL
DROP TABLE dbo.Books2;
 
CREATE TABLE dbo.Books2
(
  BookID int NOT NULL PRIMARY KEY,
  BookTitle nvarchar(50) NOT NULL,
  ModifiedDate datetime NOT NULL
);
 
INSERT INTO Books2 VALUES(101, '100 Years of Solitude', GETDATE());
INSERT INTO Books2 VALUES(102, 'Pride & Prejudice', GETDATE());

--Once we've created the Books2 table, we can try a MERGE statement. 
-- In the following example, I declare the @MergeOutput1 variable, 
-- merge data from the Books table into the Books2 table, and view the results:
			
-- declare @MergeOutput1 table variable
DECLARE @MergeOutput1 table
(
  ActionType nvarchar(10),
  BookID int,
  OldBookTitle nvarchar(50),
  NewBookTitle nvarchar(50),
  ModifiedDate datetime
);
 
-- use MERGE statement to perform update on Book2
MERGE Books2 AS b2 
USING Books AS b1
ON (b2.BookID = b1.BookID)
WHEN MATCHED
THEN UPDATE SET b2.BookTitle = b1.BookTitle
OUTPUT
    $action,
    INSERTED.BookID,
    DELETED.BookTitle,
    INSERTED.BookTitle,
    INSERTED.ModifiedDate
  INTO @MergeOutput1;
 
-- view Books table
SELECT * FROM Books;
 
-- view updated rows in Books2 table
SELECT * FROM Books2;
 
-- view output rows in @MergeOutput1 variable
SELECT * FROM @MergeOutput1;


