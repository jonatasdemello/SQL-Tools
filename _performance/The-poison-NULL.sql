-- False:
SELECT '0=NULL', 
       (CASE WHEN 0=NULL THEN 'True' ELSE 'False' END);
-- False:
SELECT '0!=NULL',
       (CASE WHEN 0!=NULL THEN 'True' ELSE 'False' END);
-- Still false:
SELECT 'NULL=NULL',
       (CASE WHEN NULL=NULL THEN 'True' ELSE 'False' END);

So it stands to reason that this also applies to IN and NOT IN:

-- False:
SELECT 'NULL IN (0, 1)',
       (CASE WHEN NULL IN (0, 1, NULL) THEN 'True' ELSE 'False' END);
-- False:
SELECT 'NULL IN (0, 1, NULL)',
       (CASE WHEN NULL IN (0, 1, NULL) THEN 'True' ELSE 'False' END);
-- False:
SELECT 'NULL NOT IN (0, 1, NULL)',
       (CASE WHEN NULL NOT IN (0, 1, NULL) THEN 'True' ELSE 'False' END);

So far, so good. Now, let’s turn it around and look if we can look for a constant in a dataset that includes a NULL value:

-- True:
SELECT '1 IN (0, 1, NULL)',
       (CASE WHEN 1 IN (0, 1, NULL) THEN 'True' ELSE 'False' END);
-- False:
SELECT '1 NOT IN (0, 1, NULL)',
       (CASE WHEN 1 NOT IN (0, 1, NULL) THEN 'True' ELSE 'False' END);
-- False:
SELECT '1 NOT IN (2, 3, 4, NULL)',
       (CASE WHEN 1 NOT IN (2, 3, 4, NULL) THEN 'True' ELSE 'False' END);


x NOT IN (y, z, NULL)

… always returns false, because the NULL value could represent essentially anything, including the x. 
And so it is with the inner table, if there happens to be a NULL value among those rows.


The poison NULL

Let’s go bigger. Instead of comparing a fixed set of values, let’s look at a whole table. Here’s a quick setup:

--- Create the outer table, give it some rows:
CREATE TABLE #outer (
    i   int NOT NULL,
    CONSTRAINT PK PRIMARY KEY CLUSTERED (i)
);

INSERT INTO #outer (i) VALUES (1);

WHILE (@@ROWCOUNT<100000)
    INSERT INTO #outer (i)
    SELECT MAX(i) OVER ()+i
    FROM #outer;

--- Create the inner table, fill it with a copy of the outer table,
--- except for 10 random rows:
CREATE TABLE #inner (
    i   int NULL
);

CREATE UNIQUE CLUSTERED INDEX UCIX ON #inner (i);

INSERT INTO #inner (i)
SELECT i
FROM #outer;

--- Remove 10 random rows, to make things a little more interesting.
DELETE TOP (10) FROM #inner;

Now, let’s look at some simple IN () queries. First up:

SELECT *
FROM #outer
WHERE i IN (SELECT i FROM #inner);

This one equates to a really nice merge join, because the two tables have matching clustered indexes on the join column.
Simple is beautiful.

So what happens if we change the IN() to a NOT IN()?

SELECT *
FROM #outer
WHERE i NOT IN (SELECT i FROM #inner);

Why so complicated?

We expected the Semi Join to turn into an Anti Semi Join, but the plan now also contains a Nested Loop branch with a Row Count Spool – what’s that about? Turns out the Row Count Spool, along with its index seek, has to do with the NOT IN() and the fact that we’re looking at a nullable column. Remember that…

x NOT IN (y, z, NULL)

… always returns false, because the NULL value could represent essentially anything, including the x. And so it is with the inner table, if there happens to be a NULL value among those rows.

So the lower-right clustered index seek actually checks if there is a NULL value in the inner table’s join column, and if there is, the entire join subsequent Merge Join between the inner and outer tables will return zero rows.



Simplifying the plan

There are a number of ways we can simplify things.
Skipping the NULLs

You could change the column to a non-nullable type (so SQL Server won’t have to check for NULL values in the first place), or you could just tell SQL Server to ignore NULL values, by eliminating them with a WHERE clause:

SELECT *
FROM #outer
WHERE i NOT IN (SELECT i FROM #inner
                WHERE i IS NOT NULL);

Back to doing Merge Joins again.
Using NOT EXISTS instead of NOT IN

You could rewrite the query to use a NOT EXISTS construct, which will be optimized to form the exact same Merge Join plan as we saw above.

SELECT *
FROM #outer AS o
WHERE NOT EXISTS (SELECT i FROM #inner AS i
                  WHERE o.i=i.i);

Left Anti Join

You could write the query with a LEFT JOIN and a WHERE clause, but what it gains in readability, it loses adding an extra Filter operator that could slow the query down just a fraction:

SELECT o.*
FROM #outer AS o
LEFT JOIN #inner AS i ON o.i=i.i
WHERE i.i IS NULL;

Shoot first, filter rows later.
Getting fancy with set operators

You could use the EXCEPT set operator. It generates the same query plan in this case, but the downside is that you can only return the key column(s). But instead, EXCEPT does compare NULL values, unlike the equality operator in a regular join.

SELECT i FROM #outer
EXCEPT
SELECT i FROM #inner;

Left Anti Semi join, but with a Scan instead of Seek

I wrote a post a while ago about using set operators like INTERSECT to compare or join on null values, but Paul White has a really nice post that goes a lot more in depth.
