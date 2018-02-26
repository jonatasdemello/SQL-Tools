-- To Display all the Constraint in the Database

SELECT * FROM sys.objects
	WHERE type_desc LIKE '%CONSTRAINT'

-- To Display all the Constraints in the Database

SELECT OBJECT_NAME(object_id) AS ConstraintName,
SCHEMA_NAME(schema_id) AS SchemaName,
OBJECT_NAME(parent_object_id) AS TableName,
type_desc AS ConstraintType
FROM sys.objects
WHERE type_desc LIKE '%CONSTRAINT'

-- To Display all the Constraints in table 'Employee'

SELECT OBJECT_NAME(object_id) AS ConstraintName,
SCHEMA_NAME(schema_id) AS SchemaName,
type_desc AS ConstraintType
FROM sys.objects
WHERE type_desc LIKE '%CONSTRAINT' AND OBJECT_NAME(parent_object_id)='Assignment'


-- To Display all the Constraints in the Database

SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS

-- To Display all the Constraints in table 'Employee'

SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME='WorkflowStatus'

-- To Display Default Constraints in Database

SELECT OBJECT_NAME(PARENT_OBJECT_ID) AS TABLE_NAME,
COL_NAME (PARENT_OBJECT_ID, PARENT_COLUMN_ID) AS COLUMN_NAME,
NAME AS DEFAULT_CONSTRAINT_NAME
FROM SYS.DEFAULT_CONSTRAINTS
