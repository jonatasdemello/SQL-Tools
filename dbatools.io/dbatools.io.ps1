
https://docs.dbatools.io/#Get-DbaDbTable
https://docs.dbatools.io/#Copy-DbaDbTableData
https://docs.dbatools.io/#Export-DbaDbTableData
https://docs.dbatools.io/#Write-DbaDbTableData


PS C:\> Copy-DbaDbTableData -SqlInstance sql1 -Destination sql2 -Database dbatools_from -Table dbo.test_table

Copies all the data from table dbo.test_table (2-part name) in database dbatools_from on sql1 to table test_table in database dbatools_from on sql2.
Example: 2

PS C:\> Copy-DbaDbTableData -SqlInstance sql1 -Destination sql2 -Database dbatools_from -DestinationDatabase dbatools_dest -Table [Schema].[test table]

Copies all the data from table [Schema].[test table] (2-part name) in database dbatools_from on sql1 to table [Schema].[test table] in database dbatools_dest on sql2
Example: 3

PS C:\> Get-DbaDbTable -SqlInstance sql1 -Database tempdb -Table tb1, tb2 | Copy-DbaDbTableData -DestinationTable tb3

Copies all data from tables tb1 and tb2 in tempdb on sql1 to tb3 in tempdb on sql1
Example: 4

PS C:\> Get-DbaDbTable -SqlInstance sql1 -Database tempdb -Table tb1, tb2 | Copy-DbaDbTableData -Destination sql2

Copies data from tb1 and tb2 in tempdb on sql1 to the same table in tempdb on sql2
Example: 5

PS C:\> Copy-DbaDbTableData -SqlInstance sql1 -Destination sql2 -Database dbatools_from -Table test_table -KeepIdentity -Truncate

Copies all the data in table test_table from sql1 to sql2, using the database dbatools_from, keeping identity columns and truncating the destination


-------------------------------------------------------------------------------------------------------------------------------
Get-DbaDbTable -SqlInstance 127.0.0.1 -Database CMS_Stage -Table Study.MajorInfo | Copy-DbaDbTableData -DestinationDatabase CMS_Dev -Table Study.MajorInfo -KeepIdentity -Truncate

