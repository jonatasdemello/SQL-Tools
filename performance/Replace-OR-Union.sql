/*
https://decipherinfosys.wordpress.com/2007/08/29/bind-variables-usage-parameterized-queries-in-sql-server/

https://blog.sqlauthority.com/2020/02/10/sql-server-top-reasons-for-slow-performance/



The SQL Server AND operator takes precedence over the SQL Server OR operator 
(just like a multiplication operation takes precedence over an addition operation).

And has precedence over Or, so, even if a <=> a1 Or a2

	Where a And b 

is not the same as

	Where a1 Or a2 And b,

because that would be Executed as

	Where a1 Or (a2 And b)

and what you want, to make them the same, is the following (using parentheses to override rules of precedence):

	Where (a1 Or a2) And b
 
 */

[Student].[StudentProfile].[PortfolioId] as [sp].[PortfolioId]=[dbo].[udf_GetGroupMembers].[PortfolioId] as [gs].[PortfolioId] 

AND (
	[School].[Assignment].[GradeRangeId] as [a].[GradeRangeId]=(3) 
	AND [Student].[StudentProfile].[GradeId] as [sp].[GradeId]>=(3) AND [Student].[StudentProfile].[GradeId] as [sp].[GradeId]<=(5) 
	
	OR [School].[Assignment].[GradeRangeId] as [a].[GradeRangeId]=(4) AND [Student].[StudentProfile].[GradeId] as [sp].[GradeId]>=(6)
	)
	
	

-- K5-2953 Fixed issue with K-2 students assigned to assignments #3415
	-- https://github.com/CareerCruising/CC3_Database/pull/3415/files


select top 10 * FROM School.[Group] g

select top 10 * FROM School.[Group] g
	LEFT JOIN School.InstitutionEducator ie ON (ie.InstitutionEducatorId = g.InstitutionEducatorId)	
	
	AND ( a.GradeRangeId =  dbo.GradeRange.GradeRangeId AND sp.GradeId >= dbo.GradeRange.MinGrade AND  sp.GradeId <= dbo.GradeRange.MaxGrade)


select * from dbo.Grade

select * from dbo.GradeRange
--if a.GradeRangeId = 1 then sp.GradeId BETWEEN 0 AND 14
--if a.GradeRangeId = 2 then sp.GradeId BETWEEN 0 AND 2
--if a.GradeRangeId = 3 then sp.GradeId BETWEEN 3 AND 5
--if a.GradeRangeId = 4 then sp.GradeId BETWEEN 6 AND 14

select top 10 * FROM School.[Group] g

select top 10 * FROM School.[Group] g
	LEFT JOIN School.InstitutionEducator ie ON (ie.InstitutionEducatorId = g.InstitutionEducatorId)	


alter table dbo.GradeRange Add
	MinGrade INT NULL,
	MaxGrade INT NULL

select * from dbo.GradeRange
update dbo.GradeRange set MinGrade = 0, MaxGrade = 14 where GradeRangeId = 1
update dbo.GradeRange set MinGrade = 0, MaxGrade = 2 where GradeRangeId = 2
update dbo.GradeRange set MinGrade = 3, MaxGrade = 5 where GradeRangeId = 3
update dbo.GradeRange set MinGrade = 6, MaxGrade = 14 where GradeRangeId = 4


AND ( a.GradeRangeId =  dbo.GradeRange.GradeRangeId AND sp.GradeId >=  dbo.GradeRange.MinGrade AND  sp.GradeId <= dbo.GradeRange.MaxGrade)





-- removing OR statements to improve performance #3362
	-- https://github.com/CareerCruising/CC3_Database/pull/3362

	



-- applied UNION #3414
	-- https://github.com/CareerCruising/CC3_Database/pull/3414/files


--before:
SELECT GroupId
   FROM School.[Group] AS g
   WHERE g.IsDynamicGroup = 1
		 AND g.InstitutionId = @demoStudentSchoolId
		 OR (g.InstitutionId IN (SELECT InstitutionId FROM dbo.udf_GetParentRegions(@demoStudentSchoolId)))
		AND g.GroupName = 'DYNAMIC_GROUP_' + @demoStudentGrade + '_STUDENTS';


