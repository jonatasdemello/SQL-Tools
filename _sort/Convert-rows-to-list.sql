/*
http://stackoverflow.com/questions/887628/convert-multiple-rows-into-one-with-comma-as-separator

http://oops-solution.blogspot.ca/2011/11/sql-server-convert-table-column-data.html

http://stackoverflow.com/questions/194852/concatenate-many-rows-into-a-single-text-string
*/


--Here  I am using COALESCE function Sql Server 2005/2008 to convert a field into comma separated value of string or row

--Select query will be:
--Assuming my table name is  #test, It has 2 column field1,field2

SELECT field1,
 SUBSTRING( 
 (
  SELECT ( ',' + field2)
  FROM #test t2 
  WHERE t1.Field1 = t2.Field1
  ORDER BY t1.Field1, t2.Field1
  FOR XML PATH('')
 ), 3, 1000)
FROM #test t1
GROUP BY field1

---If you wish select all the rows of field2 as comma separated list then query will be:

SELECT STUFF( -- Remove first comma
    (
        SELECT  ', ' + field2 FROM -- create comma separated values
        (
          SELECT field2 FROM #test --Your query here
        ) AS T FOR XML PATH('')
    )
    ,1,1,'') AS field2

--OR

DECLARE @test NVARCHAR(max)  
SELECT @test = COALESCE(@test + ',', '') + field2 FROM #test
SELECT field2= @test 


-- OR 
create table #user (username varchar(25))

insert into #user (username) values ('Paul')
insert into #user (username) values ('John')
insert into #user (username) values ('Mary')

declare @tmp varchar(250)
SET @tmp = ''
select @tmp = @tmp + username + ', ' from #user

select SUBSTRING(@tmp, 0, LEN(@tmp))


-- or

select
   distinct  
    stuff((
        select ',' + u.username
        from users u
        where u.username = username
        order by u.username
        for xml path('')
    ),1,1,'') as userlist
from users
group by username


-- or 

DECLARE @categories varchar(200)
SET @categories = NULL

SELECT @categories = COALESCE(@categories + ',','') + Name
FROM Production.ProductCategory

SELECT @categories

-- or

SELECT ',' + Name
FROM Production.ProductCategory
ORDER BY LEN(Name)
FOR XML PATH('') 


-- or 

USE tempdb;
GO
CREATE TABLE t1 (id INT, NAME VARCHAR(MAX));
INSERT t1 values (1,'Jamie');
INSERT t1 values (1,'Joe');
INSERT t1 values (1,'John');
INSERT t1 values (2,'Sai');
INSERT t1 values (2,'Sam');
GO

select
    id,
    stuff((
        select ',' + t.[name]
        from t1 t
        where t.id = t1.id
        order by t.[name]
        for xml path('')
    ),1,1,'') as name_csv
from t1
group by id
; 



--or

DECLARE @EmployeeList varchar(100)

SELECT @EmployeeList = COALESCE(@EmployeeList + ', ', '') + 
   CAST(Emp_UniqueID AS varchar(5))
FROM SalesCallsEmployees
WHERE SalCal_UniqueID = 1

SELECT @EmployeeList
--source: http://www.sqlteam.com/article/using-coalesce-to-build-comma-delimited-string





-- AS AthleticConf
	DECLARE @AthleticConf NVARCHAR(max)  
	SELECT @AthleticConf = COALESCE(@AthleticConf + ', ', '') + --field2 FROM #test
			  cl.CodeDescription --as AthleticConf 
				FROM School.SchoolInfo si
				inner join school.ListSchoolRelation lsr on si.SchoolId = lsr.SchoolId
				inner join cms.codelist cl on cl.CodeListEntryId = lsr.CodeListEntryId 
				WHERE lsr.SchoolId = 1 --@schoolId 
					AND si.TranslationLanguageId = 1 --@translationLanguageId 
					AND (cl.ListTypeId = 87 )
--	SELECT @AthleticConf 


SELECT st.AthleticsDescription AS SportIntro, ss.SportIntro, ss.AthleticConf, ss.Mascot, ss.Colours, 
	@AthleticConf as AthleticConf
