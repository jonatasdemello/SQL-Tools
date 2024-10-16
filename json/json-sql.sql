-- https://learn.microsoft.com/en-us/sql/relational-databases/json/store-json-documents-in-sql-tables?view=sql-server-ver16
-- using OPENJSON, JSON_VALUE or JSON_QUERY functions

create table WebSite.Logs (
    _id bigint primary key identity,
    log nvarchar(max)
);

-- The nvarchar(max) data type lets you store JSON documents that are up to 2 GB in size. 
-- If you're sure that your JSON documents aren't greater than 8 KB, however, 
-- we recommend that you use NVARCHAR(4000) instead of NVARCHAR(max) for performance reasons.			   

ALTER TABLE WebSite.Logs
    ADD CONSTRAINT [Log record should be formatted as JSON]
                   CHECK (ISJSON(log)=1)


SELECT TOP 100 JSON_VALUE(log, '$.severity'), AVG( CAST( JSON_VALUE(log,'$.duration') as float))
 FROM WebSite.Logs
 WHERE CAST( JSON_VALUE(log,'$.date') as datetime) > @datetime
 GROUP BY JSON_VALUE(log, '$.severity')
 HAVING AVG( CAST( JSON_VALUE(log,'$.duration') as float) ) > 100
 ORDER BY AVG( CAST( JSON_VALUE(log,'$.duration') as float) ) DESC


create table WebSite.Logs (
    _id bigint primary key identity,
    log nvarchar(max),

    severity AS JSON_VALUE(log, '$.severity'),
    index ix_severity (severity)
);

SELECT log
FROM Website.Logs
WHERE JSON_VALUE(log, '$.severity') = 'P4'


create sequence WebSite.LogID as bigint;
go
create table WebSite.Logs (
    _id bigint default(next value for WebSite.LogID),
    log nvarchar(max),

    INDEX cci CLUSTERED COLUMNSTORE
);


create table WebSite.Logs (
  _id bigint identity primary key nonclustered,
  log nvarchar(4000)
) with (memory_optimized=on)


create table WebSite.Logs (

  _id bigint identity primary key nonclustered,
  log nvarchar(4000),

  severity AS cast(JSON_VALUE(log, '$.severity') as tinyint) persisted,
  index ix_severity (severity)

) with (memory_optimized=on)


CREATE PROCEDURE WebSite.UpdateData(@Id int, @Property nvarchar(100), @Value nvarchar(100))
WITH SCHEMABINDING, NATIVE_COMPILATION

AS BEGIN
    ATOMIC WITH (transaction isolation level = snapshot,  language = N'English')

    UPDATE WebSite.Logs
    SET log = JSON_MODIFY(log, @Property, @Value)
    WHERE _id = @Id;

END


-------------------------------------------------------------------------------------------------------------------------------
-- https://learn.microsoft.com/en-us/sql/relational-databases/json/import-json-documents-into-sql-server?view=sql-server-ver16

SELECT BulkColumn
FROM OPENROWSET(BULK 'C:\JSON\Books\book.json', SINGLE_CLOB) as j;


-- Load file contents into a variable
DECLARE @json NVARCHAR(MAX);
SELECT @json = BulkColumn
 FROM OPENROWSET(BULK 'C:\JSON\Books\book.json', SINGLE_CLOB) as j

-- Load file contents into a table
SELECT BulkColumn
INTO #temp
FROM OPENROWSET(BULK 'C:\JSON\Books\book.json', SINGLE_CLOB) as j

/*
Create a file storage account (for example, mystorage), a file share (for example, sharejson), and a folder in Azure File Storage by using the Azure portal or Azure PowerShell.
Upload some JSON files to the file storage share.
Create an outbound firewall rule in Windows Firewall on your computer that allows port 445. Your Internet service provider might block this port. If you get a DNS error (error 53) in the following step, then port 445 isn't open, or your ISP is blocking it.
Mount the Azure File Storage share as a local drive (for example T:).

Here's the command syntax:
	net use [drive letter] \\[storage name].file.core.windows.net\[share name] /u:[storage account name] [storage account access key]

Here's an example that assigns local drive letter T: to the Azure File Storage share:
	net use t: \\mystorage.file.core.windows.net\sharejson /u:myaccount hb5qy6eXLqIdBj0LvGMHdrTiygkjhHDvWjUZg3Gu7bubKLg==

You can find the storage account key and the primary or secondary storage account access key in the Keys section of Settings in the Azure portal.
Now you can access your JSON files from the Azure File Storage share by using the mapped drive, as shown in the following example:
SQL
*/

SELECT book.*
FROM OPENROWSET(BULK N't:\books\books.json', SINGLE_CLOB) AS json
CROSS APPLY OPENJSON(BulkColumn) WITH (
    id NVARCHAR(100),
    name NVARCHAR(100),
    price FLOAT,
    pages_i INT,
    author NVARCHAR(100)
) AS book



CREATE EXTERNAL DATA SOURCE MyAzureBlobStorage
WITH (
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://myazureblobstorage.blob.core.windows.net',
    CREDENTIAL = MyAzureBlobStorageCredential
);

BULK INSERT Product
FROM 'data/product.dat'
WITH ( DATA_SOURCE = 'MyAzureBlobStorage');

-------------------------------------------------------------------------------------------------------------------------------
-- Parse JSON documents into rows and columns

SELECT value
FROM OPENROWSET(BULK 'C:\JSON\Books\books.json', SINGLE_CLOB) AS j
CROSS APPLY OPENJSON(BulkColumn);

/*
{"id":"978-0641723445", "cat":["book","hardcover"], "name":"The Lightning Thief", ... }
{"id":"978-1423103349", "cat":["book","paperback"], "name":"The Sea of Monsters", ... }
{"id":"978-1857995879", "cat":["book","paperback"], "name":"Sophie's World : The Greek", ... }
{"id":"978-1933988177", "cat":["book","paperback"], "name":"Lucene in Action, Second", ... }
*/

SELECT book.*
FROM OPENROWSET(BULK 'C:\JSON\Books\books.json', SINGLE_CLOB) AS j
CROSS APPLY OPENJSON(BulkColumn) WITH (
    id NVARCHAR(100),
    name NVARCHAR(100),
    price FLOAT,
    pages_i INT,
    author NVARCHAR(100)
) AS book;


