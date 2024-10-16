-- https://www.sqlshack.com/learn-sql-the-information_schema-database/

-- INFORMATION_SCHEMA Database


SELECT * FROM sys.databases;
EXEC sp_databases;


USE our_first_database;
 
-- list of all tables in the selected database
SELECT *
FROM INFORMATION_SCHEMA.TABLES;
    
-- list of all constraints in the selected database
SELECT *
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS;


USE our_first_database;
 
-- join tables and constraints data
SELECT 
    INFORMATION_SCHEMA.TABLES.TABLE_NAME,
    INFORMATION_SCHEMA.TABLE_CONSTRAINTS.CONSTRAINT_NAME,
    INFORMATION_SCHEMA.TABLE_CONSTRAINTS.CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLES
INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS ON INFORMATION_SCHEMA.TABLES.TABLE_NAME = INFORMATION_SCHEMA.TABLE_CONSTRAINTS.TABLE_NAME
ORDER BY
    INFORMATION_SCHEMA.TABLES.TABLE_NAME ASC,
    INFORMATION_SCHEMA.TABLE_CONSTRAINTS.CONSTRAINT_TYPE DESC;
	

USE our_first_database;
 
-- join tables and constraints data
SELECT 
    INFORMATION_SCHEMA.TABLES.TABLE_NAME,
    SUM(CASE WHEN INFORMATION_SCHEMA.TABLE_CONSTRAINTS.CONSTRAINT_TYPE = 'PRIMARY KEY' THEN 1 ELSE 0 END) AS pk,
    SUM(CASE WHEN INFORMATION_SCHEMA.TABLE_CONSTRAINTS.CONSTRAINT_TYPE = 'UNIQUE' THEN 1 ELSE 0 END) AS uni,
    SUM(CASE WHEN INFORMATION_SCHEMA.TABLE_CONSTRAINTS.CONSTRAINT_TYPE = 'FOREIGN KEY' THEN 1 ELSE 0 END) AS fk
FROM INFORMATION_SCHEMA.TABLES
LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS ON INFORMATION_SCHEMA.TABLES.TABLE_NAME = INFORMATION_SCHEMA.TABLE_CONSTRAINTS.TABLE_NAME
GROUP BY
    INFORMATION_SCHEMA.TABLES.TABLE_NAME
ORDER BY
    INFORMATION_SCHEMA.TABLES.TABLE_NAME ASC;
	

/*
The only thing I’ll do here is to list all the tables (views) you have at disposal. They are:

    CHECK_CONSTRAINTS – details related to each CHECK constraint
    COLUMN_DOMAIN_USAGE – details related to columns that have an alias data type
    COLUMN_PRIVILEGES – columns privileges granted to or granted by the current user
    COLUMNS – columns from the current database
    CONSTRAINT_COLUMN_USAGE – details about column-related constraints
    CONSTRAINT_TABLE_USAGE – details about table-related constraints
    DOMAIN_CONSTRAINTS – details related to alias data types and rules related to them (accessible by this user)
    DOMAINS – alias data type details (accessible by this user)
    KEY_COLUMN_USAGE – details returned if the column is related with keys or not
    PARAMETERS – details related to each parameter related to user-defined functions and procedures accessible by this user
    REFERENTIAL_CONSTRAINTS – details about foreign keys
    ROUTINES –details related to routines (functions & procedures) stored in the database
    ROUTINE_COLUMNS – one row for each column returned by the table-valued function
    SCHEMATA – details related to schemas in the current database
    TABLE_CONSTRAINTS – details related to table constraints in the current database
    TABLE_PRIVILEGES –table privileges granted to or granted by the current user
    TABLES –details related to tables stored in the database
    VIEW_COLUMN_USAGE – details about columns used in the view definition
    VIEW_TABLE_USAGE – details about the tables used in the view definition
    VIEWS – details related to views stored in the database

*/