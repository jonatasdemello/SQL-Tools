-- Remove Duplicated Rows

-- NOTE: This will be run in an upgrade script ONLY if duplicate records are found
-- Select ALL records where the combination of SchoolID AND RequirementID are repeated and create a temporary table with them

SELECT SchoolID, RequirementID, COUNT(*) AS NumberOfRepeatedRows 
INTO #ControlTable 
FROM School.RequirementSchoolRel 
GROUP BY SchoolID, RequirementID 
HAVING COUNT(*) > 1

-- While records where the combination of SchoolID AND RequirementID are repeated still exist in the target table

WHILE EXISTS (Select SchoolID, RequirementID, COUNT(*) AS NumberOfRepeatedRows FROM School.RequirementSchoolRel GROUP BY SchoolID, RequirementID HAVING 
COUNT(*) > 1)
BEGIN

-- Delete the record in the target table using the SchoolID AND RequirementID from the TOP 1 record in the temporary table
   DELETE FROM School.RequirementSchoolRel WHERE SchoolID = (SELECT TOP 1 SchoolID FROM #ControlTable) AND RequirementID = (SELECT TOP 1 RequirementID FROM #ControlTable)

   -- Delete the record from the Control Table so it doesn`t cause an infinite loop
   DELETE FROM #ControlTable WHERE SchoolID = (SELECT TOP 1 SchoolID FROM #ControlTable) AND RequirementID = (SELECT TOP 1 RequirementID FROM #ControlTable)

END

-- Repopulation of the target table happens AFTER the upgrade script has run, this is just here for demonstration purposes
EXEC [Dataset].[SC_Requirement]

-- Step #1:

-- Verify that there are actual dupes in the table.

-- I don`t know anything about School.RequirementSchoolRel but when I look at one of the dupes (SchoolId = 490, RequirementID = 6), the records do have some differences in terms of the RequiementTypeID column. Because of this, we have to ask ourselves a few questions.

-- Can a school + requirement belong to multiple requirement types?
-- If yes, then is this truly a dupe? Most likely we have a problem downstream somewhere, but the data is fine.
-- If no, then why do we even have RequirementTypeID in this table? It would be better to remove it and put a unique constraint on SchoolID + RequirementID so that dupes can`t physically make it into the table.

-- This one requires some critical thinking and understanding of how the table is used, so Ill leave that up to the team. For now, Ill assume they`re legit dupes and we want them gone (my favorite part) image.png
-- Step #2:

-- Identify the dupes using a SELECT in conjunction with the ROW_NUMBER() function.

WITH CTE_Dupes AS
(
	Select *, ROW_NUMBER() OVER(PARTITION BY SchoolId, RequirementId ORDER BY ID) AS RowId 
	FROM School.RequirementSchoolRel 	
)
SELECT *
FROM CTE_Dupes d
ORDER BY SchoolId, RequirementId;

-- Yep, this is a case of duplicates and triplicates (anything where RowId <> 1 is a candidate for deletion). image.png
-- Step #3:

-- A slight tweak to the above query turns it into a DELETE that will delete anything where RowId > 1

WITH CTE_Dupes AS
(
	Select *, ROW_NUMBER() OVER(PARTITION BY SchoolId, RequirementId ORDER BY ID) AS RowId 
	FROM School.RequirementSchoolRel 	
)
DELETE d
FROM CTE_Dupes d
WHERE RowId > 1;

-- Note: I tested this, but rolled it back just in case you need to do any of the step #1 evaluation. Assuming these are actual dupes we dont want, feel free to run the script in step #3. Functionally, the above delete is the exact same as the looping logic, but its going to be faster because it`s a set-based operation rather than a cursor based one.

