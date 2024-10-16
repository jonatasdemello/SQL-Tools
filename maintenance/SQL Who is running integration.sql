-- SQL Who is running integration during the Day

USE DataIntegration
GO 

-- Who's running integrations?!?
SELECT id.IntegrationDistrictId, id.Name, h.StartTime, h.EndTime, DATEDIFF(s, h.StartTime, h.EndTime) / 60.0 AS [TimeTakenMinutes], s.Name AS LastStatus, h.[Message], CASE WHEN bh.ExecutionSourceId = 2 THEN 'Manual' ELSE 'Scheduled' END AS ExecutionType, lr.UserName AS LstRunBy
FROM [audit].BatchIntegrationHistory h
INNER JOIN dbo.Integration i ON (i.IntegrationId = h.IntegrationId)
INNER JOIN dbo.IntegrationDistrict id ON (id.IntegrationDistrictId = i.IntegrationDistrictId)
INNER JOIN dbo.IntegrationStatus s ON (s.IntegrationStatusId = i.IntegrationStatusId)
INNER JOIN [audit].BatchHistory bh ON (bh.BatchId = h.BatchId)
OUTER APPLY
(	
	SELECT TOP 1 [UserName]
	FROM [audit].UserActivityLog l
	WHERE l.IntegrationDistrictId = id.IntegrationDistrictId AND l.LogMessage = 'Integration was run.'
	ORDER BY l.CreatedDate DESC
) lr
WHERE h.StartTime > '2021-02-23 7:00:00' AND h.StartTime < '2021-02-23 9:00:00'
ORDER BY h.StartTime
