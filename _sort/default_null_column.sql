
select schema_name(t.schema_id) as schema_name,
       t.name as table_name,
       c.name as column_name,
       case is_nullable
            when 0 then 'NOT NULLABLE'
            else 'NULLABLE'
            end as nullable
from sys.columns c
join sys.tables t on t.object_id = c.object_id
where t.name = 'FamilyProfile' and c.name = 'DefaultLanguageId'
order by schema_name, table_name, column_name;


select is_nullable from sys.columns c
join sys.tables t on t.object_id = c.object_id
where t.name = 'FamilyProfile' and c.name = 'DefaultLanguageId' 
and is_nullable = 1

GO
IF EXISTS (SELECT is_nullable FROM sys.columns c JOIN sys.tables t on t.object_id = c.object_id
	WHERE t.name = 'FamilyProfile' and c.name = 'DefaultLanguageId' and is_nullable = 1)
BEGIN
	ALTER TABLE [Family].[FamilyProfile] ALTER COLUMN DefaultLanguageId INTEGER NOT NULL
END

GO
