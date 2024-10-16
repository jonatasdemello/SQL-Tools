-- Iterate with T-SQL
-- https://learn.microsoft.com/en-us/troubleshoot/sql/database-engine/development/iterate-through-result-set

-------------------------------------------------------------------------------------------------------------------------------
-- One method is the use of temp tables. With this method, you create a snapshot of the initial SELECT statement and use it as a basis for cursoring.

/********** example 1 **********/
DECLARE @au_id char( 11 )

SET rowcount 0
SELECT * INTO #mytemp FROM authors

SET rowcount 1

SELECT @au_id = au_id FROM #mytemp

WHILE @@rowcount <> 0
BEGIN
	SET rowcount 0
	SELECT * FROM #mytemp WHERE au_id = @au_id
	DELETE #mytemp WHERE au_id = @au_id

	SET rowcount 1
	SELECT @au_id = au_id FROM #mytemp
END
SET rowcount 0

-------------------------------------------------------------------------------------------------------------------------------
-- A second method is to use the min function to walk a table one row at a time. 

/********** example 2 **********/
DECLARE @au_id char( 11 )

SELECT @au_id = min( au_id ) FROM authors

WHILE @au_id IS NOT NULL
BEGIN
	SELECT * FROM authors WHERE au_id = @au_id
	SELECT @au_id = min( au_id ) FROM authors WHERE au_id > @au_id
END

-------------------------------------------------------------------------------------------------------------------------------

/********** example 3 **********/
SET rowcount 0
SELECT NULL mykey, * INTO #mytemp FROM authors

SET rowcount 1
UPDATE #mytemp SET mykey = 1

WHILE @@rowcount > 0
BEGIN
	SET rowcount 0
	SELECT * FROM #mytemp WHERE mykey = 1
	DELETE #mytemp WHERE mykey = 1
	SET rowcount 1
	UPDATE #mytemp SET mykey = 1
END
SET rowcount 0
w

