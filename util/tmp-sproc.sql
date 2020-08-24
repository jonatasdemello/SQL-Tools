IF EXISTS(SELECT * FROM sys.procedures sp WHERE sp.name = '#InspireSchoolCreateWithConstantId')
BEGIN
	DROP PROCEDURE #InspireSchoolCreateWithConstantId;
END
GO

select OBJECT_ID('tempdb..#InspireSchoolCreateWithConstantId')

SELECT * FROM sys.procedures sp WHERE sp.name = '#InspireSchoolCreateWithConstantId'

CREATE PROCEDURE #InspireSchoolCreateWithConstantId
AS 
BEGIN
	select 'OK'
END

exec #InspireSchoolCreateWithConstantId


-- Create test temp. proc
CREATE PROC #tempMyProc as
Begin
 print 'Temp proc'
END
GO
-- Drop the above proc
IF OBJECT_ID('tempdb..#InspireSchoolCreateWithConstantId') IS NOT NULL
BEGIN
    DROP PROC #tempMyProc
END