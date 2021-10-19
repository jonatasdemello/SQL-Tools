--http://stackoverflow.com/questions/2043259/sql-server-how-to-join-to-first-row

SELECT   Orders.OrderNumber, LineItems.Quantity, LineItems.Description
FROM     Orders
JOIN     LineItems
ON       LineItems.LineItemGUID =
         (
         SELECT  TOP 1 LineItemGUID 
         FROM    LineItems
         WHERE   OrderID = Orders.OrderID
         )
--In SQL Server 2005 and above, you could just replace INNER JOIN with CROSS APPLY:

SELECT  Orders.OrderNumber, LineItems2.Quantity, LineItems2.Description
FROM    Orders
CROSS APPLY
        (
        SELECT  TOP 1 LineItems.Quantity, LineItems.Description
        FROM    LineItems
        WHERE   LineItems.OrderID = Orders.OrderID
        ) LineItems2
		

--https://www.periscopedata.com/blog/4-ways-to-join-only-the-first-row-in-sql.html

--sql join 1 result only

--


--Use Correlated Subqueries when the foreign key is indexed

select * from users join widgets on widgets.id = (
    select id from widgets
    where widgets.user_id = users.id
    order by created_at desc
    limit 1
)

--Use a Complete Subquery when you don’t have indexes

select * from users join (
    select distinct on (user_id) * from widgets
    order by user_id, created_at desc
) as most_recent_user_widget
on users.id = most_recent_user_widget.user_id


--Use Nested Subqueries if you have an ordered ID column

select * from users join (
    select * from widgets
    where id in (
        select max(id) from widgets group by user_id
    )
) as most_recent_user_widget
on users.id = most_recent_user_widget.user_id

--Use Window Functions if you need more control

select * from users join (
    select * from (
        select *, row_number() over (
            partition by user_id
            order by created_at desc
        ) as row_num
        from widgets
    ) as ordered_widgets
    where ordered_widgets.row_num = 1
) as most_recent_user_widget
on users.id = most_recent_user_widget.user_id
order by users.id

---The interesting part is here:

select *, row_number() over (
    partition by user_id
    order by created_at desc
) as row_num
from widgets
