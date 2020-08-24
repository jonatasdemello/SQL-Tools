SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;

-- Indexes

IF EXISTS(
    SELECT i.name, o.name, s.name
    FROM sys.indexes i
    INNER JOIN sys.objects o ON (o.[object_id] = i.[object_id])
    INNER JOIN sys.schemas s ON (s.[schema_id] = o.[schema_id])
    WHERE s.name = 'Student' AND o.name = 'Career' AND i.name = 'IX_Student_Career_PortfolioId_IsSaved'
)
BEGIN

	DROP INDEX Student.Career.[IX_Student_Career_PortfolioId_IsSaved] --ON Student.Career (PortfolioId, IsSaved)
END
GO

IF EXISTS(
    SELECT i.name, o.name, s.name
    FROM sys.indexes i
    INNER JOIN sys.objects o ON (o.[object_id] = i.[object_id])
    INNER JOIN sys.schemas s ON (s.[schema_id] = o.[schema_id])
    WHERE s.name = 'School' AND o.name = 'EducatorStudent' AND i.name = 'IX_EducatorStudent_EducatorIdPortfolioId_ApprovalStatus'
)
BEGIN
    DROP INDEX School.EducatorStudent.IX_EducatorStudent_EducatorIdPortfolioId_ApprovalStatus --ON School.EducatorStudent (ApprovalStatus) INCLUDE (PortfolioId)
END
GO

