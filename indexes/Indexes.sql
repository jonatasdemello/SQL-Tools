/* ****************************************************************** 
http://msdn.microsoft.com/en-us/library/ms190283.aspx

sp_helptext 'sp_helpindex'

****************************************************************** */

select 
    i.name as IndexName, 
    o.name as TableName, 
    ic.key_ordinal as ColumnOrder,
    ic.is_included_column as IsIncluded, 
    co.[name] as ColumnName
from sys.indexes i 
join sys.objects o on i.object_id = o.object_id
join sys.index_columns ic on ic.object_id = i.object_id 
    and ic.index_id = i.index_id
join sys.columns co on co.object_id = i.object_id 
    and co.column_id = ic.column_id
where i.[type] = 2 
and i.is_unique = 0 
and i.is_primary_key = 0
and o.[type] = 'U'
--and ic.is_included_column = 0
order by o.[name], i.[name], ic.is_included_column, ic.key_ordinal

/********************************************************************/


-- If you need more information, here is a nice SQL script, which I use from time to time:

DECLARE @TabName varchar(100)

CREATE TABLE #temp (
   TabName varchar(200), IndexName varchar(200), IndexDescr varchar(200), 
   IndexKeys varchar(200), IndexSize int
)

DECLARE cur CURSOR FAST_FORWARD LOCAL FOR
    SELECT name FROM sysobjects WHERE xtype = 'U'

OPEN cur

FETCH NEXT FROM cur INTO @TabName
WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO #temp (IndexName, IndexDescr, IndexKeys)
        EXEC sp_helpindex @TabName

        UPDATE #temp SET TabName = @TabName WHERE TabName IS NULL

        FETCH NEXT FROM cur INTO @TabName
    END

CLOSE cur
DEALLOCATE cur

DECLARE @ValueCoef int
SELECT @ValueCoef = low FROM Master.dbo.spt_values WHERE number = 1 AND type = N'E'

UPDATE #temp SET IndexSize = 
    ((CAST(sysindexes.used AS bigint) * @ValueCoef)/1024)/1024
        FROM sysobjects INNER JOIN sysindexes ON sysobjects.id = sysindexes.id
                INNER JOIN #temp T ON T.TabName = sysobjects.name AND T.IndexName = sysindexes.name

SELECT * FROM #temp
ORDER BY TabName, IndexName 

DROP TABLE #temp

/********************************************************************/
/*
SQL Server: How to Get All Indexes List With Involved Columns Name
Recently a friend of mine asked for a script, for documentation purpose 
which can help them to create all of their indexes list with column names used in each index. 
I thought, I must share this simple script with my blog readers.
*/

SELECT  Tab.[name] AS TableName,
Ind.[name] AS IndexName,
SUBSTRING(( SELECT  ', ' + AC.name
FROM    sys.[tables] AS T
INNER JOIN sys.[indexes] I
ON T.[object_id] = I.[object_id]
INNER JOIN sys.[index_columns] IC
ON I.[object_id] = IC.[object_id]
AND I.[index_id] = IC.[index_id]
INNER JOIN sys.[all_columns] AC
ON T.[object_id] = AC.[object_id]
AND IC.[column_id] = AC.[column_id]
WHERE   Ind.[object_id] = I.[object_id]
AND Ind.index_id = I.index_id
AND IC.is_included_column = 0
ORDER BY IC.key_ordinal
FOR
XML PATH('')
), 2, 8000) AS KeyCols,
SUBSTRING(( SELECT  ', ' + AC.name
FROM    sys.[tables] AS T
INNER JOIN sys.[indexes] I
ON T.[object_id] = I.[object_id]
INNER JOIN sys.[index_columns] IC
ON I.[object_id] = IC.[object_id]
AND I.[index_id] = IC.[index_id]
INNER JOIN sys.[all_columns] AC
ON T.[object_id] = AC.[object_id]
AND IC.[column_id] = AC.[column_id]
WHERE   Ind.[object_id] = I.[object_id]
AND Ind.index_id = I.index_id
AND IC.is_included_column = 1
ORDER BY IC.key_ordinal
FOR
XML PATH('')
), 2, 8000) AS IncludeCols

FROM    sys.[indexes] Ind
INNER JOIN sys.[tables] AS Tab
ON Tab.[object_id] = Ind.[object_id]
ORDER BY TableName



there is a problem with it, however - it is putting the "included" columns into the same list as index columns

to distinguish them is_included_column flag of
sys.[index_columns] table should be used



