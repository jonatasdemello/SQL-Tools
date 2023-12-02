

DECLARE @json NVARCHAR(MAX)

SET @json='{"name":"John","surname":"Doe","age":45,"skills":["SQL","C#","MVC"]}';

SELECT *
FROM OPENJSON(@json);


SELECT BulkColumn
 FROM OPENROWSET (BULK 'C:\JSON\Books\book.json', SINGLE_CLOB) as j;

-- Load file contents into a variable
SELECT @json = BulkColumn
 FROM OPENROWSET (BULK 'C:\JSON\Books\book.json', SINGLE_CLOB) as j

-- Load file contents into a table 
SELECT BulkColumn
 INTO #temp 
 FROM OPENROWSET (BULK 'C:\JSON\Books\book.json', SINGLE_CLOB) as j

SELECT value
 FROM OPENROWSET (BULK 'C:\JSON\Books\books.json', SINGLE_CLOB) as j
 CROSS APPLY OPENJSON(BulkColumn)


SELECT book.*
 FROM OPENROWSET (BULK 'C:\JSON\Books\books.json', SINGLE_CLOB) as j
 CROSS APPLY OPENJSON(BulkColumn)
 WITH( id nvarchar(100), name nvarchar(100), price float,
 pages_i int, author nvarchar(100)) AS book




SELECT BulkColumn
 INTO #temp 
 FROM OPENROWSET (BULK 'C:\temp\CommonApp.json', SINGLE_CLOB) as j

SELECT * from #temp

SELECT value
 FROM OPENROWSET (BULK 'C:\temp\CommonApp.json', SINGLE_CLOB) as j
 CROSS APPLY OPENJSON(BulkColumn)


 SELECT book.*
 FROM OPENROWSET (BULK 'C:\temp\CommonApp.json', SINGLE_CLOB) as j
 CROSS APPLY OPENJSON(BulkColumn)
 WITH(
    	[MemberId] INT,
		[CollegeName] NVARCHAR(300),
		[Address1] NVARCHAR(200),
		[Address2] NVARCHAR(200),
		[City] NVARCHAR(50),
		[State] NVARCHAR(50),
		[Country] NVARCHAR(50),
		[Website] NVARCHAR(300),
		[ContactEmail] NVARCHAR(150),
		[Zip] NVARCHAR(15),
		[Phone] NVARCHAR(20),
		[Fax] NVARCHAR(20),
		[CeebCode] NVARCHAR(10),
		[IpedsCode] NVARCHAR(10),
		[MemberTypeId] INT,
		[ArtsSupplement] INT,
		[MinTeacherEval] INT,
		[MaxTeacherEval] INT,
		[CaEssayReqdFY] BIT,
		[CounselorEvalReqd] BIT,
		[CoursesAndGradesReqd] BIT,
		[MidYearRequired] BIT
    ) AS book
