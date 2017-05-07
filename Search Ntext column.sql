
/* Search text in NTEXT column */


CREATE TABLE TestTable (ID INT, MyText NTEXT)
GO
SELECT ID, MyText
FROM TestTable
WHERE MyText = 'AnyText'
GO

SELECT ID, MyText
FROM TestTable
WHERE MyText = N'AnyText'

DROP TABLE TestTable
GO


--Solution 1: Convert the data types to match with each other using CONVERT function.

--Change the datatype of the MyText to nvarchar.

SELECT ID, MyText
FROM TestTable
WHERE CONVERT(NVARCHAR(MAX), MyText) = N'AnyText'
GO

--Solution 2: Convert the data type of columns from NTEXT to NVARCHAR(MAX) (TEXT to VARCHAR(MAX)

ALTER TABLE TestTable
ALTER COLUMN MyText NVARCHAR(MAX)
GO

--Now you can run the original query again and it will work fine.

--Solution 3: Using LIKE command instead of Equal to command.

SELECT ID, MyText
FROM TestTable
WHERE MyText LIKE 'AnyText'
GO

/*
Well, any of the three of the solutions will work. 
Here is my suggestion if you can change the column data type from ntext or text to nvarchar or varchar, 
you should follow that path as text and ntext datatypes are marked as deprecated. 
All developers any way to change the deprecated data types in future, 
it will be a good idea to change them right early.

If due to any reason you can not convert the original column use Solution 1 for temporary fix. 
Solution 3 is the not the best solution and use it as a last option. 
Did I miss any other method? 
If yes, please let me know and I will add the solution to original blog post with due credit.
*/

SELECT ID, MyText
FROM TestTable
WHERE cast(mytext AS varchar(max))= 'AnyText'


SELECT ID, MyText
FROM TestTable
WHERE SUBSTRING(MyText,0,DATALENGTH(MyText))=N'AnyText'

SELECT ID, MyText
FROM TestTable
WHERE PATINDEX(N'AnyText', MyText) =1

SELECT ID, MyText
FROM TestTable
WHERE CHARINDEX(N'AnyText', MyText) =1 AND DATALENGTH(N'AnyText')=DATALENGTH(MyText)