/********************************************************************/



USE AdventureWorksDW2008R2
GO

SELECT
    so.name AS TableName, si.name AS IndexName, si.type_desc AS IndexType
FROM
    sys.indexes si JOIN sys.objects so ON si.[object_id] = so.[object_id]
WHERE
    so.type = 'U'    --Only get indexes for User Created Tables
    AND si.name IS NOT NULL
ORDER BY
    so.name, si.type 


/*
SQL Server 2000 
 
Yes, you can use the following for a specific table: 
*/

EXEC sp_helpindex 'tablename' 

/* 
This returns index_name, index_description, and index_keys. The index_description column tells whether or not the index is clustered, and which filegroup it resides on. The index_keys column tells you the column names that participate in the index, and from what I can tell, these are always in the order they are created (a negative symbol (-) denotes that the column is in DESC order). 
 
This is great, but does not provide all of the information I'm often looking for.  
 
In order to return everything I wanted to know about the indexes in my database, I needed to create a couple of extra helper functions. (Unfortunately, indexes are not covered in the INFORMATION_SCHEMA views, so we need to rely on system tables like sysindexes and sysfilegroups, and system functions like INDEXPROPERTY() and INDEX_COL().) The first function is not required, but makes the second function quite tidier, IMHO: 
 
*/
-- Returns whether the column is ASC or DESC 
CREATE FUNCTION dbo.GetIndexColumnOrder 
( 
    @object_id INT, 
    @index_id TINYINT, 
    @column_id TINYINT 
) 
RETURNS NVARCHAR(5) 
AS 
BEGIN 
    DECLARE @r NVARCHAR(5) 
    SELECT @r = CASE INDEXKEY_PROPERTY 
    ( 
        @object_id, 
        @index_id, 
        @column_id, 
        'IsDescending' 
    ) 
        WHEN 1 THEN N' DESC' 
        ELSE N'' 
    END 
    RETURN @r 
END 
GO 
 
-- Returns the list of columns in the index 
CREATE FUNCTION dbo.GetIndexColumns 
( 
    @table_name SYSNAME, 
    @object_id INT, 
    @index_id TINYINT 
) 
RETURNS NVARCHAR(4000) 
AS 
BEGIN 
    DECLARE 
        @colnames NVARCHAR(4000),  
        @thisColID INT, 
        @thisColName SYSNAME 
         
    SET @colnames = INDEX_COL(@table_name, @index_id, 1) 
        + dbo.GetIndexColumnOrder(@object_id, @index_id, 1) 
 
    SET @thisColID = 2 
    SET @thisColName = INDEX_COL(@table_name, @index_id, @thisColID) 
        + dbo.GetIndexColumnOrder(@object_id, @index_id, @thisColID) 
 
    WHILE (@thisColName IS NOT NULL) 
    BEGIN 
        SET @thisColID = @thisColID + 1 
        SET @colnames = @colnames + ', ' + @thisColName 
 
        SET @thisColName = INDEX_COL(@table_name, @index_id, @thisColID) 
            + dbo.GetIndexColumnOrder(@object_id, @index_id, @thisColID) 
    END 
    RETURN @colNames 
END 
GO 
 
These functions are based largely on sp_helpindex, and while they avoid cursors, 
they are still not likely to be very efficient as the functions will need to be called multiple times. 
 
Now that we have these functions, we can create this view: 
 
CREATE VIEW dbo.vAllIndexes  
AS 
    SELECT  
        TABLE_NAME = OBJECT_NAME(i.id), 
        INDEX_NAME = i.name, 
        COLUMN_LIST = dbo.GetIndexColumns(OBJECT_NAME(i.id), i.id, i.indid), 
        IS_CLUSTERED = INDEXPROPERTY(i.id, i.name, 'IsClustered'), 
        IS_UNIQUE = INDEXPROPERTY(i.id, i.name, 'IsUnique'), 
        FILE_GROUP = g.GroupName 
    FROM 
        sysindexes i 
    INNER JOIN 
        sysfilegroups g 
    ON 
        i.groupid = g.groupid 
    WHERE 
        (i.indid BETWEEN 1 AND 254) 
        -- leave out AUTO_STATISTICS: 
        AND (i.Status & 64)=0 
        -- leave out system tables: 
        AND OBJECTPROPERTY(i.id, 'IsMsShipped') = 0 
GO 
 
