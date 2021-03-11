use PROGRAMAR

/*
JOIN operations in SQL Server are used to join two or more tables. 

However, JOIN operations cannot be used to join a table with the output of a table valued function. 

The CROSS APPLY operator is semantically similar to INNER JOIN operator. 
It retrieves those records from the table valued function and the table being joined, 
where it finds matching rows between the two.

On the other hand, 
The OUTER APPLY retrieves all the records from both the table valued function and the table, irrespective of the match. 


CREATE DATABASE Library
GO 
USE Library;
*/

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
 
--USE Library;
 
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

select * from Author
select * from Book

SELECT A.author_name, B.id, B.book_name, B.price
FROM Author A
INNER JOIN Book B ON A.id = B.author_id

SELECT A.author_name, B.id, B.book_name, B.price
FROM Author A
LEFT JOIN Book B ON A.id = B.author_id

-- Joining table valued functions with tables using APPLY operators

-- We saw how JOIN operators join the results from two tables. 
-- However, as mentioned above they cannot be used to join a table valued function with a table. 
-- A table valued function is a function that returns records in the form of a table. 

CREATE FUNCTION fnGetBooksByAuthorId(@AuthorId int)
RETURNS TABLE
AS
RETURN
( 
	SELECT * FROM Book
	WHERE author_id = @AuthorId
)

-- test it
SELECT * FROM fnGetBooksByAuthorId(3)

-- Let’s try to use an INNER JOIN operator to join the Author table with the table valued function fnGetBooksByAuthorId. 
SELECT A.author_name, B.id, B.book_name, B.price
FROM Author A
INNER JOIN fnGetBooksByAuthorId(A.Id) B ON A.id = B.author_id

-- error: The multi-part identifier "A.Id" could not be bound.

SELECT A.author_name, B.id, B.book_name, B.price
FROM Author A
	CROSS APPLY fnGetBooksByAuthorId(A.Id) B
	-- CROSS APPLY is similar to INNER JOIN

-- Joining table and table valued functions using OUTER APPLY
-- To retrieve all the rows from both the physical table and the output of the table valued function, OUTER APPLY is used. OUTER APPLY is semantically similar to the OUTER JOIN operation. 

SELECT A.author_name, B.id, B.book_name, B.price
FROM Author A
	OUTER APPLY fnGetBooksByAuthorId(A.Id) B
	-- OUTER APPLY is similar to LEFT OUTER JOIN


/*
SQL Server APPLY operator has two variants; CROSS APPLY and OUTER APPLY

    The CROSS APPLY operator returns only those rows from the left table expression (in its final output) if it matches with the right table expression. In other words, the right table expression returns rows for the left table expression match only.
    The OUTER APPLY operator returns all the rows from the left table expression irrespective of its match with the right table expression. For those rows for which there are no corresponding matches in the right table expression, it contains NULL values in columns of the right table expression.
    So you might conclude, the CROSS APPLY is equivalent to an INNER JOIN (or to be more precise its like a CROSS JOIN with a correlated sub-query) with an implicit join condition of 1=1 whereas the OUTER APPLY is equivalent to a LEFT OUTER JOIN.
*/

IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[Employee]') AND type IN (N'U')) 
BEGIN 
   DROP TABLE [Employee] 
END 
GO 

IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[Department]') AND type IN (N'U')) 
BEGIN 
   DROP TABLE [Department] 
END 

CREATE TABLE [Department]( 
   [DepartmentID] [int] NOT NULL PRIMARY KEY, 
   [Name] VARCHAR(250) NOT NULL, 
) ON [PRIMARY] 

INSERT [Department] ([DepartmentID], [Name])  VALUES (1, N'Engineering') 
INSERT [Department] ([DepartmentID], [Name])  VALUES (2, N'Administration') 
INSERT [Department] ([DepartmentID], [Name])  VALUES (3, N'Sales') 
INSERT [Department] ([DepartmentID], [Name])  VALUES (4, N'Marketing') 
INSERT [Department] ([DepartmentID], [Name])  VALUES (5, N'Finance') 
GO 

