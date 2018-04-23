DECLARE @tableName NVARCHAR(MAX), @schemaName NVARCHAR(MAX), @className NVARCHAR(MAX), @counter int
   
--------------- Input arguments ---------------
SET @tableName = 'Background' -- the name of the table
SET @schemaName = 'Student' -- the name of the schema (eg: dbo, Student)
SET @className = 'StudentBackgroundModel' -- the model's class name
SET @counter = 0; -- used for ProtoBuf to add ProtoMember identifiers
--------------- Input arguments end -----------
   
DECLARE tableColumns CURSOR LOCAL FOR
SELECT cols.name, cols.system_type_id, cols.is_nullable FROM sys.columns cols
    JOIN sys.tables tbl ON cols.object_id = tbl.object_id
    WHERE tbl.name = @tableName
   
PRINT '[ProtoContract]'
PRINT 'public class ' + @className
PRINT '{'
   
OPEN tableColumns
DECLARE @name NVARCHAR(MAX), @typeId INT, @isNullable BIT, @typeName NVARCHAR(MAX)
FETCH NEXT FROM tableColumns INTO @name, @typeId, @isNullable
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @typeName =
    CASE @typeId
        WHEN 35 THEN 'string'
        WHEN 40 THEN 'DateTime'
        WHEN 52 THEN 'short'
        WHEN 56 THEN 'int'
        WHEN 61 THEN 'DateTime'
        WHEN 104 THEN 'bool'
        WHEN 165 THEN 'byte[]'
        WHEN 167 THEN 'string'
        WHEN 175 THEN 'string'
        WHEN 231 THEN 'string'
        WHEN 239 THEN 'string'
        WHEN 241 THEN 'XElement'
        ELSE 'TODO(' + CAST(@typeId AS NVARCHAR) + ')'
    END;
    IF @isNullable = 1
    AND @typeId != 35
    AND @typeId != 167
    AND @typeId != 175
    AND @typeId != 231
    AND @typeId != 239
    AND @typeId != 241
        SET @typeName = @typeName + '?'
        SET @counter = @counter + 1
    PRINT '    [ProtoMember(' + Convert( varchar, @counter) + ')]'
    PRINT '    public ' + @typeName + ' ' + @name + ' { get; set; }'   
    FETCH NEXT FROM tableColumns INTO @name, @typeId, @isNullable
END
   
PRINT '}'
   
CLOSE tableColumns