This will give you a handy resultset, but does not specify whether the index is a PRIMARY KEY CONSTRAINT. 
You can do that by joining against INFORMATION_SCHEMA.TABLE_CONSTRAINTS: 
 
SELECT 
    v.*, 
    [PrimaryKey?] = CASE  
        WHEN T.TABLE_NAME IS NOT NULL THEN 1 
        ELSE 0 
    END 
FROM 
    dbo.vAllIndexes v 
LEFT OUTER JOIN 
    INFORMATION_SCHEMA.TABLE_CONSTRAINTS T  
ON 
    T.CONSTRAINT_NAME = v.INDEX_NAME 
    AND T.TABLE_NAME = v.TABLE_NAME  
    AND T.CONSTRAINT_TYPE = 'PRIMARY KEY' 

/* 
This doesn't take into account same-named tables owned by different users, but if you look at the alternative (see the source code for sp_pkeys), it is probably a valid solution for most of us, where dbo is the de facto owner of all objects. 
 
With that limitation in mind, we can take it one step further by generating the CREATE INDEX / ADD CONSTRAINT statements: 
*/ 

SELECT  
    CASE WHEN T.TABLE_NAME IS NULL THEN 
        'CREATE ' 
        + CASE IS_UNIQUE WHEN 1 THEN ' UNIQUE' ELSE '' END 
        + CASE IS_CLUSTERED WHEN 1 THEN ' CLUSTERED' ELSE '' END 
        + ' INDEX [' + INDEX_NAME + '] ON [' + v.TABLE_NAME + ']' 
        + ' (' + COLUMN_LIST + ') ON ' + FILE_GROUP 
    ELSE 
        'ALTER TABLE ['+T.TABLE_NAME+']' 
        +' ADD CONSTRAINT ['+INDEX_NAME+']' 
        +' PRIMARY KEY ' 
        + CASE IS_CLUSTERED WHEN 1 THEN ' CLUSTERED' ELSE '' END 
        + ' (' + COLUMN_LIST + ')' 
    END 
FROM 
    dbo.vAllIndexes v 
LEFT OUTER JOIN 
    INFORMATION_SCHEMA.TABLE_CONSTRAINTS T  
ON 
    T.CONSTRAINT_NAME = v.INDEX_NAME 
    AND T.TABLE_NAME = v.TABLE_NAME  
    AND T.CONSTRAINT_TYPE = 'PRIMARY KEY' 
ORDER BY 
    v.TABLE_NAME, 
    IS_CLUSTERED DESC 
 
This is what I have to offer for now, and I realize it is pretty quick and dirty. I'll be working on a similar script using the SQL Server 2005 catalog views, but I'll save that for another day. 
 
MS Access 
 
Since Access stopped storing object names in its MSys* tables, it is nearly impossible to perform administrative tasks within the database itself, unless you want to point and click through a GUI. So I developed the following script with ADOX: 
 
<% 
    Set conn = CreateObject("ADODB.Connection") 
     
    conn.Open "Provider=Microsoft.Jet.OLEDB.4.0;" & _ 
        "Data Source=" & Server.MapPath("db.mdb") 
 
    Set adox = CreateObject("ADOX.Catalog") 
    Set adox.ActiveConnection = conn 
     
    Response.Write "<table border=1 cellspacing=0 cellpadding=5>" & _ 
        "<tr valign=top bgcolor=#EDEDED>" & _  
        "<th>Table Name" & _  
        "<th>Index Name" & _ 
        "<th>Unique?" & _ 
        "<th>Clustered?" & _ 
        "<th>Primary Key?" & _ 
        "<th>Column Name(s)" & _ 
        "<th>Sort Order" 
         
    For Each table In adox.Tables  
        For Each index In table.Indexes 
            Response.Write "<tr valign=top>" & _ 
                "<td>" & table.Name & _ 
                "<td>" & index.Name & _ 
                "<td>" & index.Unique & _ 
                "<td>" & index.Clustered & _ 
                "<td>" & index.PrimaryKey 
 
            colNames = "" 
            sortOrders = "" 
                 
            For Each col In index.Columns 
                colNames = colNames & col.Name & "<br>" 
                so = "ASC" 
                If col.SortOrder = 2 Then so = "DESC" 
                sortOrders = sortOrders & so & "<br>" 
            Next 
 
            Response.Write "<td>" & colNames & _ 
                "<td>" & sortOrders 
        Next 
    Next 
     
    Response.Write "</table>" 
     
    Set adox = Nothing 
    conn.Close() 
    Set conn = Nothing 
%> 