--after:
SELECT GroupId
   FROM School.[Group] AS g
   WHERE g.IsDynamicGroup = 1
		 AND g.GroupName = 'DYNAMIC_GROUP_' + @demoStudentGrade + '_STUDENTS'
		 AND g.InstitutionId = @demoStudentSchoolId
UNION
SELECT GroupId
   FROM School.[Group] AS g
   WHERE g.IsDynamicGroup = 1
		 AND g.GroupName = 'DYNAMIC_GROUP_' + @demoStudentGrade + '_STUDENTS'
		 AND g.InstitutionId IN (SELECT InstitutionId FROM dbo.udf_GetParentRegions(@demoStudentSchoolId));


-- removing OR statements to improve performance #3362
	-- https://github.com/CareerCruising/CC3_Database/pull/3362

--before:
	IF EXISTS (SELECT * FROM dbo.UserAccount ua WHERE ua.PendingUserName = @Email)
	BEGIN
		SELECT @ReturnCode = 3
	END
	ELSE IF EXISTS (SELECT * FROM Student.StudentProfile sp 
		INNER JOIN UserAccount ua on ua.UserAccountId = sp.UserAccountId WHERE sp.EmailAddress = @Email OR sp.[PersonalEmailAddress] = @Email OR ua.UserName = @Email)
	BEGIN
		SELECT @ReturnCode = 4
	END
	ELSE IF NOT EXISTS (SELECT * FROM dbo.UserAccount ua WHERE ua.UserName = @Email)
	BEGIN
		SELECT @ReturnCode = 1
	END 
	ELSE IF NOT EXISTS (SELECT * FROM dbo.UserAccount ua 
					INNER JOIN dbo.UserAccountUserType uaut1 ON ua.UserAccountId=uaut1.UserAccountId
					INNER JOIN dbo.UserAccountUserType uaut2 ON ua.UserAccountId=uaut2.UserAccountId
				WHERE ua.UserName=@Email AND uaut1.UserTypeId = 3 AND uaut2.UserTypeId = 4)
	BEGIN
		-- Doesn't exist UserAccount with given Email such as that it has entries for both UserTypeId=3 (Inspire) and UserTypeId=4 (Educator) - meaning that we can create account for missing app
		SELECT @ReturnCode = 2
	END
	
--after:
	IF EXISTS (SELECT * FROM dbo.UserAccount ua WHERE ua.PendingUserName = @Email)  
	BEGIN  
		SELECT @ReturnCode = 3  
	END  
	-- Student ua.UserName  
	ELSE IF EXISTS (SELECT * FROM Student.StudentProfile sp INNER JOIN UserAccount ua on ua.UserAccountId = sp.UserAccountId WHERE ua.UserName = @Email)  
	BEGIN  
		SELECT @ReturnCode = 4  
	END  
	-- Student sp.EmailAddress  
	ELSE IF EXISTS (SELECT * FROM Student.StudentProfile sp INNER JOIN UserAccount ua on ua.UserAccountId = sp.UserAccountId WHERE sp.EmailAddress = @Email)  
	BEGIN  
		SELECT @ReturnCode = 4  
	END  
	-- Student Personal Email Address  
	ELSE IF EXISTS (SELECT * FROM Student.StudentProfile sp INNER JOIN UserAccount ua on ua.UserAccountId = sp.UserAccountId WHERE sp.[PersonalEmailAddress] = @Email)  
	BEGIN  
		SELECT @ReturnCode = 4  
	END  
	ELSE IF NOT EXISTS (SELECT * FROM dbo.UserAccount ua WHERE ua.UserName = @Email)  
	BEGIN  
		SELECT @ReturnCode = 1  
	END   
	ELSE IF NOT EXISTS (SELECT * FROM dbo.UserAccount ua   
		INNER JOIN dbo.UserAccountUserType uaut1 ON ua.UserAccountId=uaut1.UserAccountId  
		INNER JOIN dbo.UserAccountUserType uaut2 ON ua.UserAccountId=uaut2.UserAccountId  
	WHERE ua.UserName=@Email AND uaut1.UserTypeId = 3 AND uaut2.UserTypeId = 4)  
	BEGIN  
		-- Doesn't exist UserAccount with given Email such as that it has entries for both UserTypeId=3 (Inspire) and UserTypeId=4 (Educator) - meaning that we can create account for missing app  
		SELECT @ReturnCode = 2  
	END  
	