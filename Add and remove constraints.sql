
--To Add a foreign key to a column in an existing table, use ALTER TABLE ADD CONSTRAINT

ALTER TABLE President_Lookup  
	ADD CONSTRAINT fk_PresidentID FOREIGN KEY (PresidentID)REFERENCES Presidents (PresidentID) 

CREATE TABLE Orders
(
	O_Id int NOT NULL PRIMARY KEY,
	OrderNo int NOT NULL,
	P_Id int FOREIGN KEY REFERENCES Persons(P_Id)
)

CREATE TABLE Orders
(
	O_Id int NOT NULL,
	OrderNo int NOT NULL,
	P_Id int,
	PRIMARY KEY (O_Id),
	CONSTRAINT fk_PerOrders FOREIGN KEY (P_Id) REFERENCES Persons(P_Id)
)

--------------------------------------------------------------------------------
ALTER TABLE Orders
	ADD FOREIGN KEY (P_Id) REFERENCES Persons(P_Id)

ALTER TABLE Orders
	ADD CONSTRAINT fk_PerOrders FOREIGN KEY (P_Id) REFERENCES Persons(P_Id)
--------------------------------------------------------------------------------

ALTER TABLE Orders DROP FOREIGN KEY fk_PerOrders

ALTER TABLE Orders DROP CONSTRAINT fk_PerOrders
--------------------------------------------------------------------------------

USE AdventureWorks2008R2 ;
GO
CREATE TABLE Person.ContactBackup
(ContactID int) ;
GO
ALTER TABLE Person.ContactBackup
	ADD CONSTRAINT FK_ContactBacup_Contact FOREIGN KEY (ContactID)
		REFERENCES Person.Person (BusinessEntityID) ;

ALTER TABLE Person.ContactBackup DROP CONSTRAINT FK_ContactBacup_Contact ;
GO
DROP TABLE Person.ContactBackup ;

/*
I. Disabling and re-enabling a constraint
The following example disables a constraint that limits the salaries accepted in the data. NOCHECK CONSTRAINT is used with ALTER TABLE to disable the constraint and allow for an insert that would typically violate the constraint. CHECK CONSTRAINT re-enables the constraint.
*/

 CREATE TABLE cnst_example 
(id INT NOT NULL,
 name VARCHAR(10) NOT NULL,
 salary MONEY NOT NULL
    CONSTRAINT salary_cap CHECK (salary < 100000)
);

-- Valid inserts
INSERT INTO cnst_example VALUES (1,'Joe Brown',65000);
INSERT INTO cnst_example VALUES (2,'Mary Smith',75000);

-- This insert violates the constraint.
INSERT INTO cnst_example VALUES (3,'Pat Jones',105000);

-- Disable the constraint and try again.
ALTER TABLE cnst_example NOCHECK CONSTRAINT salary_cap;
INSERT INTO cnst_example VALUES (3,'Pat Jones',105000);

-- Re-enable the constraint and try another insert; this will fail.
ALTER TABLE cnst_example CHECK CONSTRAINT salary_cap;
INSERT INTO cnst_example VALUES (4,'Eric James',110000) ;

/*
J. Dropping a constraint
The following example removes a UNIQUE constraint from a table.
*/

CREATE TABLE doc_exc ( column_a INT
CONSTRAINT my_constraint UNIQUE) ;
GO
ALTER TABLE doc_exc DROP CONSTRAINT my_constraint ;
GO
DROP TABLE doc_exc ;
GO

