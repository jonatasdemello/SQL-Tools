-- rename columns
EXEC sp_RENAME 'TableName.OldColumnName' , 'NewColumnName', 'COLUMN'


-- IconId
--[Spark].[EducationPathType]

--Column               | Datatype      | Computed value
-------------------------------------------------------
--PathTypeId           | int           |               
--PathTypeFriendlyName | nvarchar(500) |               
--PathTypeIconId       | int           |               


EXEC sp_RENAME '[Spark].[EducationPathType].PathTypeIconId' , 'IconId', 'COLUMN'
EXEC sp_RENAME '[Spark].[EducationPathType].PathTypeFriendlyName' , 'FriendlyName', 'COLUMN'


--[Spark].[Subject]

--Column              | Datatype      | Computed value
------------------------------------------------------
--SubjectId           | int           |               
--SubjectFriendlyName | nvarchar(500) |               
--IconId              | int           |               

EXEC sp_RENAME '[Spark].[Subject].SubjectFriendlyName' , 'FriendlyName', 'COLUMN'

--[Spark].[Workplace]

--Column                | Datatype      | Computed value
--------------------------------------------------------
--WorkplaceId           | int           |               
--WorkplaceFriendlyName | nvarchar(500) |               
--IconId                | int           |               

EXEC sp_RENAME '[Spark].[Workplace].WorkplaceFriendlyName' , 'FriendlyName', 'COLUMN'

--[Spark].[SubjectTopic]

--Column                   | Datatype      | Computed value
-----------------------------------------------------------
--SubjectTopicId           | int           |               
--SubjectId                | int           |               
--SubjectTopicFriendlyName | nvarchar(500) |               
--IconId                   | int           |               

EXEC sp_RENAME '[Spark].[SubjectTopic].SubjectTopicFriendlyName' , 'FriendlyName', 'COLUMN'
