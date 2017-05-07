/*
Search and Replace in a TEXT(NTEXT) column

It's been a while since I've posted anything SQL related. So... Sometimes we need to search and replace a text value in the entire table. The column in question is of TEXT or NTEXT datatype. T-SQL REPLACE function does not work with TEXT/NTEXT datatype.

Instead we have to use several other functions:

UPDATETEXT - Updates an existing text, ntext, or image field.
TEXTPTR - Returns the text-pointer value that corresponds to a text, ntext, or image column in varbinary format. The retrieved text pointer value can be used in READTEXT, WRITETEXT, and UPDATETEXT statements.
PATINDEX - Returns the starting position of the first occurrence of a pattern in a specified expression, or zeros if the pattern is not found, on all valid text and character data types.

A while ago I wrote a small utility procedure which uses above functions to implement Search and Replace functionality.

*/

ALTER PROC dbo.SearchAndReplace 
(
     @FindString    NVARCHAR(100)
    ,@ReplaceString NVARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @TextPointer VARBINARY(16) 
    DECLARE @DeleteLength INT 
    DECLARE @OffSet INT 

    SELECT @TextPointer = TEXTPTR([MY_TEXT_COLUMN])
      FROM [MY_TABLE]

    SET @DeleteLength = LEN(@FindString) 
    SET @OffSet = 0
    SET @FindString = '%' + @FindString + '%'

    WHILE (SELECT COUNT(*)
             FROM [MY_TABLE]
            WHERE PATINDEX(@FindString, [MY_TEXT_COLUMN]) <> 0) > 0
    BEGIN 
        SELECT @OffSet = PATINDEX(@FindString, [MY_TEXT_COLUMN]) - 1
          FROM [MY_TABLE]
         WHERE PATINDEX(@FindString, [MY_TEXT_COLUMN]) <> 0

        UPDATETEXT [MY_TABLE].[MY_TEXT_COLUMN]
            @TextPointer
            @OffSet
            @DeleteLength
            @ReplaceString
    END

    SET NOCOUNT OFF
END



--usage exec pr_FindAndReplaceTextDatatype YOURTABLE,ThePrimaryKeyOfTheTable,TheTEXT/NTEXTFieldName,OptionalWHEREStatementTolimitImpact,OldStringToReplace,NewStringToReplaceWith
--usage exec pr_FindAndReplaceTextDatatype 'GMAMEMO','ACTMEMOTBLKEY','TCOMMENT','','{\rtf1','{\rtf2'
--usage exec pr_FindAndReplaceTextDatatype 'GMAMEMO','ACTMEMOTBLKEY','TCOMMENT','WHERE ACTMEMOTBLKEY  BETWEEN 8 AND 75','Coca Cola Classic','Just Coke'

CREATE Procedure pr_FindAndReplaceTextDatatype 
--DECLARE 
        @TableName        varchar(255),
        @PKIDColumnName   varchar(255),
        @TextColumnName   varchar(255),
        @WhereStatement   varchar(1000) = '',
        @OldString        varchar(255),
        @NewString        varchar(255)
AS
  DECLARE
        @sql              varchar(2000),
        @LenOldString     int
  BEGIN
    --Assign variables
    SET @LenOldString=datalength(@OldString)
    --string building..single quotes handled special
    SET @OldString = REPLACE(@OldString,'''','''''')
    SET @NewString = REPLACE(@NewString,'''','''''')
    --initialize row identifier
    SET @sql = '  DECLARE          ' + CHAR(13)
    SET @sql = @sql + '        @LenOldString     int, '       + CHAR(13)
    SET @sql = @sql + '        @WhichPKID        int,  '      + CHAR(13)
    SET @sql = @sql + '        @idx              int, '       + CHAR(13)
    SET @sql = @sql + '        @ptr              binary(16) ' + CHAR(13)
    SET @sql = @sql + '  SET @LenOldString = ' + CONVERT(varchar,@LenOldString) + CHAR(13)
    SET @sql = @sql + '  SELECT TOP 1 @WhichPKID = ' + @PKIDColumnName + ',  ' + CHAR(13)
    SET @sql = @sql + '             @idx      = PATINDEX(''%' + @OldString + '%'',' + @TextColumnName + ')-1  ' + CHAR(13)
    SET @sql = @sql + '  FROM ' + @TableName + '  ' + @WhereStatement + ' ' + CHAR(13)
    SET @sql = @sql + '  WHERE PATINDEX(''%' + @OldString + '%'',' + @TextColumnName + ') > 0  ' + CHAR(13)
    SET @sql = @sql + ' ' + CHAR(13)
    SET @sql = @sql + '  WHILE @WhichPKID > 0  ' + CHAR(13)
    SET @sql = @sql + '    BEGIN  ' + CHAR(13)
    SET @sql = @sql + '      SELECT @ptr = TEXTPTR(' + @TextColumnName + ')  ' + CHAR(13)
    SET @sql = @sql + '      FROM ' + @TableName + '  ' + CHAR(13)
    SET @sql = @sql + '      WHERE ' + @PKIDColumnName + ' = @WhichPKID  ' + CHAR(13)
    SET @sql = @sql + '      UPDATETEXT ' + @TableName + '.' + @TextColumnName + ' @ptr @idx ' +  convert(varchar,@LenOldString) + ''''+ @NewString + '''  ' + CHAR(13)
    SET @sql = @sql + '      SET @WhichPKID = 0  ' + CHAR(13)
    SET @sql = @sql + '      SELECT TOP 1 @WhichPKID = ' + @PKIDColumnName + ', @idx = PATINDEX(''%' + @OldString + '%'',' + @TextColumnName + ')-1  ' + CHAR(13)
    SET @sql = @sql + '      FROM ' + @TableName + '  ' + @WhereStatement + ' ' + CHAR(13)
    SET @sql = @sql + '      WHERE ' + @PKIDColumnName + ' > @WhichPKID  ' + CHAR(13)
    SET @sql = @sql + '        AND PATINDEX(''%' + @OldString + '%'',' + @TextColumnName + ') > 0  ' + CHAR(13)
    SET @sql = @sql + '   END  ' + CHAR(13)
    PRINT @sql
    EXEC (@sql)
  END --PROC 
