
-- Found a couple of similar questions here on this, but couldn't figure out how to apply to my scenario.
-- My function has a parameter called @IncludeBelow. Values are 0 or 1 (BIT).
-- I have this query:

SELECT p.*
FROM Locations l
INNER JOIN Posts p on l.LocationId = p.LocationId
WHERE l.Condition1 = @Value1
AND   l.SomeOtherCondition = @SomeOtherValue

-- If @IncludeBelow is 0, i need the query to be this:

SELECT p.*
FROM Locations l
INNER JOIN Posts p on l.LocationId = p.LocationId
WHERE l.Condition1 = @Value1
AND   l.SomeOtherCondition = @SomeOtherValue
AND   p.LocationType = @LocationType -- additional filter to only include level.

-- If @IncludeBelow is 1, that last line needs to be excluded. (i.e don't apply filter).
-- I'm guessing it needs to be a CASE statement, but can't figure out the syntax.
-- Here's what i've tried:

SELECT p.*
FROM Locations l
INNER JOIN Posts p on l.LocationId = p.LocationId
WHERE l.Condition1 = @Value1
AND   l.SomeOtherCondition = @SomeOtherValue
AND (CASE @IncludeBelow WHEN 0 THEN p.LocationTypeId = @LocationType ELSE 1 = 1)

-------------------------------------------------------------------------------------------------------------------------------
--You can write it as

SELECT  p.*
  FROM  Locations l
INNER JOIN Posts p ON l.LocationId = p.LocationId
  WHERE l.Condition1 = @Value1
    AND l.SomeOtherCondition = @SomeOtherValue
    AND ((@IncludeBelow = 1) OR (p.LocationTypeId = @LocationType))

-- which is a pattern you see a lot e.g. for optional search parameters. But IIRC that can mess up the query execution plans so there may be a better way to do this.

-- Since it's only a bit, it almost might be worth deciding between two blocks of SQL with or without the check, e.g. using an IF in a stored procedure or with different command strings in calling code, based on the bit?

-- You can change your CASE statement to this. The query planner sees this differently, but it may be no more efficient than using OR:

	(p.LocationTypeId = CASE @IncludeBelow WHEN 0 THEN p.LocationTypeId ELSE @LocationType END)




IF OBJECT_ID('dbo.GetCities') IS NULL
	EXEC ('CREATE PROCEDURE dbo.GetCities AS RETURN 0')
GO

ALTER PROCEDURE dbo.GetCities
	@StateProvinceID int
AS
SELECT DISTINCT City
FROM Person.Address
WHERE StateProvinceID=@StateProvinceID;

/* imagine lots of other statements here */
GO

