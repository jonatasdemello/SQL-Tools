/*
This script will generate calls to sp_dropextendedproperty for every
extended property that exists in your database.
Actually, a caveat: I don't promise that it will catch each and every 
extended property that exists, but I'm confident it will catch most of them!

It is based on this: 
http://blog.hongens.nl/2010/02/25/drop-all-extended-properties-in-a-mssql-database/ 
by Angelo Hongens.

Also had lots of help from this:
http://www.sqlservercentral.com/articles/Metadata/72609/
by Adam Aspin

Adam actually provides a script at that link to do something very similar
but when I ran it I got an error:
Msg 468, Level 16, State 9, Line 78
Cannot resolve the collation conflict between "Latin1_General_100_CS_AS" and "Latin1_General_CI_AS" in the equal to operation.

So I put together this version instead. 

Use at your own risk.

Jamie Thomson
2012-03-25
*/


/*Are there any extended properties? Let's take a look*/
select  *,OBJECT_NAME(major_id) from    sys.extended_properties xp

/*Now let's generate sp_dropextendedproperty statements for all of them.*/
--tables
set nocount on;
select 'EXEC sp_dropextendedproperty
@name = '''+xp.name+'''
,@level0type = ''schema''
,@level0name = ''' + object_schema_name(xp.major_id) + '''
,@level1type = ''table''
,@level1name = ''' + object_name(xp.major_id) + ''''
from sys.extended_properties xp
join sys.tables t on xp.major_id = t.object_id
where xp.class_desc = 'OBJECT_OR_COLUMN'
and xp.minor_id = 0
union
--columns
select 'EXEC sp_dropextendedproperty
@name = '''+sys.extended_properties.name+'''
,@level0type = ''schema''
,@level0name = ''' + object_schema_name(extended_properties.major_id) + '''
,@level1type = ''table''
,@level1name = ''' + object_name(extended_properties.major_id) + '''
,@level2type = ''column''
,@level2name = ''' + columns.name + ''''
from sys.extended_properties
join sys.columns
on columns.object_id = extended_properties.major_id
and columns.column_id = extended_properties.minor_id
where extended_properties.class_desc = 'OBJECT_OR_COLUMN'
and extended_properties.minor_id > 0
union
--check constraints
select  'EXEC sp_dropextendedproperty
@name = '''+xp.name+'''
,@level0type = ''schema''
,@level0name = ''' + object_schema_name(xp.major_id) + '''
,@level1type = ''table''
,@level1name = ''' + object_name(cc.parent_object_id) + '''
,@level2type = ''constraint''
,@level2name = ''' + cc.name + ''''
from    sys.extended_properties xp
join sys.check_constraints cc       on  xp.major_id = cc.object_id
union
--check constraints
select  'EXEC sp_dropextendedproperty
@name = '''+xp.name+'''
,@level0type = ''schema''
,@level0name = ''' + object_schema_name(xp.major_id) + '''
,@level1type = ''table''
,@level1name = ''' + object_name(cc.parent_object_id) + '''
,@level2type = ''constraint''
,@level2name = ''' + cc.name + ''''
from    sys.extended_properties xp
join sys.default_constraints cc     on  xp.major_id = cc.object_id
union
--views
select 'EXEC sp_dropextendedproperty
@name = '''+xp.name+'''
,@level0type = ''schema''
,@level0name = ''' + object_schema_name(xp.major_id) + '''
,@level1type = ''view''
,@level1name = ''' + object_name(xp.major_id) + ''''
from sys.extended_properties xp
join sys.views t on xp.major_id = t.object_id
where xp.class_desc = 'OBJECT_OR_COLUMN'
and xp.minor_id = 0
union
--sprocs
select 'EXEC sp_dropextendedproperty
@name = '''+xp.name+'''
,@level0type = ''schema''
,@level0name = ''' + object_schema_name(xp.major_id) + '''
,@level1type = ''procedure''
,@level1name = ''' + object_name(xp.major_id) + ''''
from sys.extended_properties xp
join sys.procedures t on xp.major_id = t.object_id
where xp.class_desc = 'OBJECT_OR_COLUMN'
and xp.minor_id = 0
union
--functions
select 'EXEC sp_dropextendedproperty
@name = '''+xp.name+'''
,@level0type = ''schema''
,@level0name = ''' + object_schema_name(xp.major_id) + '''
,@level1type = ''function''
,@level1name = ''' + object_name(xp.major_id) + ''''
from sys.extended_properties xp
join sys.functions t on xp.major_id = t.object_id
where xp.class_desc = 'OBJECT_OR_COLUMN'
and xp.minor_id = 0
union
--FKs
select  'EXEC sp_dropextendedproperty
@name = '''+xp.name+'''
,@level0type = ''schema''
,@level0name = ''' + object_schema_name(xp.major_id) + '''
,@level1type = ''table''
,@level1name = ''' + object_name(cc.parent_object_id) + '''
,@level2type = ''constraint''
,@level2name = ''' + cc.name + ''''
from    sys.extended_properties xp
join sys.foreign_keys cc        on  xp.major_id = cc.object_id
union
--PKs
SELECT 
'EXEC sys.sp_dropextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '], @level1type = ''TABLE'', @level1name = [' + TBL.name + '] , @level2type = ''CONSTRAINT'', @level2name = [' + SKC.name + '] ,@name = ''' + REPLACE(CAST(SEP.name AS NVARCHAR(300)),'''','''''') + ''''
FROM sys.tables TBL
 INNER JOIN sys.schemas SCH
 ON TBL.schema_id = SCH.schema_id 
 INNER JOIN sys.extended_properties SEP
 INNER JOIN sys.key_constraints SKC
 ON SEP.major_id = SKC.object_id 
 ON TBL.object_id = SKC.parent_object_id 
