DECLARE @a TABLE (id varchar(10))
DECLARE @b TABLE (id varchar(10))

INSERT INTO @a
    SELECT 'test1' UNION ALL SELECT 'test2'
INSERT INTO @b
    SELECT 'test1 ' UNION ALL SELECT 'test2'

SELECT 'x' + id + 'x' FROM @a
SELECT 'x' + id + 'x' FROM @b

SELECT * FROM @a a INNER JOIN @b b ON b.id = a.id



select 1 where 'a ' = 'a' -- true 
select 1 where ' a' = 'a' -- false

select 1 where 'a ' <> 'a' -- false 
select 1 where ' a' <> 'a' -- true


