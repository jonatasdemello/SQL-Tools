
SELECT name, description FROM fn_helpcollations();


-- Find the students taught by Dominick Pope who have a grade higher than 75%
SELECT  person.FirstName, person.LastName, course.Name, credit.Grade
FROM  Person AS person
    INNER JOIN Student AS student ON person.PersonId = student.PersonId
    INNER JOIN Credit AS credit ON student.StudentId = credit.StudentId
    INNER JOIN Course AS course ON credit.CourseId = course.courseId
WHERE course.Teacher = 'Dominick Pope'
    AND Grade > 75


-- Find all the courses in which Noe Coleman has ever enrolled
SELECT  course.Name, course.Teacher, credit.Grade
FROM  Course AS course
    INNER JOIN Credit AS credit ON credit.CourseId = course.CourseId
    INNER JOIN Student AS student ON student.StudentId = credit.StudentId
    INNER JOIN Person AS person ON person.PersonId = student.PersonId
WHERE person.FirstName = 'Noe'
    AND person.LastName = 'Coleman'


-- Restore
USE [master]
RESTORE DATABASE [AdventureWorks2019] 
FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\AdventureWorks2019.bak' 
WITH  FILE = 1,  NOUNLOAD,  STATS = 5
GO


USE [master]
RESTORE DATABASE [AdventureWorks2019]
FROM DISK = '/var/opt/mssql/backup/AdventureWorks2019.bak'
WITH MOVE 'AdventureWorks2017' TO '/var/opt/mssql/data/AdventureWorks2019.mdf',
MOVE 'AdventureWorks2017_log' TO '/var/opt/mssql/data/AdventureWorks2019_log.ldf',
FILE = 1,  NOUNLOAD,  STATS = 5
GO

