create function dbo.fn_WeekDayBR
(  
    @weekday varchar(30)
)  
returns varchar(30)   
as   
begin   
	declare @day varchar(30)
	declare @tmp varchar(30)

	select @day = Upper(@weekday)

	if @weekday = 'Monday'
		SELECT @tmp = 'segunda-feira'
	if @weekday = 'Tuesday'
		SELECT @tmp = 'terça-feira'
	if @weekday = 'Wednesday'
		SELECT @tmp = 'quarta-feira'
	if @weekday = 'Thursday'
		SELECT @tmp = 'quinta-feira'
	if @weekday = 'Friday'
		SELECT @tmp = 'sexta-feira'
	if @weekday = 'Saturday'
		SELECT @tmp = 'sábado'
	if @weekday = 'Sunday'
		SELECT @tmp = 'domingo'

    RETURN @tmp  
END  

GO

grant execute on dbo.fn_WeekDayBR to public

GO

SELECT DATENAME(year, '12:10:30.123')
    ,DATENAME(month, '12:10:30.123')
    ,DATENAME(day, '12:10:30.123')
    ,DATENAME(dayofyear, '12:10:30.123')
    ,DATENAME(weekday, '12:10:30.123');

select DATENAME(weekday, getdate());

SET LANGUAGE Portuguese
select DATENAME(weekday, '2011-12-05');

select getdate()

SET LANGUAGE Brazilian
SET LANGUAGE English

sp_helplanguage English


fn_IsWeekDay
fn_TiraAcento

select dbo.fn_WeekDayBR(DATENAME(weekday, '2011-12-07'));

select dbo.fn_WeekDayBR(DATENAME(weekday, '2011-12-07'));

drop function dbo.fn_WeekDayBR


