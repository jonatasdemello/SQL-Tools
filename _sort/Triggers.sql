
/*******************************************************************************/

-- Get Triggers w/ Code
SELECT
      Tables.Name TableName,
      Triggers.name TriggerName,
      Triggers.crdate TriggerCreatedDate,
      Comments.Text TriggerText
FROM
      sysobjects Triggers
      Inner Join sysobjects Tables On Triggers.parent_obj = Tables.id
      Inner Join syscomments Comments On Triggers.id = Comments.id
WHERE
      Triggers.xtype = 'TR'
      And Tables.xtype = 'U'
ORDER BY Tables.Name, Triggers.name

/*******************************************************************************/

SELECT s.name AS SchemaName
    ,ta.name AS TableName
    ,t.name AS TriggerName
    ,CASE
        WHEN t.is_disabled = 1 THEN 'Yes'
        ELSE 'No'
    END AS IsDisabled
    ,CASE
        WHEN t.is_instead_of_trigger = 1 THEN 'Yes'
        ELSE 'No'
    END AS IsInsteadOfTrigger
    ,te.type_desc AS TriggerType
    ,t.create_date AS DateCreated
    ,t.modify_date AS LastModifiedDate
FROM sys.triggers AS t
    INNER JOIN sys.trigger_events AS te ON te.[object_id] = t.[object_id]
    INNER JOIN sys.tables AS ta ON ta.[object_id] = t.parent_id
    INNER JOIN sys.schemas AS s ON s.[schema_id] = ta.[schema_id];
    