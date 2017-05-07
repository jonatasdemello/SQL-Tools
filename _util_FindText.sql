

SELECT text, * FROM sys.syscomments WHERE text LIKE '%ProjectMgmntLibrary_ProjectMgmntSet%'

SELECT name, text, xtype, type FROM sys.syscomments 
	LEFT JOIN sys.sysobjects ON sys.syscomments.id = sys.sysobjects.id
	WHERE text LIKE '%ProjectMgmntSets_Organisations%'
   