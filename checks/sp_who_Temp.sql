

declare @tempTable table (SPID INT,Status VARCHAR(255),Login VARCHAR(255),HostName VARCHAR(255),BlkBy VARCHAR(255),DBName VARCHAR(255),
	Command VARCHAR(255),CPUTime INT,DiskIO INT,LastBatch VARCHAR(255),ProgramName VARCHAR(255),SPID2 INT,REQUESTID INT);

INSERT INTO @tempTable 
	EXEC sp_who2

select * from @tempTable ORDER BY [@tempTable].DBName
