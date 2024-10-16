select Name from sys.schemas order by 1

SELECT TOP (100) * FROM INFORMATION_SCHEMA.TABLES order by TABLE_SCHEMA, TABLE_NAME
SELECT TOP (100) * FROM INFORMATION_SCHEMA.ROUTINES order by ROUTINE_SCHEMA, ROUTINE_NAME

--Tables + Views
SELECT TOP (100) * FROM INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA like 'Esignature' order by TABLE_SCHEMA, TABLE_NAME
SELECT TOP (100) * FROM INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA like 'Family' order by TABLE_SCHEMA, TABLE_NAME
SELECT TOP (100) * FROM INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA like 'Gate' order by TABLE_SCHEMA, TABLE_NAME
SELECT TOP (100) * FROM INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA like 'Resume' order by TABLE_SCHEMA, TABLE_NAME
SELECT TOP (100) * FROM INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA like 'Spark' order by TABLE_SCHEMA, TABLE_NAME

-- Stored Procedures
SELECT TOP (100) ROUTINE_SCHEMA, ROUTINE_NAME, ROUTINE_TYPE FROM INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA like 'Esignature' order by ROUTINE_NAME
SELECT TOP (100) ROUTINE_SCHEMA, ROUTINE_NAME, ROUTINE_TYPE FROM INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA like 'Family' order by ROUTINE_TYPE, ROUTINE_NAME
SELECT TOP (100) ROUTINE_SCHEMA, ROUTINE_NAME, ROUTINE_TYPE FROM INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA like 'Gate' order by ROUTINE_NAME
SELECT TOP (100) ROUTINE_SCHEMA, ROUTINE_NAME, ROUTINE_TYPE FROM INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA like 'Resume' order by ROUTINE_NAME
SELECT TOP (100) ROUTINE_SCHEMA, ROUTINE_NAME, ROUTINE_TYPE FROM INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA like 'Spark' order by ROUTINE_NAME




-- remove
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Spark].[udf_K2EpisodeGet]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
    drop FUNCTION Spark.udf_K2EpisodeGet

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Spark].[udf_K2FlagGet]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
    drop FUNCTION Spark.udf_K2FlagGet

exec [Utility].[DeleteStoredProcedure] @SchemaName = 'Spark', @RoutineName = 'K2FlagSave'
exec [Utility].[DeleteStoredProcedure] @SchemaName = 'Spark', @RoutineName = 'K2UserGetByUserName_v1'
exec [Utility].[DeleteStoredProcedure] @SchemaName = 'Spark', @RoutineName = 'MyGoalCreateNewStep'
exec [Utility].[DeleteStoredProcedure] @SchemaName = 'Spark', @RoutineName = 'MyGoalDeleteStep'
exec [Utility].[DeleteStoredProcedure] @SchemaName = 'Spark', @RoutineName = 'MyGoalStepSave_v1'
exec [Utility].[DeleteStoredProcedure] @SchemaName = 'Spark', @RoutineName = 'MyGoalUpdateStep'
exec [Utility].[DeleteStoredProcedure] @SchemaName = 'Spark', @RoutineName = 'StudentProgressTableByPortfolioId1'
exec [Utility].[DeleteStoredProcedure] @SchemaName = 'Spark', @RoutineName = 'StudentProgressAllGradesByPortfolioId'

exec [Utility].[DeleteStoredProcedure] @SchemaName = 'Resume', @RoutineName = 'DeleteResume'
exec [Utility].[DeleteStoredProcedure] @SchemaName = 'Resume', @RoutineName = 'ResumeForProfileGet'

exec [Utility].[DeleteStoredProcedure] @SchemaName = 'Family', @RoutineName = 'ExportData_DEV'
exec [Utility].[DeleteStoredProcedure] @SchemaName = 'Family', @RoutineName = 'ParentsWithStudentsGet'
exec [Utility].[DeleteStoredProcedure] @SchemaName = 'Family', @RoutineName = 'FamilyGetTableByInstitutionId_DEV'
exec [Utility].[DeleteStoredProcedure] @SchemaName = 'Family', @RoutineName = 'FamilyGetTableByInstitutionId_v1'
exec [Utility].[DeleteStoredProcedure] @SchemaName = 'Family', @RoutineName = 'GetTableV2'
exec [Utility].[DeleteStoredProcedure] @SchemaName = 'Family', @RoutineName = 'StudentProfileGetByPortfolioId'



