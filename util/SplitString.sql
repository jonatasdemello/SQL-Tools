create function dbo.SplitString 
(
    @str nvarchar(max), 
    @separator char(1)
)
returns table
AS
return (
with tokens(p, a, b) AS (
    select 
        cast(1 as bigint), 
        cast(1 as bigint), 
        charindex(@separator, @str)
    union all
    select
        p + 1, 
        b + 1, 
        charindex(@separator, @str, b + 1)
    from tokens
    where b > 0
)
select p-1 ItemIndex, substring( @str, a, case when b > 0 then b-a ELSE LEN(@str) end) AS s
from tokens
);

GO

select * from dbo.SplitString('Hello John Smith', ' ') 
	--where zeroBasedOccurance=1

select * from dbo.SplitString(
'Florence Nightingale was born in Italy in 1820. At that time, most rich women did not work. But Florence loved to help people. So she became a nurse.  

In 1854, a war began in Russia. Soldiers were very sick with battle wounds. They were cold and hungry and had no one to take care of them.   

Florence wanted to help, so she came to their rescue! When she arrived, she saw how dirty the hospital was. There were broken toilets and rats running everywhere. It must have been very smelly!

Florence and her nurses cleaned the hospital. They fed the soldiers and dressed their wounds. She visited her patients in bed each night, too.   

Florence saved many soldiers with her care. Because of her work, nurses got proper training. She also helped to make sure hospitals were always clean. Today, she is known as "the founder of modern nursing."',
char(10))