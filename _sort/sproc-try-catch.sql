EXEC dbo.ProvisionSproc 'schema', 'sprocName';
GO

ALTER PROCEDURE [schema].[sprocName]
(
	@PortfolioId INTEGER,
	@Indicators IndicatorList READONLY
)
AS
BEGIN TRY
	SET NOCOUNT ON;
	BEGIN TRANSACTION;
		
		-- do insert 
		-- do update
		-- do delete

		SELECT @@ROWCOUNT;
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION;
THROW;
END CATCH;
GO
