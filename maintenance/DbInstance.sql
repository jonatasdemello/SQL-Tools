-- Determine CountryId and TranslationLanguageId from DbInstance
DECLARE
	@CountryId INT = 1,
	@TranslationLanguageId INT = 1

 SELECT @CountryId = CASE WHEN dbi.DBInstanceId = 2 THEN 184 ELSE 1 END -- UK else CA
	FROM dbo.CurrentDBInstance dbi

SELECT @TranslationLanguageId = CASE WHEN @CountryId = 184 THEN 8 ELSE 1 END 

-------------------------------------------------------------------------------------------------------------------------------
