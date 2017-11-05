-- verificar em stored procedure:
select id, [text] from sys.syscomments where text like '%PlanID%'

select top 10 * from sys.syscolumns where name like 'UserID'
select top 10 * from sys.tables 

select top 100 C.name, C.id, T.name, T.object_id  
	from sys.syscolumns C
	left join sys.tables T on T.object_id =C.id
	where C.name like 'UserID'

select top 10 * from sys.tables where name like 'PlanID'


/* decobrir em qual tabela uma coluna existe */
select * 
	from information_schema.COLUMNS 
	where column_name like 'UserID%' 
	order by table_name
