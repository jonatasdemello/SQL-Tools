
SELECT xactid AS TRAN_ID, op AS LOG_RECORD FROM syslogs

DBCC log ( {dbid|dbname}, [, type={0|1|2|3|4}] )


DBCC log ( senar_prod, 4)