select * from Esignature.SignatureStatus
exec sp_help 'Esignature.SignatureStatus'

EXEC sp_fkeys @pktable_name = 'SignatureStatus', @pktable_owner = 'Esignature'


-- columns
SELECT TOP (100) t1.TABLE_SCHEMA, t1.TABLE_NAME , t2.TABLE_NAME
FROM Local_DB_dev.INFORMATION_SCHEMA.TABLES T1
left join tmp_Local_DB_jm. INFORMATION_SCHEMA.TABLES T2 on t1.TABLE_NAME = t2.TABLE_NAME
where t1.TABLE_SCHEMA like 'Esignature' 
order by TABLE_SCHEMA, t1.TABLE_NAME


-- check columns at 'School.SchoolInfo'
SELECT TOP (100) t1.TABLE_SCHEMA, t1.TABLE_NAME, t1.COLUMN_NAME, t2.COLUMN_NAME
FROM Local_DB_dev.INFORMATION_SCHEMA.COLUMNS t1
left join Local_DB_test.INFORMATION_SCHEMA.COLUMNS t2 
    on t1.COLUMN_NAME = t2.COLUMN_NAME AND t1.TABLE_SCHEMA = t2.TABLE_SCHEMA AND t1.TABLE_NAME = t2.TABLE_NAME
where t1.TABLE_NAME = 'SchoolInfo'



exec sp_help 'School.SchoolInfo'

SELECT TOP (100) * FROM School.SchoolInfo





alter table School.SchoolInfo drop CONSTRAINT FK_SchoolInfo_Reference_CoursePlannerSignatureStatusId

alter table School.SchoolInfo drop CONSTRAINT DF__SchoolInf__Cours__4B045FBF
alter table School.SchoolInfo drop CONSTRAINT DF__SchoolInf__AppRe__57696B4D


alter table School.SchoolInfo DROP COLUMN CoursePlannerSignatureStatusId
alter table School.SchoolInfo DROP COLUMN AppResumeIsRequired


drop table Esignature.SignatureStatus

drop view Esignature.vwFourYearCoursePlanParentApproval
drop view Esignature.vwSingleYearCoursePlanParentApproval



SELECT TOP (100) TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA like 'Spark' order by TABLE_SCHEMA, TABLE_NAME

SELECT TOP (100) ROUTINE_SCHEMA, ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA like 'Family' order by ROUTINE_NAME



SELECT TOP (100) * FROM INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA like 'dbo' order by TABLE_SCHEMA, TABLE_NAME
SELECT TOP (100) * FROM INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA like 'CommonApp' order by TABLE_SCHEMA, TABLE_NAME
SELECT TOP (100) * FROM INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA like 'CommonApp' and TABLE_NAME like '%bak20%'
order by TABLE_SCHEMA, TABLE_NAME

SELECT TOP (100) * FROM INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA like 'CCMR' order by TABLE_SCHEMA, TABLE_NAME

SELECT TOP (100) * FROM INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA like 'TestScore' order by TABLE_SCHEMA, TABLE_NAME

SELECT TOP (100) * FROM INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA like 'TestScore' and TABLE_NAME like 'UploadTemp_%'
order by TABLE_SCHEMA, TABLE_NAME

SELECT distinct TABLE_SCHEMA FROM INFORMATION_SCHEMA.TABLES order by TABLE_SCHEMA

SELECT TOP (100) * FROM Ccmr.UploadTemp_2582
drop table Ccmr.UploadTemp_2582

-- old table
SELECT TOP (100) * FROM datamerging.MergingLog

-- new: details
SELECT TOP (100) * FROM datamerging.MergingLogError order by 1 desc

SELECT TOP (100) * FROM datamerging.MergingLogCareer order by 1 desc
SELECT TOP (100) * FROM datamerging.MergingLogSchool order by 1 desc
SELECT TOP (100) * FROM datamerging.MergingLogStudy order by 1 desc
SELECT TOP (100) * FROM datamerging.MergingLogCollegeSuccess order by 1 desc


SELECT TOP (100) * FROM [dbo].[GeneralSetting] 

SELECT TOP (100) * FROM Student.StudentProfile where PortfolioId> 1

exec Family.StudentProfileGetByPortfolioId 16222725

drop PROCEDURE Family.StudentProfileGetByPortfolioId 