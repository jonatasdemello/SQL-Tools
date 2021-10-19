-- https://www.sqlshack.com/the-difference-between-cross-apply-and-outer-apply-in-sql-server/


CREATE DATABASE Library
 
GO 
 
USE Library;
 
CREATE TABLE Author
(
    id INT PRIMARY KEY,
    author_name VARCHAR(50) NOT NULL,
    
 )
 
CREATE TABLE Book
(
    id INT PRIMARY KEY,
    book_name VARCHAR(50) NOT NULL,
    price INT NOT NULL,
    author_id INT NOT NULL
   
 )
 
USE Library;
 
 INSERT INTO Author 
 
VALUES
(1, 'Author1'),
(2, 'Author2'),
(3, 'Author3'),
(4, 'Author4'),
(5, 'Author5'),
(6, 'Author6'),
(7, 'Author7')
 
 
INSERT INTO Book 
 
VALUES
(1, 'Book1',500, 1),
(2, 'Book2', 300 ,2),
(3, 'Book3',700, 1),
(4, 'Book4',400, 3),
(5, 'Book5',650, 5),
(6, 'Book6',400, 3)


--Let’s first use the INNER JOIN operator to retrieve matching rows from both of the tables.  
SELECT A.author_name, B.id, B.book_name, B.price
FROM Author A
INNER JOIN Book B
ON A.id = B.author_id

-- You can see that only those records have been selected from the Author table where there is a matching row in the Book table. To retrieve all the records from Author table, LEFT JOIN can be used. 

SELECT A.author_name, B.id, B.book_name, B.price
FROM Author A
LEFT JOIN Book B
ON A.id = B.author_id

-- We saw how JOIN operators join the results from two tables. However, as mentioned above they cannot be used to join a table valued function with a table. A table valued function is a function that returns records in the form of a table. 

-- Let’s first write a simple table valued function that accepts author id as parameter and returns all the books written by that author.
	
CREATE FUNCTION fnGetBooksByAuthorId(@AuthorId int)
RETURNS TABLE
AS
RETURN
( 
SELECT * FROM Book
WHERE author_id = @AuthorId
)

	
SELECT * FROM fnGetBooksByAuthorId(3)

 -- Let’s try to use an INNER JOIN operator to join the Author table with the table valued function fnGetBooksByAuthorId.

SELECT A.author_name, B.id, B.book_name, B.price
FROM Author A
INNER JOIN fnGetBooksByAuthorId(A.Id) B
ON A.id = B.author_id

-- Here we are using the INNER JOIN operator to join a physical table (Author) with a table valued function fnGetBooksByAuthorId. All the ids from the Author table are passed to the function. However, the script above throws an error which looks like this: 

SELECT A.author_name, B.id, B.book_name, B.price
FROM Author A
CROSS APPLY fnGetBooksByAuthorId(A.Id) B

-- In the script above, all the ids from the Author table are being passed to fnGetBooksByAuthorId function. For each id in the Author table, the function returns corresponding records from the Book table. The result from this table valued function is being joined with the table Author. 

-- This is similar to the INNER JOIN operation performed on the Author and Book tables. CROSS APPLY returns only those records from a physical table where there are matching rows in the output of the table valued function. 

 -- To retrieve all the rows from both the physical table and the output of the table valued function, OUTER APPLY is used. OUTER APPLY is semantically similar to the OUTER JOIN operation.

	
SELECT A.author_name, B.id, B.book_name, B.price
FROM Author A
OUTER APPLY fnGetBooksByAuthorId(A.Id) B


