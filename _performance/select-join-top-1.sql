
-- https://www.red-gate.com/simple-talk/sql/t-sql-programming/how-to-get-nulls-horribly-wrong-in-sql-server/

-- https://www.sqlshack.com/design-sql-queries-better-performance-select-exists-vs-vs-joins/

-- https://www.red-gate.com/simple-talk/sql/t-sql-programming/how-to-get-nulls-horribly-wrong-in-sql-server/

-- https://sqlperformance.com/2013/08/t-sql-queries/parameter-sniffing-embedding-and-the-recompile-options
-- https://sqlperformance.com/2012/12/t-sql-queries/left-anti-semi-join

-- https://www.sqlservercentral.com/articles/understanding-and-using-apply-part-1
-- https://www.sqlservercentral.com/articles/understanding-and-using-apply-part-2

-- By using an OUTER APPLY we can join the 2 tables and get the most recent address like this: 

SELECT c.*, la.*
FROM Customer c
OUTER APPLY 
 (
	SELECT TOP 1 *
    FROM Address a
    WHERE a.CustomerID = c.CustomerID
    ORDER BY a.DateAdded DESC
  ) AS la
	

-- There are two main types of APPLY operators. 
-- 1) CROSS APPLY and 
-- 2) OUTER APPLY.

-- The CROSS APPLY operator is semantically similar to INNER JOIN operator. 
-- It retrieves those records from the table valued function and the table being joined, 
-- where it finds matching rows between the two.

-- On the other hand, OUTER APPLY retrieves all the records from both the table valued function and the table, 
-- irrespective of the match. 



-- Use a Complete Subquery when you don’t have indexes

-- Correlated subqueries break down when the foreign key isn’t indexed, because each subquery will require a full table scan.

-- In that case, we can speed things up by rewriting the query to use a single subquery, only scanning the widgets table once:

select * from users join (
    select distinct on (user_id) * from widgets
    order by user_id, created_at desc
) as most_recent_user_widget
on users.id = most_recent_user_widget.user_i

-- Use Nested Subqueries if you have an ordered ID column

-- In our example, the most recent row always has the highest id value. This means that even without DISTINCT ON, we can cheat with our nested subqueries like this:

select * from users join (
    select * from widgets
    where id in (
        select max(id) from widgets group by user_id
    )
) as most_recent_user_widget
on users.id = most_recent_user_widget.user_id

-- We start by selecting the list of IDs representing the most recent widget per user. Then we filter the main widgets table to those IDs. This gets us the same result as DISTINCT ON since sorting by id and created_at happen to be equivalent.

-- Use Nested Subqueries if you have an ordered ID column

-- In our example, the most recent row always has the highest id value. This means that even without DISTINCT ON, we can cheat with our nested subqueries like this:

select * from users join (
    select * from widgets
    where id in (
        select max(id) from widgets group by user_id
    )
) as most_recent_user_widget
on users.id = most_recent_user_widget.user_id

-- We start by selecting the list of IDs representing the most recent widget per user. Then we filter the main widgets table to those IDs. This gets us the same result as DISTINCT ON since sorting by id and created_at happen to be equivalent.



-- Use Window Functions if you need more control

-- If your table doesn’t have an id column, or you can’t depend on its min or max to be the most recent row, use row_number with a window function. It’s a little more complicated, but a lot more flexible:

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

-- The interesting part is here:

select *, row_number() over (
    partition by user_id
    order by created_at desc
) as row_num
from widgets

-- over (partition by user_id order by created_at desc specifies a sub-table, called a window, per user_id, and sorts those windows by created_at desc. row_number() returns a row’s position within its window. Thus the first widget for each user_id will have row_number 1.

-- In the outer subquery, we select only the rows with a row_number of 1. With a similar query, you could get the 2nd or 3rd or 10th rows instead.