CREATE TABLE [Employee]( 
   [EmployeeID] [int] NOT NULL PRIMARY KEY, 
   [FirstName] VARCHAR(250) NOT NULL, 
   [LastName] VARCHAR(250) NOT NULL, 
   [DepartmentID] [int] NOT NULL REFERENCES [Department](DepartmentID), 
) ON [PRIMARY] 
GO
 
INSERT [Employee] ([EmployeeID], [FirstName], [LastName], [DepartmentID]) VALUES (1, N'Orlando', N'Gee', 1 ) 
INSERT [Employee] ([EmployeeID], [FirstName], [LastName], [DepartmentID]) VALUES (2, N'Keith', N'Harris', 2 ) 
INSERT [Employee] ([EmployeeID], [FirstName], [LastName], [DepartmentID]) VALUES (3, N'Donna', N'Carreras', 3 ) 
INSERT [Employee] ([EmployeeID], [FirstName], [LastName], [DepartmentID]) VALUES (4, N'Janet', N'Gates', 3 ) 



select * From [Employee]
select * From [Department]


select * From [Department] D
	LEFT JOIN [Employee] E ON D.DepartmentID = E.DepartmentID

--Script #2 - CROSS APPLY and INNER JOIN

SELECT * FROM Department D 
CROSS APPLY 
( 
	SELECT * FROM Employee E 
	WHERE E.DepartmentID = D.DepartmentID  -- D is outside
) A 
-- similar to INNER JOIN
SELECT * FROM Department D 
INNER JOIN Employee E ON D.DepartmentID = E.DepartmentID 




--Script #3 - OUTER APPLY and LEFT OUTER JOIN

SELECT * FROM Department D 
OUTER APPLY 
   ( 
   SELECT * FROM Employee E 
   WHERE E.DepartmentID = D.DepartmentID 
   ) A 
GO
 
SELECT * FROM Department D 
LEFT OUTER JOIN Employee E ON D.DepartmentID = E.DepartmentID 
GO 


/*
Joining table valued functions and tables using APPLY operators

In Script #4, I am creating a table-valued function which accepts DepartmentID as its parameter and returns all the employees who belong to this department. \
The next query selects data from the Department table and uses a CROSS APPLY to join with the function we created. 
It passes the DepartmentID for each row from the outer table expression 
(in our case Department table) and evaluates the function for each row similar to a correlated subquery. 

The next query uses the OUTER APPLY in place of the CROSS APPLY and hence unlike the CROSS APPLY which returned only correlated data, 
the OUTER APPLY returns non-correlated data as well, placing NULLs into the missing columns.
*/
--Script #4 - APPLY with table-valued function

IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[fn_GetAllEmployeeOfADepartment]') AND type IN (N'IF')) 
BEGIN 
   DROP FUNCTION dbo.fn_GetAllEmployeeOfADepartment 
END 
GO
 
CREATE FUNCTION dbo.fn_GetAllEmployeeOfADepartment(@DeptID AS INT)  
RETURNS TABLE 
AS 
RETURN 
   ( 
   SELECT * FROM Employee E 
   WHERE E.DepartmentID = @DeptID 
   ) 
GO
 
SELECT * FROM Department D 
CROSS APPLY dbo.fn_GetAllEmployeeOfADepartment(D.DepartmentID) -- D is each row from above
GO
 
SELECT * FROM Department D 
OUTER APPLY dbo.fn_GetAllEmployeeOfADepartment(D.DepartmentID) 
GO 




select * From [Employee]
select * From [Department]

-- Sales has 2 employees
select * From [Department] D
cross apply ( select * from [Employee] E where E.DepartmentID = D.DepartmentID ) X

-- only the first employee from the department
select * From [Department] D
cross apply ( select top 1 * from [Employee] E where E.DepartmentID = D.DepartmentID ) X


-- https://explainextended.com/2009/07/16/inner-join-vs-cross-apply/
