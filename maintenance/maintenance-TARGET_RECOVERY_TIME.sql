-- https://sqlperformance.com/2020/05/system-configuration/0-to-60-switching-to-indirect-checkpoints

DECLARE @sql nvarchar(max) = N'';
 
SELECT @sql += N'ALTER DATABASE ' + QUOTENAME(name) + ' SET TARGET_RECOVERY_TIME = 60 SECONDS;' 
  FROM sys.databases AS d 
  WHERE target_recovery_time_in_seconds = 0
    AND database_id > 4 
    AND [state] = 0
    AND is_read_only = 0
    AND NOT EXISTS 
    (
      SELECT 1 FROM sys.dm_hadr_availability_replica_states AS s
        INNER JOIN sys.availability_databases_cluster AS c
             ON s.group_id  = c.group_id 
          WHERE c.database_name = d.name
            AND (s.role_desc <> 'PRIMARY' OR s.is_local = 0) 
    );
 
SELECT DatabaseCount = @@ROWCOUNT, Version = @@VERSION, cmd = @sql;
 
print @sql;

--EXEC sys.sp_executesql @sql;

/*
ALTER DATABASE [Logging] SET TARGET_RECOVERY_TIME = 60 SECONDS;
ALTER DATABASE [octopus] SET TARGET_RECOVERY_TIME = 60 SECONDS;
ALTER DATABASE [jenkins_cms_test] SET TARGET_RECOVERY_TIME = 60 SECONDS;
ALTER DATABASE [ProGet] SET TARGET_RECOVERY_TIME = 60 SECONDS;
ALTER DATABASE [kraken] SET TARGET_RECOVERY_TIME = 60 SECONDS;
*/
