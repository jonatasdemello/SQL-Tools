-- Remove all Foreign Keys from DB
declare @sql nvarchar(max) = (
    select
        'alter table ' + quotename(schema_name(schema_id)) + '.' +
        quotename(object_name(parent_object_id)) +
        ' drop constraint '+quotename(name) + ';'
    from sys.foreign_keys
    for xml path('')
);
print @sql;

exec sp_executesql @sql;