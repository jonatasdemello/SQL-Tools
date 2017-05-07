-- Encontrar StoreProcedures que contemo texto 'dump'

select id,text from syscomments where text like '%dump%'

-- crei: 

exec sp_texto 'crchinstrutor'