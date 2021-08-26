
-- Archive SpProj tables
declare @sql nvarchar(max), @SchemaName varchar(500), @TableName varchar(500)
declare cur CURSOR LOCAL for
    select schema_name(t.schema_id) as SchemaName, t.name as TableName
    from sys.tables t 
    where schema_name(t.schema_id) = 'SpProj'
open cur
fetch next from cur into @SchemaName, @TableName
while @@FETCH_STATUS = 0 BEGIN

    set @SQL = 'ALTER SCHEMA archive_SpProj TRANSFER '+ @SchemaName +'.'+ @TableName
    print @sql
    exec sp_executesql @sql

    fetch next from cur into @SchemaName, @TableName
END
close cur
deallocate cur
GO

-------------------------------------------------------------------------------------------------------------------------------
declare @field1 int
declare @field2 int
declare cur CURSOR LOCAL for
    select field1, field2 from sometable where someotherfield is null

open cur

fetch next from cur into @field1, @field2

while @@FETCH_STATUS = 0 BEGIN

    --execute your sproc on each row
    exec uspYourSproc @field1, @field2

    fetch next from cur into @field1, @field2
END

close cur
deallocate cur
-------------------------------------------------------------------------------------------------------------------------------


-- Declare & init (2008 syntax)
DECLARE @CustomerID INT = 0

-- Iterate over all customers
WHILE (1 = 1) 
BEGIN  

  -- Get next customerId
  SELECT TOP 1 @CustomerID = CustomerID
  FROM Sales.Customer
  WHERE CustomerID > @CustomerId 
  ORDER BY CustomerID

  -- Exit loop if no more customers
  IF @@ROWCOUNT = 0 BREAK;

  -- call your sproc
  EXEC dbo.YOURSPROC @CustomerId

END

-------------------------------------------------------------------------------------------------------------------------------

DECLARE @SQL varchar(max)=''
-- MyTable has fields fld1 & fld2

Select @SQL = @SQL + 'exec myproc ' + convert(varchar(10),fld1) + ',' + convert(varchar(10),fld2) + ';' 
From MyTable

EXEC (@SQL)

-------------------------------------------------------------------------------------------------------------------------------


-- define the last customer ID handled
DECLARE @LastCustomerID INT
SET @LastCustomerID = 0

-- define the customer ID to be handled now
DECLARE @CustomerIDToHandle INT

-- select the next customer to handle    
SELECT TOP 1 @CustomerIDToHandle = CustomerID
FROM Sales.Customer
WHERE CustomerID > @LastCustomerID
ORDER BY CustomerID

-- as long as we have customers......    
WHILE @CustomerIDToHandle IS NOT NULL
BEGIN
    -- call your sproc

    -- set the last customer handled to the one we just handled
    SET @LastCustomerID = @CustomerIDToHandle
    SET @CustomerIDToHandle = NULL

    -- select the next customer to handle    
    SELECT TOP 1 @CustomerIDToHandle = CustomerID
    FROM Sales.Customer
    WHERE CustomerID > @LastCustomerID
    ORDER BY CustomerID
END


