
-- Debug TableType Parameter
declare @p3 dbo.RelatedCareerType
insert into @p3 values(3,177)
insert into @p3 values(3,435)
insert into @p3 values(3,431)

select * from @p3
exec [Spark].[SaveRelatedCareer] @CareerId=3,@TranslationLanguageId=1,@RelatedCareerList=@p3

select * from Spark.RelatedCareer rc where rc.BaseCareerId = 3



insert into @p3 values(6,1)
--insert into @p3 values(2,2)
--insert into @p3 values(3,3)
insert into @p3 values(4,1)

select * from @p3
exec [Spark].[SchoolSubjectSaveList] @PortfolioId = 583161, @SchoolSubjectList = @p3

select * from [Spark].[SchoolSubjectSelection]





EXEC dbo.ProvisionSproc 'Spark', 'SchoolSubjectSaveList';
GO

ALTER PROCEDURE [Spark].[SchoolSubjectSaveList]
(
	@PortfolioId INT,
	@SchoolSubjectList [IdValueList] READONLY
)
AS
BEGIN
--	SET NOCOUNT ON;
	
DECLARE @MergeOutput TABLE
(
	ActionType NVARCHAR(10),
	SchoolSubjectId INT,
	SortOrder INT
)

	MERGE 
		[Spark].[SchoolSubjectSelection] AS [Target]
	USING 
		@SchoolSubjectList AS [Source]
	ON 
		[Target].SchoolSubjectId = [Source].Id AND 
		[Target].PortfolioId = @PortfolioId
	
	WHEN MATCHED THEN
		UPDATE SET 
			[Target].SortOrder = [Source].[Value]

	WHEN NOT MATCHED BY TARGET THEN
		INSERT (PortfolioId, SchoolSubjectId, SortOrder)
		VALUES (@PortfolioId, [Source].Id, [Source].[Value])

	WHEN NOT MATCHED BY SOURCE 
		AND [Target].PortfolioId = @PortfolioId THEN
		DELETE
		
OUTPUT
    $action,
    DELETED.SchoolSubjectId,
    DELETED.SortOrder
  INTO @MergeOutput
  ;
  SELECT * FROM @MergeOutput;
END
GO

