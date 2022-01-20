
select * from sys.types
select * from sys.table_types
where name like 'CommonAppMemberType'

select 
    tt.name as TypeName, c.name as ColumnName, 
    c.*
from sys.table_types tt
inner join sys.columns c on c.object_id = tt.type_table_object_id
where tt.name like 'CommonAppMemberType'
order by c.column_id


select 
    tt.name AS table_Type, 
    c.name AS table_Type_col_name,
    st.name AS table_Type_col_datatype
from sys.table_types tt
inner join sys.columns c on c.object_id = tt.type_table_object_id
inner join sys.systypes AS ST  ON ST.xtype = c.system_type_id
where tt.name like 'CommonAppMemberType'
order by tt.name, c.column_id
