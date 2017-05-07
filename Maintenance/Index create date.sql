
SELECT DISTINCT type FROM sys.objects

SELECT TOP 100 * FROM sys.objects WHERE type='s'


SELECT * FROM sys.indexes
SELECT index_id FROM sys.indexes WHERE etc

SELECT STATS_DATE(OBJECT_ID('MyTable', (SELECT index_id FROM sys.indexes WHERE etc))

	SELECT 
		i.name 'Index Name',
		o.create_date
	FROM 
		sys.indexes i
	INNER JOIN 
		sys.objects o ON i.name = o.name
	WHERE 
		o.is_ms_shipped = 0
		AND o.type IN ('PK', 'FK', 'UQ')
	ORDER BY 
		create_date DESC
		

SELECT TOP 10    *
FROM    sys.indexes i
        INNER JOIN sys.objects o ON i.object_id = o.object_id
WHERE o.type NOT IN ('S', 'IT')
ORDER BY create_date DESC


/*
FAQ : How to find the Index Creation /Rebuild Date in SQL Server
AFAIK, there is no system object gives you the information of Index creation Date in SQL Server. If the Clustered index is on PK then the creation date can get from sysobjects or sys.objects. But that is not the case always. 

This query which uses STATS_DATE() function to get the STATISTICS updated date. This will not give you accurate result if you are updating STATISTICS explicitly. The logic behind the query is, if you rebuild indexes the STATISTICS are also being updated at the same time. So if you are not explicitly updating STATISTICS using UPDATE STATISTICS tableName command , then this query will give you the correct information

*/
--In SQL Server 2000
Select Name as IndexName, 
STATS_DATE ( id , indid ) as IndexCreatedDate
From sysindexes where id=object_id('HumanResources.Employee')

-- In SQL Server 2005
Select Name as IndexName, 
STATS_DATE ( object_id , index_id ) as IndexCreatedDate
From sys.indexes where object_id=object_id('HumanResources.Employee')


select crdate, i.name, object_name(o.id)
from sysindexes i
   join sysobjects o ON o.id = i.id
order by crdate DESC
