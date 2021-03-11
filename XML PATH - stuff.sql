-- this will fail
set quoted_identifier OFF

DECLARE @xmlRecords XML
SET     @xmlRecords = '<records><record orderId="1" refCode="1234"></record></records>'

SELECT  records.record.value('(@orderId)[1]', 'INT') AS orderId
FROM    @xmlRecords.nodes('/records/record') records(record)
go

SET QUOTED_IDENTIFIER Off

DECLARE @T TABLE (id VARCHAR(5),col1 XML)
INSERT INTO @t (id,col1) VALUES ('1','<node1>one</node1>')
SELECT ISNULL(STUFF((SELECT ', ' + id FROM @t FOR XML PATH('') ,TYPE ).value('.', 'NVARCHAR(MAX)'), 1, 2, ' '), '') UNAMESLIST

go

--https://stackoverflow.com/questions/21623593/what-is-the-meaning-of-select-for-xml-path-1-1
begin
	declare @t table 
	(
		Id int,
		Name varchar(10)
	)
	insert into @t
	select 1,'a' union all
	select 1,'b' union all
	select 2,'c' union all
	select 2,'d' 

	select ID,
	stuff( (    select ','+ [Name] from @t where Id = t.Id for XML path('') ),1,1,'') 
	from (select distinct ID from @t )t
END
/*
--There's no real technique to learn here. 
--It's just a cute trick to concatenate multiple rows of data into a single string. 
--It's more a quirky use of a feature than an intended use of the XML formatting feature.

SELECT ',' + ColumnName ... FOR XML PATH('')

-- generates a set of comma separated values, 
-- based on combining multiple rows of data from the ColumnName column. 
-- It will produce a value like ,abc,def,ghi,jkl.

select STUFF(...,1,1,'')

-- https://stackoverflow.com/questions/31211506/how-stuff-and-for-xml-path-work-in-sql-server

Here is how it works:

1. Get XML element string with FOR XML

Adding FOR XML PATH to the end of a query allows you to output the results of the query as XML elements, 
with the element name contained in the PATH argument. 
For example, if we were to run the following statement:

SELECT ',' + name 
              FROM temp1
              FOR XML PATH ('')

By passing in a blank string (FOR XML PATH('')), we get the following instead:

,aaa,bbb,ccc,ddd,eee

2. Remove leading comma with STUFF

The STUFF statement literally "stuffs” one string into another, 
replacing characters within the first string. We, however, 
are using it simply to remove the first character of the resultant list of values.

SELECT abc = STUFF((
            SELECT ',' + NAME
            FROM temp1
            FOR XML PATH('')
            ), 1, 1, '')
FROM temp1

The parameters of STUFF are:

    The string to be “stuffed” (in our case the full list of name with a leading comma)
    The location to start deleting and inserting characters (1, we’re stuffing into a blank string)
    The number of characters to delete (1, being the leading comma)

So we end up with:

aaa,bbb,ccc,ddd,eee

3. Join on id to get full list

Next we just join this on the list of id in the temp table, to get a list of IDs with name:

SELECT ID,  abc = STUFF(
             (SELECT ',' + name 
              FROM temp1 t1
              WHERE t1.id = t2.id
              FOR XML PATH (''))
             , 1, 1, '') from temp1 t2
group by id;

And we have our result:

-----------------------------------
| Id        | Name                |
|---------------------------------|
| 1         | aaa,bbb,ccc,ddd,eee |
-----------------------------------

Hope this helps!
*/
