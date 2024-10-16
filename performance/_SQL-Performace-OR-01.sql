/*
http://educator.xello.world/api/institutions/17176/groups/false?OB=asc&S=0&SB=groupName&T=25&timestamp=1599665688978
POST Institutions/GetGroupsByInstitutionIdAsync [includeDynamicGroup/institutionId]
instId = 8449 , edId = 1
*/

Declare
	@InstitutionId INTEGER = 17176,
	@Educatorid INTEGER = 95839,
	@TranslationLanguageID INTEGER = 1,
	@Top INTEGER = 25,
	@Skip INTEGER = 0,
	@OrderBy VARCHAR(255) = 'groupName',
	@OrderDirection VARCHAR(255) = 'ASC',
	@IncludeCount BIT = 1,
	@IncludeDynamicGroups BIT = 0

declare @Filters FilterList 

declare @count INT, @totalTime INT, @StartTime DateTime2, @sql varchar(3000)
-- init
SELECT @count = 0, @StartTime = SysUTCDateTime()

exec School.GroupGetTableByInstitutionId_AllPublic
	@InstitutionId, @Educatorid, @TranslationLanguageID, @Top, @Skip, @OrderBy, @OrderDirection, @Filters, @IncludeCount, @IncludeDynamicGroups

set @totalTime = DateDiff(millisecond, @StartTime, SysUTCDateTime())
Print '>     script run - Time taken was ' + cast(FORMAT(@totalTime, 'N0') as varchar) + ' ms'

SELECT @count = 0, @StartTime = SysUTCDateTime()

exec School.GroupGetTableByInstitutionId_AllPublic_v1
	@InstitutionId, @Educatorid, @TranslationLanguageID, @Top, @Skip, @OrderBy, @OrderDirection, @Filters, @IncludeCount, @IncludeDynamicGroups

set @totalTime = DateDiff(millisecond, @StartTime, SysUTCDateTime())
Print '>     script run - Time taken was ' + cast(FORMAT(@totalTime, 'N0') as varchar) + ' ms'


go



SET NOCOUNT ON; 
-- change here:
declare @loops INT = 100
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

/*
>     script 0 run 100 x times - Time taken was 208,140 ms
>     script 1 run 100 x times - Time taken was 8,219 ms
*/