WHERE SKC.type_desc = N'PRIMARY_KEY_CONSTRAINT'
union
--Table triggers
SELECT 
'EXEC sys.sp_dropextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '], @level1type = ''TABLE'', @level1name = [' + TBL.name + '] , @level2type = ''TRIGGER'', @level2name = [' + TRG.name + '] ,@name = ''' + REPLACE(CAST(SEP.name AS NVARCHAR(300)),'''','''''') + ''''
FROM sys.tables TBL
 INNER JOIN sys.triggers TRG
 ON TBL.object_id = TRG.parent_id 
 INNER JOIN sys.extended_properties SEP
 ON TRG.object_id = SEP.major_id 
 INNER JOIN sys.schemas SCH
 ON TBL.schema_id = SCH.schema_id
union
--UDF params
SELECT 
'EXEC sys.sp_dropextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '], @level1type = ''FUNCTION'', @level1name = [' + OBJ.name + '] , @level2type = ''PARAMETER'', @level2name = [' + PRM.name + '] ,@name = ''' + REPLACE(CAST(SEP.name AS NVARCHAR(300)),'''','''''') + ''''
FROM sys.extended_properties SEP
 INNER JOIN sys.objects OBJ
 ON SEP.major_id = OBJ.object_id 
 INNER JOIN sys.schemas SCH
 ON OBJ.schema_id = SCH.schema_id 
 INNER JOIN sys.parameters PRM
 ON SEP.major_id = PRM.object_id 
 AND SEP.minor_id = PRM.parameter_id 
WHERE SEP.class_desc = N'PARAMETER'
 AND OBJ.type IN ('FN', 'IF', 'TF') 
union
--sp params
SELECT 
'EXEC sys.sp_dropextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '], @level1type = ''PROCEDURE'', @level1name = [' + SPR.name + '] , @level2type = ''PARAMETER'', @level2name = [' + PRM.name + '] ,@name = ''' + REPLACE(CAST(SEP.name AS NVARCHAR(300)),'''','''''') + ''''
FROM sys.extended_properties SEP
 INNER JOIN sys.procedures SPR
 ON SEP.major_id = SPR.object_id 
 INNER JOIN sys.schemas SCH
 ON SPR.schema_id = SCH.schema_id 
 INNER JOIN sys.parameters PRM
 ON SEP.major_id = PRM.object_id 
 AND SEP.minor_id = PRM.parameter_id 
WHERE SEP.class_desc = N'PARAMETER'
union
--DB
SELECT 
'EXEC sys.sp_dropextendedproperty @name = ''' + REPLACE(CAST(SEP.name AS NVARCHAR(300)),'''','''''') + ''''
FROM sys.extended_properties SEP
WHERE class_desc = N'DATABASE'
union
--schema
SELECT 
'EXEC sys.sp_dropextendedproperty @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '] ,@name = ''' + REPLACE(CAST(SEP.name AS NVARCHAR(300)),'''','''''') + ''''
FROM sys.extended_properties SEP
 INNER JOIN sys.schemas SCH
 ON SEP.major_id = SCH.schema_id 
WHERE SEP.class_desc = N'SCHEMA'
union
--DATABASE_FILE
SELECT 
'EXEC sys.sp_dropextendedproperty @level0type = N''FILEGROUP'', @level0name = [' + DSP.name + '], @level1type = ''LOGICAL FILE NAME'', @level1name = ' + DBF.name + ' ,@name = ''' + REPLACE(CAST(SEP.name AS NVARCHAR(300)),'''','''''') + ''''
FROM sys.extended_properties SEP
 INNER JOIN sys.database_files DBF
 ON SEP.major_id = DBF.file_id 
 INNER JOIN sys.data_spaces DSP
 ON DBF.data_space_id = DSP.data_space_id 
WHERE SEP.class_desc = N'DATABASE_FILE'
union
--filegroup
SELECT 
'EXEC sys.sp_dropextendedproperty @level0type = N''FILEGROUP'', @level0name = [' + DSP.name + '] ,@name = ''' + REPLACE(CAST(SEP.name AS NVARCHAR(300)),'''','''''') + ''''
FROM sys.extended_properties SEP
 INNER JOIN sys.data_spaces DSP
 ON SEP.major_id = DSP.data_space_id
WHERE DSP.type_desc = 'ROWS_FILEGROUP'
