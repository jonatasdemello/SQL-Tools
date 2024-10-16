


-- Find foreign keys referencing to dbo.states table
   SELECT name AS 'Foreign Key Constraint Name', 
       OBJECT_SCHEMA_NAME(parent_object_id) + '.' + OBJECT_NAME(parent_object_id) AS 'Child Table'
   FROM sys.foreign_keys 
   WHERE OBJECT_SCHEMA_NAME(referenced_object_id) = 'CMS' AND 
              OBJECT_NAME(referenced_object_id) = 'CodeList'

-- Drop the foreign key constraint by its name 
  ALTER TABLE dbo.cities DROP CONSTRAINT FK__cities__state__6442E2C9;



BEGIN
 
  DECLARE @stmt VARCHAR(300);
 
  -- Cursor to generate ALTER TABLE DROP CONSTRAINT statements  
  DECLARE cur CURSOR FOR
     SELECT 'ALTER TABLE ' + OBJECT_SCHEMA_NAME(parent_object_id) + '.' + OBJECT_NAME(parent_object_id) +
                    ' DROP CONSTRAINT ' + name
     FROM sys.foreign_keys 
     WHERE OBJECT_SCHEMA_NAME(referenced_object_id) = 'CMS' AND 
                OBJECT_NAME(referenced_object_id) = 'CodeList';
 
   OPEN cur;
   FETCH cur INTO @stmt;
 
   -- Drop each found foreign key constraint 
   WHILE @@FETCH_STATUS = 0
     BEGIN
       EXEC (@stmt);
       FETCH cur INTO @stmt;
     END
 
  CLOSE cur;
  DEALLOCATE cur;
 
  END
  GO