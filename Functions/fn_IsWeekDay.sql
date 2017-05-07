create function fn_IsWeekDay 
(
    @date datetime 
)
returns bit 
as 
begin 

    declare @dtfirst int
    declare @dtweek int 
    declare @iswkday bit 

    set @dtfirst = @@datefirst - 1
    set @dtweek = datepart(weekday, @date) - 1

    if (@dtfirst + @dtweek) % 7 not in (5, 6)
        set @iswkday = 1 --business day
    else
        set @iswkday = 0 --weekend

    return @iswkday
end