USE PTC;
GO

CREATE TABLE dbo.SampleTable (
  SampleTableID INT NOT NULL IDENTITY(1,1),
  SampleTableInt INT NOT NULL,
  SampleTableChar CHAR(5) NOT NULL,
  SampleTableVarChar VARCHAR(30) NOT NULL,
  CONSTRAINT PK_SampleTable PRIMARY KEY CLUSTERED (SampleTableID)
);
GO

CREATE TABLE dbo.SampleTable_Audit (
  SampleTableID INT NOT NULL,
  SampleTableInt INT NOT NULL,
  SampleTableChar CHAR(5) NOT NULL,
  SampleTableVarChar VARCHAR(30) NOT NULL,
  Operation CHAR(1) NOT NULL,
  TriggerTable CHAR(1) NOT NULL,
  AuditDateTime smalldatetime NOT NULL DEFAULT GETDATE(),
);

CREATE INDEX IDX_SampleTable_Audit_AuditDateTime ON dbo.SampleTable_Audit (AuditDateTime DESC);
GO


-- triggers

CREATE TRIGGER dbo.SampleTable_InsertTrigger
ON dbo.SampleTable
FOR INSERT
AS
BEGIN
   INSERT INTO dbo.SampleTable_Audit (SampleTableID, SampleTableInt, SampleTableChar, SampleTableVarChar, Operation, TriggerTable)    
   SELECT SampleTableID, SampleTableInt, SampleTableChar, SampleTableVarChar, 'I', 'I'
   FROM inserted;
END;
GO

CREATE TRIGGER dbo.SampleTable_DeleteTrigger
ON dbo.SampleTable
FOR DELETE
AS
BEGIN
   INSERT INTO dbo.SampleTable_Audit (SampleTableID, SampleTableInt, SampleTableChar, SampleTableVarChar, Operation, TriggerTable)    
   SELECT SampleTableID, SampleTableInt, SampleTableChar, SampleTableVarChar, 'D', 'D'
   FROM deleted;
END;
GO

CREATE TRIGGER dbo.SampleTable_UpdateTrigger
ON dbo.SampleTable
FOR UPDATE
AS
BEGIN
   INSERT INTO dbo.SampleTable_Audit (SampleTableID, SampleTableInt, SampleTableChar, SampleTableVarChar, Operation, TriggerTable)    
   SELECT SampleTableID, SampleTableInt, SampleTableChar, SampleTableVarChar, 'U', 'D'
   FROM deleted;
  
   INSERT INTO dbo.SampleTable_Audit (SampleTableID, SampleTableInt, SampleTableChar, SampleTableVarChar, Operation, TriggerTable)    
   SELECT SampleTableID, SampleTableInt, SampleTableChar, SampleTableVarChar, 'U', 'I'
   FROM inserted;
END;
GO



-- First the inserts
	INSERT INTO dbo.SampleTable (SampleTableInt, SampleTableChar, SampleTableVarChar)
	VALUES (1, '11111', '1111111111');

	INSERT INTO dbo.SampleTable (SampleTableInt, SampleTableChar, SampleTableVarChar)
	VALUES (2, '22222', '222222222222222');

	INSERT INTO dbo.SampleTable (SampleTableInt, SampleTableChar, SampleTableVarChar)
	VALUES (3, 'AAAAA', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
	GO

-- Check the sample table
	SELECT * FROM dbo.SampleTable;
	GO

	-- Check the inserts
	SELECT * FROM dbo.SampleTable_Audit;
	GO

-- Perform a delete operation
	DELETE FROM dbo.SampleTable
	WHERE SampleTableInt = 2;
	GO

	-- Check the sample table
	SELECT * FROM dbo.SampleTable;
	GO

	-- Check the delete
	SELECT * FROM dbo.SampleTable_Audit;
	GO

-- Perform an update operation
	UPDATE dbo.SampleTable
	SET SampleTableChar = '33333'
	WHERE SampleTableInt = 3;
	GO

	-- Check the sample table
	SELECT * FROM dbo.SampleTable;
	GO

	-- Check the update
	SELECT * FROM dbo.SampleTable_Audit;
	GO


checkpoint

