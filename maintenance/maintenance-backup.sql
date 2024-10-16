-- backups

exec dbo.DatabaseBackup @Databases='SYSTEM_DATABASES', @BackupType='FULL'
exec dbo.DatabaseBackup @Databases='USER_DATABASES', @BackupType='FULL'

-- ok
exec dbo.DatabaseBackup @Databases='CMS', @BackupType='FULL'

exec dbo.DatabaseBackup @Databases='jenkins_cms_pullrequest', @BackupType='FULL'
exec dbo.DatabaseBackup @Databases='jenkins_cms_test', @BackupType='FULL'

exec dbo.DatabaseBackup @Databases='DataIntegration', @BackupType='FULL'
