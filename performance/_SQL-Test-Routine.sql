-- Test Routine : ------------------------------------------------------------------------

SET NOCOUNT ON; 
-- change here:
declare @loops INT = 700
declare @ver INT = 0

-- here is OK
declare @count INT, @totalTime INT, @StartTime DateTime2, @sql varchar(3000)
-- init
SELECT @count = 0, @StartTime = SysUTCDateTime()
while @count < @loops
begin
	declare @Filters  FILTERLIST
	exec PCS.GradesWithLessonsGetByInstitutionId_v0  2, @Filters

	set @count = @count + 1
end
-- result 
set @totalTime = DateDiff(millisecond, @StartTime, SysUTCDateTime())
Print '>     script '+cast(@ver as varchar)+' run '+ cast(@count as varchar) +' x times - Time taken was ' + cast(FORMAT(@totalTime, 'N0') as varchar) + ' ms'

go 4

-- Test Routine : ------------------------------------------------------------------------