FROM School.SchoolText st
	LEFT JOIN [School].[SchoolSports] ss on ss.SchoolId = st.SchoolId
	WHERE st.SchoolId = 3 --@schoolId 
AND st.TranslationLanguageId = 1 --@translationLanguageId 


-- **********************************

		select * From School.SchoolText st
			LEFT JOIN school.ListSchoolRelation lsr on st.schoolid = lsr.schoolid
			where lsr.CodeListEntryId in (18040,18041)

			select * from CMS.CodeList where CodeListEntryId in (18040,18041)

-- AS AthleticConf
SELECT cl.CodeDescription as AthleticConf -- For AthleticConf
	FROM School.SchoolText st
	join school.ListSchoolRelation lsr on st.schoolid = lsr.schoolid
	join cms.codelist cl on cl.CodeListEntryId = lsr.CodeListEntryId 
	WHERE st.SchoolId = 1 --@schoolId 
		AND st.TranslationLanguageId = 1 --@translationLanguageId 
		AND (cl.ListTypeId = 87 )

-- this is OK
	SELECT STUFF( -- Remove first comma
    (
        SELECT  ', ' + AthleticConf FROM -- create comma separated values
        (
          --SELECT field2 FROM #test --Your query here
		  SELECT cl.CodeDescription as AthleticConf 
			FROM School.SchoolInfo si
			inner join school.ListSchoolRelation lsr on si.SchoolId = lsr.SchoolId
			inner join cms.codelist cl on cl.CodeListEntryId = lsr.CodeListEntryId 
			WHERE lsr.SchoolId = 1 --@schoolId 
				AND si.TranslationLanguageId = 1 --@translationLanguageId 
				AND (cl.ListTypeId = 87 )
        ) AS T FOR XML PATH('')
    )
    ,1,1,'') AS AthleticConf

-- this is OK too
	DECLARE @test NVARCHAR(max)  
	SELECT @test = COALESCE(@test + ', ', '') + --field2 FROM #test
			  cl.CodeDescription --as AthleticConf 
				FROM School.SchoolInfo si
				inner join school.ListSchoolRelation lsr on si.SchoolId = lsr.SchoolId
				inner join cms.codelist cl on cl.CodeListEntryId = lsr.CodeListEntryId 
				WHERE lsr.SchoolId = 1 --@schoolId 
					AND si.TranslationLanguageId = 1 --@translationLanguageId 
					AND (cl.ListTypeId = 87 )
	SELECT @test 


SELECT cl.CodeDescription as AthleticConf 
	FROM School.SchoolInfo si
	inner join school.ListSchoolRelation lsr on si.SchoolId = lsr.SchoolId
	inner join cms.codelist cl on cl.CodeListEntryId = lsr.CodeListEntryId 
	WHERE lsr.SchoolId = 1 --@schoolId 
		AND si.TranslationLanguageId = 1 --@translationLanguageId 
		AND (cl.ListTypeId = 87 )

	select * from cms.codelist where ListTypeId = 87
		-- CodeListEntryId

select * from CMS.ListType where ListTypeId = 87 --Athletic Conference Memberships

select * FROM School.SchoolText st where st.SchoolId = 3 

SELECT SchoolSportsId, SchoolId, SportIntro, AthleticConf, Colours, Mascot, CrestImage, HeroImage, MascotFlag, CrestImageFlag, HeroImageFlag
	FROM [School].[SchoolSports]
	WHERE SchoolId = 3 --@SchoolID

-- Athletic Associations
--****************************
SELECT 
	cl.CodeListEntryId AS AthleticAssociationId, cl.CodeDescription AS AthleticAssociationName, lsr.SchoolId
	/*, lsr.CodeListEntryId, cl.TranslationLanguageId */
	FROM [CMS].[CodeList] cl
	LEFT JOIN [School].[ListSchoolRelation] lsr ON lsr.CodeListEntryId = cl.CodeListEntryId --and lsr.SchoolId = 1 --@SchoolId
	WHERE cl.ListTypeId = 87 and lsr.SchoolId = 3
