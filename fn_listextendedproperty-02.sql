DECLARE @prop_name sysname
DECLARE @schema_name sysname
DECLARE @name sysname
DECLARE @name2 sysname
DECLARE @sql nvarchar(max)

-- Delete extended properties database
DECLARE PROP_CURSOR CURSOR FOR
SELECT name FROM sys.extended_properties where class = 0

OPEN PROP_CURSOR

FETCH NEXT FROM PROP_CURSOR
INTO @prop_name

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'USE [master];EXEC ' + QUOTENAME(DB_NAME()) + N'.sys.sp_dropextendedproperty @name=N''' + @prop_name + N''''
    EXEC (@sql)

    FETCH NEXT FROM PROP_CURSOR
    INTO @prop_name
END
CLOSE PROP_CURSOR
DEALLOCATE PROP_CURSOR


-- Remove schema extension property
DECLARE PROP_CURSOR CURSOR FOR
SELECT SCHEMA_NAME(s.schema_id), ep.name
FROM sys.extended_properties ep
INNER JOIN sys.schemas s ON s.schema_id = ep.major_id
WHERE ep.class = 3

OPEN PROP_CURSOR

FETCH NEXT FROM PROP_CURSOR
INTO @schema_name, @prop_name

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'EXEC sys.sp_dropextendedproperty ' + 
    N'@name=N''' + @prop_name + N''',' +
    N'@level0type=N''SCHEMA'',' + 
    N'@level0name=N''' + @schema_name + ''''
    EXEC (@sql)

    FETCH NEXT FROM PROP_CURSOR
    INTO @schema_name, @prop_name
END
CLOSE PROP_CURSOR
DEALLOCATE PROP_CURSOR

-- Delete extended properties of a file group
DECLARE PROP_CURSOR CURSOR FOR
SELECT f.name, ep.name
FROM sys.extended_properties ep
INNER JOIN sys.filegroups f ON f.data_space_id = ep.major_id
WHERE ep.class = 20

OPEN PROP_CURSOR

FETCH NEXT FROM PROP_CURSOR
INTO @name, @prop_name

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'EXEC sys.sp_dropextendedproperty ' + 
    N'@name=N''' + @prop_name + N''',' +
    N'@level0type=N''FILEGROUP'',' + 
    N'@level0name=N''' + @name + ''''
    EXEC (@sql)

    FETCH NEXT FROM PROP_CURSOR
    INTO @name, @prop_name
END
CLOSE PROP_CURSOR
DEALLOCATE PROP_CURSOR


-- Delete extended properties of a file
DECLARE PROP_CURSOR CURSOR FOR
SELECT f.name, sf.name, ep.name
FROM sys.extended_properties ep
INNER JOIN sys.filegroups f ON f.data_space_id = ep.major_id
INNER JOIN sys.sysfiles sf ON sf.groupid = f.data_space_id
WHERE ep.class = 22

OPEN PROP_CURSOR

FETCH NEXT FROM PROP_CURSOR
INTO @name, @name2, @prop_name

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'EXEC sys.sp_dropextendedproperty ' + 
    N'@name=N''' + @prop_name + N''',' +
    N'@level0type=N''FILEGROUP'',' + 
    N'@level0name=N''' + @name + ''', ' + 
    N'@level1type=N''Logical File Name'',' + 
    N'@level1name=N''' + @name2 + ''''

    EXEC (@sql)

    FETCH NEXT FROM PROP_CURSOR
    INTO @name, @name2, @prop_name
END
CLOSE PROP_CURSOR
DEALLOCATE PROP_CURSOR

-- Remove the expansion properties of the XML schema collection
DECLARE PROP_CURSOR CURSOR FOR
SELECT SCHEMA_NAME(x.schema_id), x.name, ep.name
FROM sys.extended_properties ep
INNER JOIN sys.xml_schema_collections x ON x.xml_collection_id = ep.major_id
WHERE ep.class = 10

OPEN PROP_CURSOR

FETCH NEXT FROM PROP_CURSOR
INTO @schema_name, @name, @prop_name

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'EXEC sys.sp_dropextendedproperty ' + 
    N'@name=N''' + @prop_name + N''',' +
    N'@level0type=N''SCHEMA'',' + 
    N'@level0name=N''' + @schema_name + ''', '+
    N'@level1type=N''XML SCHEMA COLLECTION'',' + 
    N'@level1name=N''' + @name + N''''
    EXEC (@sql)

    FETCH NEXT FROM PROP_CURSOR
    INTO @schema_name, @name, @prop_name
END
CLOSE PROP_CURSOR
DEALLOCATE PROP_CURSOR


-- Delete extended properties of a table
DECLARE PROP_CURSOR CURSOR FOR
SELECT SCHEMA_NAME(t.schema_id), OBJECT_NAME(t.object_id), ep.name
FROM sys.extended_properties ep
INNER JOIN sys.tables t ON t.object_id = ep.major_id
WHERE ep.class = 1 AND ep.minor_id = 0

OPEN PROP_CURSOR

FETCH NEXT FROM PROP_CURSOR
INTO @schema_name, @name, @prop_name

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'EXEC sys.sp_dropextendedproperty ' + 
    N'@name=N''' + @prop_name + N''',' +
    N'@level0type=N''SCHEMA'',' + 
    N'@level0name=N''' + @schema_name + ''', '+
    N'@level1type=N''TABLE'',' + 
    N'@level1name=N''' + @name + N''''
    EXEC (@sql)

    FETCH NEXT FROM PROP_CURSOR
    INTO @schema_name, @name, @prop_name
END
CLOSE PROP_CURSOR
DEALLOCATE PROP_CURSOR


-- Delete extended properties of view
DECLARE PROP_CURSOR CURSOR FOR
SELECT SCHEMA_NAME(v.schema_id), OBJECT_NAME(v.object_id), ep.name
FROM sys.extended_properties ep
INNER JOIN sys.views v ON v.object_id = ep.major_id
WHERE ep.class = 1 AND ep.minor_id = 0

OPEN PROP_CURSOR

FETCH NEXT FROM PROP_CURSOR
INTO @schema_name, @name, @prop_name

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'EXEC sys.sp_dropextendedproperty ' + 
    N'@name=N''' + @prop_name + N''',' +
    N'@level0type=N''SCHEMA'',' + 
    N'@level0name=N''' + @schema_name + ''', '+
    N'@level1type=N''VIEW'',' + 
    N'@level1name=N''' + @name + N''''
    EXEC (@sql)

    FETCH NEXT FROM PROP_CURSOR
    INTO @schema_name, @name, @prop_name
END
CLOSE PROP_CURSOR
DEALLOCATE PROP_CURSOR


-- Delete extended properties of the index
DECLARE PROP_CURSOR CURSOR FOR
SELECT SCHEMA_NAME(o.schema_id), OBJECT_NAME(o.object_id), i.name, ep.name
FROM sys.extended_properties ep
INNER JOIN sys.objects o ON o.object_id = ep.major_id AND o.type IN ('U')
INNER JOIN sys.indexes i ON i.object_id = ep.major_id AND i.index_id = ep.minor_id
WHERE ep.class = 7

OPEN PROP_CURSOR

FETCH NEXT FROM PROP_CURSOR
INTO @schema_name, @name, @name2, @prop_name

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'EXEC sys.sp_dropextendedproperty ' + 
    N'@name=N''' + @prop_name + N''',' +
    N'@level0type=N''SCHEMA'',' + 
    N'@level0name=N''' + @schema_name + ''', '+
    N'@level1type=N''TABLE'',' + 
    N'@level1name=N''' + @name + N''', ' + 
    N'@level2type=N''INDEX'',' + 
    N'@level2name=N''' + @name2 + N''''
    EXEC (@sql)

    FETCH NEXT FROM PROP_CURSOR
    INTO @schema_name, @name, @name2, @prop_name
END
CLOSE PROP_CURSOR
DEALLOCATE PROP_CURSOR

-- Delete extended properties of the index of the view
DECLARE PROP_CURSOR CURSOR FOR
SELECT SCHEMA_NAME(o.schema_id), OBJECT_NAME(o.object_id), i.name, ep.name
FROM sys.extended_properties ep
INNER JOIN sys.objects o ON o.object_id = ep.major_id AND o.type IN ('V')
INNER JOIN sys.indexes i ON i.object_id = ep.major_id AND i.index_id = ep.minor_id
WHERE ep.class = 7

OPEN PROP_CURSOR

FETCH NEXT FROM PROP_CURSOR
INTO @schema_name, @name, @name2, @prop_name

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'EXEC sys.sp_dropextendedproperty ' + 
    N'@name=N''' + @prop_name + N''',' +
    N'@level0type=N''SCHEMA'',' + 
    N'@level0name=N''' + @schema_name + ''', '+
    N'@level1type=N''VIEW'',' + 
    N'@level1name=N''' + @name + N''', ' + 
    N'@level2type=N''INDEX'',' + 
    N'@level2name=N''' + @name2 + N''''
    EXEC (@sql)

    FETCH NEXT FROM PROP_CURSOR
    INTO @schema_name, @name, @name2, @prop_name
END
CLOSE PROP_CURSOR
DEALLOCATE PROP_CURSOR


-- Delete extended properties of the function
DECLARE PROP_CURSOR CURSOR FOR
SELECT SCHEMA_NAME(o.schema_id), OBJECT_NAME(o.object_id), ep.name
FROM sys.extended_properties ep
INNER JOIN sys.objects o ON o.object_id = ep.major_id AND o.type IN ('FN', 'TF')
WHERE ep.class = 1 AND ep.minor_id = 0

OPEN PROP_CURSOR

FETCH NEXT FROM PROP_CURSOR
INTO @schema_name, @name, @prop_name

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'EXEC sys.sp_dropextendedproperty ' + 
    N'@name=N''' + @prop_name + N''',' +
    N'@level0type=N''SCHEMA'',' + 
    N'@level0name=N''' + @schema_name + ''', '+
    N'@level1type=N''FUNCTION'',' + 
    N'@level1name=N''' + @name + N''''
    EXEC (@sql)

    FETCH NEXT FROM PROP_CURSOR
    INTO @schema_name, @name, @prop_name
END
CLOSE PROP_CURSOR
DEALLOCATE PROP_CURSOR

-- Delete extended properties of the parameters of the function
DECLARE PROP_CURSOR CURSOR FOR
SELECT SCHEMA_NAME(o.schema_id), OBJECT_NAME(o.object_id), p.name, ep.name
FROM sys.extended_properties ep
INNER JOIN sys.objects o ON o.object_id = ep.major_id AND o.type IN ('FN', 'TF')
INNER JOIN sys.parameters p ON p.object_id = ep.major_id AND p.parameter_id = ep.minor_id
WHERE ep.class = 2 

OPEN PROP_CURSOR

FETCH NEXT FROM PROP_CURSOR
INTO @schema_name, @name, @name2, @prop_name

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'EXEC sys.sp_dropextendedproperty ' + 
    N'@name=N''' + @prop_name + N''',' +
    N'@level0type=N''SCHEMA'',' + 
    N'@level0name=N''' + @schema_name + ''', '+
    N'@level1type=N''FUNCTION'',' + 
    N'@level1name=N''' + @name + N''', ' + 
    N'@level2type=N''PARAMETER'',' + 
    N'@level2name=N''' + @name2 + N''''
    EXEC (@sql)

    FETCH NEXT FROM PROP_CURSOR
    INTO @schema_name, @name, @name2, @prop_name
END
CLOSE PROP_CURSOR
DEALLOCATE PROP_CURSOR


-- Delete extended properties of the stored procedure
DECLARE PROP_CURSOR CURSOR FOR
SELECT SCHEMA_NAME(p.schema_id), OBJECT_NAME(p.object_id), ep.name
FROM sys.extended_properties ep
INNER JOIN sys.procedures p ON p.object_id = ep.major_id
WHERE ep.class = 1 AND ep.minor_id = 0

OPEN PROP_CURSOR

FETCH NEXT FROM PROP_CURSOR
INTO @schema_name, @name, @prop_name

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'EXEC sys.sp_dropextendedproperty ' + 
    N'@name=N''' + @prop_name + N''',' +
    N'@level0type=N''SCHEMA'',' + 
    N'@level0name=N''' + @schema_name + ''', '+
    N'@level1type=N''PROCEDURE'',' + 
    N'@level1name=N''' + @name + N''''
    EXEC (@sql)

    FETCH NEXT FROM PROP_CURSOR
    INTO @schema_name, @name, @prop_name
END
CLOSE PROP_CURSOR
DEALLOCATE PROP_CURSOR


-- Delete extended properties of the parameters of a stored procedure
DECLARE PROP_CURSOR CURSOR FOR
SELECT SCHEMA_NAME(o.schema_id), OBJECT_NAME(o.object_id), p.name, ep.name
FROM sys.extended_properties ep
INNER JOIN sys.objects o ON o.object_id = ep.major_id AND o.type = 'P'
INNER JOIN sys.parameters p ON p.object_id = ep.major_id AND p.parameter_id = ep.minor_id
WHERE ep.class = 2 

OPEN PROP_CURSOR

FETCH NEXT FROM PROP_CURSOR
INTO @schema_name, @name, @name2, @prop_name

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'EXEC sys.sp_dropextendedproperty ' + 
    N'@name=N''' + @prop_name + N''',' +
    N'@level0type=N''SCHEMA'',' + 
    N'@level0name=N''' + @schema_name + ''', '+
    N'@level1type=N''PROCEDURE'',' + 
    N'@level1name=N''' + @name + N''', ' + 
    N'@level2type=N''PARAMETER'',' + 
    N'@level2name=N''' + @name2 + N''''
    EXEC (@sql)

    FETCH NEXT FROM PROP_CURSOR
    INTO @schema_name, @name, @name2, @prop_name
END
CLOSE PROP_CURSOR
DEALLOCATE PROP_CURSOR


-- Delete extended properties of DDL trigger
DECLARE PROP_CURSOR CURSOR FOR
SELECT t.name, ep.name
FROM sys.extended_properties ep
INNER JOIN sys.triggers t ON t.object_id = ep.major_id AND t.parent_class = 0
WHERE ep.class = 1 AND ep.minor_id = 0

OPEN PROP_CURSOR

FETCH NEXT FROM PROP_CURSOR
INTO @name, @prop_name

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'EXEC sys.sp_dropextendedproperty ' + 
    N'@name=N''' + @prop_name + N''',' +
    N'@level0type=N''TRIGGER'',' + 
    N'@level0name=N''' + @name + N''''
    EXEC (@sql)

    FETCH NEXT FROM PROP_CURSOR
    INTO @name, @prop_name
END
CLOSE PROP_CURSOR
DEALLOCATE PROP_CURSOR


-- Delete extended properties of DML trigger
DECLARE PROP_CURSOR CURSOR FOR
SELECT SCHEMA_NAME(o.schema_id), p.name, OBJECT_NAME(o.object_id), ep.name
FROM sys.extended_properties ep
INNER JOIN sys.objects o ON o.object_id = ep.major_id AND o.type = 'TR'
INNER JOIN sys.objects p ON o.parent_object_id = p.object_id
WHERE ep.class = 1

OPEN PROP_CURSOR

FETCH NEXT FROM PROP_CURSOR
INTO @schema_name, @name, @name2, @prop_name

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'EXEC sys.sp_dropextendedproperty ' + 
    N'@name=N''' + @prop_name + N''',' +
    N'@level0type=N''SCHEMA'',' + 
    N'@level0name=N''' + @schema_name + ''', ' +
    N'@level1type=N''TABLE'',' + 
    N'@level1name=N''' + @name + N''', ' + 
    N'@level2type=N''TRIGGER'',' + 
    N'@level2name=N''' + @name2 + N''''

    EXEC (@sql)

    FETCH NEXT FROM PROP_CURSOR
    INTO @schema_name, @name, @name2, @prop_name
END
CLOSE PROP_CURSOR
DEALLOCATE PROP_CURSOR

-- Delete extended properties of the constraint
DECLARE PROP_CURSOR CURSOR FOR
SELECT SCHEMA_NAME(c.schema_id), OBJECT_NAME(c.parent_object_id), OBJECT_NAME(c.object_id), ep.name
FROM sys.extended_properties ep
INNER JOIN sys.check_constraints c ON c.object_id = ep.major_id
WHERE ep.class = 1 and ep.minor_id = 0
UNION
SELECT SCHEMA_NAME(c.schema_id), OBJECT_NAME(c.parent_object_id), OBJECT_NAME(c.object_id), ep.name
FROM sys.extended_properties ep
INNER JOIN sys.default_constraints c ON c.object_id = ep.major_id
WHERE ep.class = 1 and ep.minor_id = 0
UNION
SELECT SCHEMA_NAME(c.schema_id), OBJECT_NAME(c.parent_object_id), OBJECT_NAME(c.object_id), ep.name
FROM sys.extended_properties ep
INNER JOIN sys.foreign_keys c ON c.object_id = ep.major_id
WHERE ep.class = 1 and ep.minor_id = 0
UNION
SELECT SCHEMA_NAME(c.schema_id), OBJECT_NAME(c.parent_object_id), OBJECT_NAME(c.object_id), ep.name
FROM sys.extended_properties ep
INNER JOIN sys.key_constraints c ON c.object_id = ep.major_id
WHERE ep.class = 1 and ep.minor_id = 0


OPEN PROP_CURSOR

FETCH NEXT FROM PROP_CURSOR
INTO @schema_name, @name, @name2, @prop_name

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'EXEC sys.sp_dropextendedproperty ' + 
    N'@name=N''' + @prop_name + N''',' +
    N'@level0type=N''SCHEMA'',' + 
    N'@level0name=N''' + @schema_name + ''', ' +
    N'@level1type=N''TABLE'',' + 
    N'@level1name=N''' + @name + N''', ' + 
    N'@level2type=N''CONSTRAINT'',' + 
    N'@level2name=N''' + @name2 + N''''

    EXEC (@sql)

    FETCH NEXT FROM PROP_CURSOR
    INTO @schema_name, @name, @name2, @prop_name
END
CLOSE PROP_CURSOR
DEALLOCATE PROP_CURSOR


-- To delete an extended property of the column
DECLARE PROP_CURSOR CURSOR FOR
SELECT SCHEMA_NAME(o.schema_id), OBJECT_NAME(o.object_id), c.name, ep.name
FROM sys.extended_properties ep
INNER JOIN sys.objects o ON o.object_id = ep.major_id
INNER JOIN sys.columns c ON c.object_id = o.object_id AND c.column_id = ep.minor_id
WHERE ep.class = 1

OPEN PROP_CURSOR

FETCH NEXT FROM PROP_CURSOR
INTO @schema_name, @name, @name2, @prop_name

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'EXEC sys.sp_dropextendedproperty ' + 
    N'@name=N''' + @prop_name + N''',' +
    N'@level0type=N''SCHEMA'',' + 
    N'@level0name=N''' + @schema_name + ''', ' +
    N'@level1type=N''TABLE'',' + 
    N'@level1name=N''' + @name + N''', ' + 
    N'@level2type=N''COLUMN'',' + 
    N'@level2name=N''' + @name2 + N''''

    EXEC (@sql)

    FETCH NEXT FROM PROP_CURSOR
    INTO @schema_name, @name, @name2, @prop_name
END
CLOSE PROP_CURSOR
DEALLOCATE PROP_CURSOR