https://canro91.github.io/2020/10/08/ExistsSelectSQLServer/


EXISTS SELECT 1 vs EXISTS SELECT * in SQL Server
08 Oct 2020 #todayilearned #sql

EXISTS is a logical operator that checks if a subquery returns any rows. EXISTS works only with SELECT statements inside the subquery. Let’s see if there are any differences between EXISTS with SELECT * and SELECT 1.

There is no difference between EXISTS with SELECT * and SELECT 1. SQL Server generates similar execution plans in both scenarios. EXISTS returns true if the subquery returns one or more records. Even if it returns NULL or 1/0.

Let’s use StackOverflow database to find users from Antartica who have left any comments. Yes, the same StackOverflow we use everyday to copy and paste code.

Let’s check how the execution plans look like when using SELECT * and SELECT 1 in the subquery with the EXISTS operator.
EXISTS with “SELECT *”

This is the query to find all users from Antartica who have commented anything. This query uses EXISTS with SELECT *.

SELECT *
FROM dbo.Users u
WHERE u.Location = 'Antartica'
AND EXISTS(SELECT * FROM dbo.Comments c WHERE u.Id = c.UserId);

To make things faster, let’s add one index on Location and another one on UserId on the dbo.Users and dbo.Comments tables, respectively.

CREATE INDEX UserId ON dbo.Comments(UserId);
CREATE INDEX Location ON dbo.Users(Location);
GO

Let’s check the execution plan. Notice the “Left Semi Join” operator and the other operators.
Execution plan using EXISTS with 'SELECT *'
Execution plan using EXISTS with 'SELECT *'
EXISTS with “SELECT 1”

Now, let’s change the subquery inside the EXISTS to use SELECT 1.

SELECT *
FROM dbo.Users u
WHERE u.Location = 'Antartica'
AND EXISTS(SELECT 1 FROM dbo.Comments c WHERE u.Id = c.UserId)

Again, let’s see the execution plan.
Execution plan using EXISTS with 'SELECT 1'
Execution plan using EXISTS with 'SELECT 1'

Voilà! Notice, there is no difference between the two execution plans when using EXISTS with SELECT * and SELECT 1. We can even rewrite the query to use SELECT NULL or SELECT 1/0 without any division-by-zero error.

If you want to read more SQL and SQL Server content, check how to write Dynamic SQL and three differences between TRUNCATE and DELETE.

Happy SQL time!