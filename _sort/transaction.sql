EXEC sp_repldone @xactid = NULL, @xact_segno = NULL, @numtrans = 0,     @time = 0, @reset = 1

select * from sysobjects
select * from sysdatabases
select * from sysfiles

DBCC OPENTRAN(senar_prod)

use senar_prod
go
sp_repldone @xactid = NULL, @xact_segno = NULL, @numtrans = 0,@time = 0,@reset = 1
go

senar_prod_dat                                                                                                                  
senar_prod_log                                                                                                                  


checkpoint

DUMP TRANSACTION senar_prod WITH NO_LOG 
DBCC SHRINKDATABASE (N'senar_prod', 0,TRUNCATEONLY)

DBCC SHRINKFILE (N'senar_prod_log', 100,TRUNCATEONLY)

DBCC SHRINKDATABASE (N'senar_prod', 100,NOTRUNCATE )



DUMP TRANSACTION senar WITH NO_LOG 

DUMP TRANSACTION testes WITH NO_LOG 

DBCC SHRINKDATABASE (N'testes', 0,TRUNCATEONLY)

DUMP TRANSACTION ReportServer WITH NO_LOG 

DUMP TRANSACTION rh_senarprparal WITH NO_LOG 
DBCC SHRINKDATABASE (N'rh_senarprparal', 0,TRUNCATEONLY)


DUMP TRANSACTION saas WITH NO_LOG 
DBCC SHRINKDATABASE (N'saas', 0,TRUNCATEONLY)

DUMP TRANSACTION saas2003 WITH NO_LOG 
DBCC SHRINKDATABASE (N'saas2003', 0,TRUNCATEONLY)

DUMP TRANSACTION saas2004 WITH NO_LOG 
DBCC SHRINKDATABASE (N'saas2004', 0,TRUNCATEONLY)

sp_helptext 

sp_repldone senar_prod

-- #####################################

use senar_prod
go
create table shrinkfile(
col1 int,
col2 char(2048)
)

dump tran senar_prod with no_log
dbcc shrinkfile(senar_prod_log, 50, TRUNCATEONLY)
go

set nocount on
declare @i int
declare @limit int

select @i = 0
select @limit = 10000

while @i < @limit
begin
insert into shrinkfile values(@i, 'Shrink the log...')
select @i = @i + 1
end

-- if needed
update shrinkfile
set col2 = 'Shrink the log again...'

--Clean up
drop table shrinkfile


