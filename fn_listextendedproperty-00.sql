
-- The following example displays all extended properties set on the database object itself.
SELECT objtype, objname, name, value  
FROM fn_listextendedproperty(default, default, default, default, default, default, default);  

--The following example lists extended properties for columns in the ScrapReason table. 
--This is contained in the schema Production.
USE AdventureWorks2012;  
GO  
SELECT objtype, objname, name, value  
FROM fn_listextendedproperty (NULL, 'schema', 'Production', 'table', 'ScrapReason', 'column', default);  
GO  

-- The following example lists extended properties for all tables contained in the Sales schema.
USE AdventureWorks2012;  
GO  
SELECT objtype, objname, name, value  
FROM fn_listextendedproperty (NULL, 'schema', 'Sales', 'table', default, NULL, NULL);  
GO  


SELECT objtype, objname, name, value
FROM fn_listextendedproperty ('MS_Description', 'SCHEMA', 'Education', 'TABLE', 'ModeOfStudy', 'COLUMN', 'StudyTypeId'); 

--FROM fn_listextendedproperty ('MS_Description', 'SCHEMA', 'Education', 'TABLE', default, NULL, NULL);  
GO

select * from sys.extended_properties SEP where class_desc = N'OBJECT_OR_COLUMN' and [name] = 'MS_Description'


select * from sys.extended_properties SEP where class_desc = N'OBJECT_OR_COLUMN' and [name] = 'MS_Description'


exec sys.sp_dropextendedproperty 
	@name=N'MS_Description', 
	@level0type=N'SCHEMA',
	@level0name=N'Education',
	@level1type=N'TABLE',
	@level1name=N'ModeOfStudy',
	@level2type=N'COLUMN',
	@level2name=N'StudyTypeId'

EXEC sys.sp_addextendedproperty 
	@name=N'MS_Description', 
	@value=N'StudyTypeId=1: Program; StudyTypeId=2: Major; StudyTypeId=3: Apprenticeship',
	@level0type=N'SCHEMA',
	@level0name=N'Education',
	@level1type=N'TABLE',
	@level1name=N'ModeOfStudy',
	@level2type=N'COLUMN',
	@level2name=N'StudyTypeId'
	
IF EXISTS(SELECT objtype, objname, name, value FROM fn_listextENDedproperty ('MS_Description', 'SCHEMA', 'Education', 'TABLE', 'ModeOfStudy', 'COLUMN', 'StudyTypeId'))



fn_listextendedproperty (   
    { default | 'property_name' | NULL }   
  , { default | 'level0_object_type' | NULL }   
  , { default | 'level0_object_name' | NULL }   
  , { default | 'level1_object_type' | NULL }   
  , { default | 'level1_object_name' | NULL }   
  , { default | 'level2_object_type' | NULL }   
  , { default | 'level2_object_name' | NULL }   
  )   

Arguments

{ default | 'property_name' | NULL}
	Is the name of the property. 
	property_name is sysname. 
	Valid inputs are default, NULL, or a property name.

{ default | 'level0_object_type' | NULL}
	Is the user or user-defined type. 
	level0_object_type is varchar(128), with a default of NULL. 
	Valid inputs are 
		ASSEMBLY, CONTRACT, EVENT NOTIFICATION, FILEGROUP, MESSAGE TYPE, 
		PARTITION FUNCTION, PARTITION SCHEME, REMOTE SERVICE BINDING, ROUTE, 
		SCHEMA, SERVICE, TRIGGER, TYPE, USER, and NULL.

	Important
	USER and TYPE as level-0 types will be removed in a future version of SQL Server. 
	Avoid using these features in new development work, and plan to modify applications that currently use these features. 
	Use SCHEMA as the level 0 type instead of USER. 
	For TYPE, use SCHEMA as the level 0 type and TYPE as the level 1 type.

{ default | 'level0_object_name' | NULL }
	Is the name of the level 0 object type specified. level0_object_name is sysname with a default of NULL. 
	Valid inputs are default, NULL, or an object name.

{ default | 'level1_object_type' | NULL }
	Is the type of level 1 object. level1_object_type is varchar(128) with a default of NULL. 
	Valid inputs are 
		AGGREGATE, DEFAULT, FUNCTION, LOGICAL FILE NAME, PROCEDURE, QUEUE, RULE, SYNONYM, 
		TABLE, TYPE, VIEW, XML SCHEMA COLLECTION, and NULL.

Note: Default maps to NULL and 'default' maps to the object type DEFAULT.

{default | 'level1_object_name' |NULL }
	Is the name of the level 1 object type specified. level1_object_name is sysname with a default of NULL. 
	Valid inputs are default, NULL, or an object name.

{ default | 'level2_object_type' |NULL }
	Is the type of level 2 object. level2_object_type is varchar(128) with a default of NULL. 
	Valid inputs are DEFAULT, default (maps to NULL), and NULL. 
	Valid inputs for level2_object_type are COLUMN, CONSTRAINT, EVENT NOTIFICATION, INDEX, PARAMETER, TRIGGER, and NULL.

{ default | 'level2_object_name' |NULL }
	Is the name of the level 2 object type specified. level2_object_name is sysname with a default of NULL. 
	Valid inputs are default, NULL, or an object name.
	