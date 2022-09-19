-- Import from CSV:
GO
CREATE TABLE TMP_CommonAppSchoolDeadline
(
    Id INT,
    MemberId INT,
    DeadlineDate DATETIME2(7),
    DecisionType NVARCHAR(200),
    Term NVARCHAR(200),
    TermTypeId INT
);
GO

BULK INSERT TMP_CommonAppSchoolDeadline
FROM 'C:\Workspace\CMS\!sort\CommonApp\deadlinesResults.csv'
WITH (
    FORMAT = 'CSV'
    -- FIELDTERMINATOR = ',',
    -- ROWTERMINATOR = '\r\n'
    , FIRSTROW = 2
)
GO

SELECT * FROM TMP_CommonAppSchoolDeadline

