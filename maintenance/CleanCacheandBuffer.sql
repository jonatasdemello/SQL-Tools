-- SQL SERVER – Stored Procedure – Clean Cache and Clean Buffer
-- https://blog.sqlauthority.com/2007/03/23/sql-server-stored-procedure-clean-cache-and-clean-buffer/
	
DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS


DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

--'FreeProcCache', 'FreeSessionCache', 'FreeSystemCache'

-- drop buffers
DBCC DROPCLEANBUFFERS; 
DBCC FREEPROCCACHE;
DBCC FREESYSTEMCACHE('ALL');
DBCC FREESESSIONCACHE;

