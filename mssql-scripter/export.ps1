# example: 

mssql-scripter -S localhost -U Spock -P P@ssw0rd -d cms_dev --include-objects RealGame.Location --data-only -f c:\temp\export\location.sql

#:: export CMS table

mssql-scripter -S localhost -U Spock -P P@ssw0rd -d CC3_CMS_Stage --include-objects School.SchoolInfo --data-only -f D:\workspace\CMS\data\School.SchoolInfo.data.sql

mssql-scripter -S localhost -U Spock -P P@ssw0rd -d CC3_CMS_Stage --include-objects School.SchoolInfo --data-only -f D:\workspace\CMS\data\School.SchoolInfo.data.sql

mssql-scripter -S localhost -U Spock -P P@ssw0rd -d CC3_CMS_Stage --include-objects School.SchoolInfo -f D:\workspace\CMS\data\School.SchoolInfo.table.sql

