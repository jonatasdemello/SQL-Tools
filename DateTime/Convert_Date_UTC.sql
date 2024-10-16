

-- If they're all local to you, then here's the offset:

SELECT GETDATE() AS CurrentTime, GETUTCDATE() AS UTCTime

-- and you should be able to update all the data using:

UPDATE SomeTable SET DateTimeStamp = DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), DateTimeStamp)



-- With SQL Server 2016, there is now built-in support for time zones with the AT TIME ZONE statement. You can chain these to do conversions:

SELECT YourOriginalDateTime AT TIME ZONE 'Pacific Standard Time' AT TIME ZONE 'UTC'

-- Or, this would work as well:

SELECT SWITCHOFFSET(YourOriginalDateTime AT TIME ZONE 'Pacific Standard Time', '+00:00')



LinkedByEducatorId INTEGER NULL, 


	[CreatedDateUTC] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
	[ModifiedDateUTC] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
	

	CreatedById INTEGER NOT NULL,
	CreatedDateUTC DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
	
	CreatedDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
	ModifiedDate DATETIME2 NOT NULL DEFAULT SYSDATETIME()
	
