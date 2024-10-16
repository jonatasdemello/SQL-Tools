
declare @GroupIds VARCHAR(MAX) = '1,2,3,xx'

DECLARE @GroupList table ( GroupId int )

select * from dbo.udf_SplitString2Table(@GroupIds)

insert into @GroupList
select TRY_CAST(item AS INT) from dbo.udf_SplitString2Table(@GroupIds)

select * from @GroupList


