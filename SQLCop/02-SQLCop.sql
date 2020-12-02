/*
SQLCop:
-------
	https://github.com/red-gate/SQLCop

--	Make sure you have intalled tSQLt.class

*/
SET NOCOUNT ON;

print 'Make sure you have intalled tSQLt.class'

-- if we need to remove everything:
EXEC tSQLt.DropClass 'SQLCop';
GO

-- this will create the schema [SQLCop]:
EXEC tsqlt.NewTestClass @ClassName = N'SQLCop'
GO

-- All tests will run in the [SQLCop] schemma

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Ad_hoc_distributed_queries]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Ad_hoc_distributed_queries]
GO

CREATE PROCEDURE [SQLCop].[test_Ad_hoc_distributed_queries]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    select  @Output = 'Status: Ad Hoc Distributed Queries are enabled'
    from    sys.configurations
    where   name = 'Ad Hoc Distributed Queries'
            and value_in_use = 1

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Ad-Hoc-Distributed-Queries'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END; 
GO

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Agent_Service]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Agent_Service]
GO

CREATE PROCEDURE [SQLCop].[test_Agent_Service]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    DECLARE @service NVARCHAR(100)

    Set @Output = ''

    If Convert(VarChar(100), ServerProperty('Edition')) Like 'Express%'
      Select @Output = 'SQL Server Agent not installed for express editions'
    Else If Is_SrvRoleMember('sysadmin') = 0
      Select @Output = 'You need to be a member of the sysadmin server role to run this check'
    Else
      Begin
		-- CHAR(92) = \
        SELECT @service = CASE WHEN CHARINDEX(CHAR(92),@@SERVERNAME)>0
               THEN N'SQLAgent$'+@@SERVICENAME
               ELSE N'SQLSERVERAGENT' END

        Create Table #Temp(Output VarChar(1000))
        Insert Into #Temp
        EXEC master..xp_servicecontrol N'QUERYSTATE', @service

        Select  Top 1 @Output = Output
        From    #Temp
        Where   Output Not Like 'Running%'

        Drop    Table #Temp
      End

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'Could not find running SQL Agent:'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Auto_close]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Auto_close]
GO

CREATE PROCEDURE [SQLCop].[test_Auto_close]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    Select @Output = @Output + 'Database set to Auto Close' + Char(13) + Char(10)
    Where   DatabaseProperty(db_name(), 'IsAutoClose') = 1

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Auto-close'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Auto_create_statistics]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Auto_create_statistics]
GO

CREATE PROCEDURE [SQLCop].[test_Auto_create_statistics]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    Select @Output = @Output + 'Database not set to Auto Create Statistics' + Char(13) + Char(10)
    Where  DatabaseProperty(db_name(), 'IsAutoCreateStatistics') = 0

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Auto-create-statistics'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Auto_Shrink]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Auto_Shrink]
GO

CREATE PROCEDURE [SQLCop].[test_Auto_Shrink]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    Select @Output = @Output + 'Database set to Auto Shrink' + Char(13) + Char(10)
    Where  DatabaseProperty(db_name(), 'IsAutoShrink') = 1

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Auto-shrink'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Auto_update_statistics]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Auto_update_statistics]
GO

CREATE PROCEDURE [SQLCop].[test_Auto_update_statistics]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    Select @Output = @Output + 'Database not set to Auto Update Statistics' + Char(13) + Char(10)
    Where  DatabaseProperty(db_name(), 'IsAutoUpdateStatistics') = 0

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Auto-update-statistics'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Buffer_cache_hit_ratio]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Buffer_cache_hit_ratio]
GO

CREATE PROCEDURE [SQLCop].[test_Buffer_cache_hit_ratio]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max), @PermissionsErrors VarChar(max)
    Set @Output = ''
    Set @PermissionsErrors = SQLCop.DmOsPerformanceCountersPermissionErrors()

    If (@PermissionsErrors = '')
        SELECT  @Output = Convert(DECIMAL(4,1), (a.cntr_value * 1.0 / b.cntr_value) * 100.0)
        FROM    sys.dm_os_performance_counters  a
                JOIN  (
                    SELECT cntr_value,OBJECT_NAME
                    FROM   sys.dm_os_performance_counters
                    WHERE  counter_name collate SQL_LATIN1_GENERAL_CP1_CI_AI = 'Buffer cache hit ratio base'
                            AND OBJECT_NAME collate SQL_LATIN1_GENERAL_CP1_CI_AI like '%Buffer Manager%'
                    ) b
                    ON  a.OBJECT_NAME = b.OBJECT_NAME
        WHERE   a.counter_name collate SQL_LATIN1_GENERAL_CP1_CI_AI = 'Buffer cache hit ratio'
                AND a.OBJECT_NAME collate SQL_LATIN1_GENERAL_CP1_CI_AI like '%:Buffer Manager%'
                and Convert(DECIMAL(4,1), (a.cntr_value * 1.0 / b.cntr_value) * 100.0) < 95
    Else
        Set @Output = @PermissionsErrors

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Buffer-cache-hit-ratio'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Column_collation_does_not_match_database_default]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Column_collation_does_not_match_database_default]
GO

CREATE PROCEDURE [SQLCop].[test_Column_collation_does_not_match_database_default]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    DECLARE @Output VarChar(max)
    Set @Output = ''

    SELECT  @Output = @Output + C.TABLE_SCHEMA + '.' + C.TABLE_NAME + '.' + C.COLUMN_NAME + Char(13) + Char(10)
    FROM    INFORMATION_SCHEMA.COLUMNS C
            INNER JOIN INFORMATION_SCHEMA.TABLES T
                ON C.Table_Name = T.Table_Name
    WHERE   T.Table_Type = 'BASE TABLE'
            AND COLLATION_NAME <> convert(VarChar(100), DATABASEPROPERTYEX(db_name(), 'Collation'))
            AND COLUMNPROPERTY(OBJECT_ID(C.TABLE_NAME), COLUMN_NAME, 'IsComputed') = 0
            AND C.TABLE_SCHEMA <> 'tSQLt'
    Order By C.TABLE_SCHEMA, C.TABLE_NAME, C.COLUMN_NAME

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'hhttps://github.com/red-gate/SQLCop/wiki/Column-collation-does-not-match-database-default'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End

END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Column_data_types_Numeric_vs_Int]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Column_data_types_Numeric_vs_Int]
GO

CREATE PROCEDURE [SQLCop].[test_Column_data_types_Numeric_vs_Int]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    Select  @Output = @Output + ProblemItem + Char(13) + Char(10)
    From    (
            SELECT  TABLE_SCHEMA + '.' + TABLE_NAME + '.' + COLUMN_NAME As ProblemItem
            FROM    INFORMATION_SCHEMA.COLUMNS C
            WHERE   C.DATA_TYPE IN ('numeric','decimal')
                    AND NUMERIC_SCALE = 0
                    AND NUMERIC_PRECISION <= 18
                    AND TABLE_SCHEMA <> 'tSQLt'
            ) As Problems
    Order By ProblemItem

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Column-data-types-numeric-vs-int'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End

END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Column_Name_Problems]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Column_Name_Problems]
GO

CREATE PROCEDURE [SQLCop].[test_Column_Name_Problems]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    DECLARE @Output VarChar(max)
    Set @Output = ''

    SELECT  @Output = @Output + TABLE_SCHEMA + '.' + TABLE_NAME + '.' + COLUMN_NAME + Char(13) + Char(10)
    FROM    INFORMATION_SCHEMA.COLUMNS
    WHERE   COLUMN_NAME COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI LIKE '%[^a-z0-9_$]%'
            And TABLE_SCHEMA <> 'tSQLt'
    Order By TABLE_SCHEMA,TABLE_NAME,COLUMN_NAME

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Column-name-problems'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End

END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Columns_of_data_type_Text/nText]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Columns_of_data_type_Text/nText]
GO

CREATE PROCEDURE [SQLCop].[test_Columns_of_data_type_Text/nText]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    DECLARE @Output VarChar(max)
    Set @Output = ''

    SELECT  @Output = @Output + SCHEMA_NAME(o.uid) + '.' + o.Name + '.' + col.name + Char(13) + Char(10)
    from    syscolumns col
            Inner Join sysobjects o
                On col.id = o.id
            inner join systypes
                On col.xtype = systypes.xtype
    Where   o.type = 'U'
            And ObjectProperty(o.id, N'IsMSShipped') = 0
            AND systypes.name IN ('text','ntext')
            And SCHEMA_NAME(o.uid) <> 'tSQLt'
    Order By SCHEMA_NAME(o.uid),o.Name, col.Name

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Columns-of-data-type-Text-or-nText'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End

END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Columns_with_float_data_type]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Columns_with_float_data_type]
GO

CREATE PROCEDURE [SQLCop].[test_Columns_with_float_data_type]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    DECLARE @Output VarChar(max)
    Set @Output = ''

    SELECT  @Output = @Output + TABLE_SCHEMA + '.' + TABLE_NAME + '.' + COLUMN_NAME + Char(13) + Char(10)
    FROM    INFORMATION_SCHEMA.COLUMNS
    WHERE   DATA_TYPE IN ('float', 'real')
            AND TABLE_SCHEMA <> 'tSQLt'
    Order By TABLE_SCHEMA,TABLE_NAME,COLUMN_NAME

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Columns-with-float-data-type'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End

END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Columns_with_image_data_type]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Columns_with_image_data_type]
GO

CREATE PROCEDURE [SQLCop].[test_Columns_with_image_data_type]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    DECLARE @Output VarChar(max)
    Set @Output = ''

    SELECT  @Output = @Output + SCHEMA_NAME(o.uid) + '.' + o.Name + '.' + col.name
    from    syscolumns col
            Inner Join sysobjects o
                On col.id = o.id
            inner join systypes
                On col.xtype = systypes.xtype
    Where   o.type = 'U'
            And ObjectProperty(o.id, N'IsMSShipped') = 0
            And systypes.name In ('image')
            And SCHEMA_NAME(o.uid) <> 'tSQLt'
    Order By SCHEMA_NAME(o.uid),o.Name, col.Name

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Columns-with-image-data-type'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End

END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Compatibility_Level]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Compatibility_Level]
GO

CREATE PROCEDURE [SQLCop].[test_Compatibility_Level]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    Select @Output = @Output + name + Char(13) + Char(10)
    FROM   sys.databases
    WHERE  compatibility_level != 10 * CONVERT(Int, CONVERT(FLOAT, CONVERT(VARCHAR(3), SERVERPROPERTY('productversion'))))

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Compatibility-level'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End

END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Database_and_Log_files_on_the_same_disk]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Database_and_Log_files_on_the_same_disk]
GO

CREATE PROCEDURE [SQLCop].[test_Database_and_Log_files_on_the_same_disk]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    Select @Output = @Output + db_name() + Char(13) + Char(10)
    FROM   sys.database_files
    Having Count(*) != Count(Distinct Left(Physical_Name, 3))

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Database-and-log-on-same-disk'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Database_collation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Database_collation]
GO

CREATE PROCEDURE [SQLCop].[test_Database_collation]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    Select  @Output = @Output + 'Warning: Collation conflict between user database and TempDB' + Char(13) + Char(10)
    Where   DatabasePropertyEx('TempDB', 'Collation') <> DatabasePropertyEx(db_name(), 'Collation')

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Database-collation'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Database_Mail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Database_Mail]
GO

CREATE PROCEDURE [SQLCop].[test_Database_Mail]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    select @Output = @Output + 'Status: Database Mail procedures are enabled' + Char(13) + Char(10)
    from   sys.configurations
    where  name = 'Database Mail XPs'
           and value_in_use = 1

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Database-mail'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End

END;
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Decimal_Size_Problem]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Decimal_Size_Problem]
GO

CREATE PROCEDURE [SQLCop].[test_Decimal_Size_Problem]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    Select @Output = @Output + Schema_Name(schema_id) + '.' + name + Char(13) + Char(10)
    From    sys.objects
    WHERE   schema_id <> Schema_ID('SQLCop')
            And schema_id <> Schema_Id('tSQLt')
            and (
            REPLACE(REPLACE(Object_Definition(object_id), ' ', ''), 'decimal]','decimal') COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI LIKE '%decimal[^(]%'
            Or REPLACE(REPLACE(Object_Definition(object_id), ' ', ''), 'numeric]','numeric') COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI LIKE '%[^i][^s]numeric[^(]%'
            )
    Order By Schema_Name(schema_id), name

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Decimal-Size-Problem'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Forwarded_Records]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Forwarded_Records]
GO

CREATE PROCEDURE [SQLCop].[test_Forwarded_Records]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    DECLARE @Output VarChar(max)
    Set @Output = ''

    If Exists(Select compatibility_level from sys.databases Where database_id = db_ID() And compatibility_level > 80)
        Begin
            Create Table #Results(ProblemItem VarChar(1000))

            Insert Into #Results(ProblemItem)
            Exec (' SELECT  SCHEMA_NAME(O.Schema_Id) + ''.'' + O.name As ProblemItem
                    FROM    sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, ''DETAILED'') AS ps
                            INNER JOIN sys.indexes AS i
                                ON ps.OBJECT_ID = i.OBJECT_ID
                                AND ps.index_id = i.index_id
                            INNER JOIN sys.objects as O
                                On i.OBJECT_ID = O.OBJECT_ID
                    WHERE  ps.forwarded_record_count > 0
                    Order By SCHEMA_NAME(O.Schema_Id),O.name')

            If Exists(Select 1 From #Results)
                Select  @Output = @Output + ProblemItem + Char(13) + Char(10)
                From    #Results

        End
    Else
      Set @Output = 'Unable to check index forwarded records when compatibility is set to 80 or below'

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Forwarded-records'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End

END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Fragmented_Indexes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Fragmented_Indexes]
GO

CREATE PROCEDURE [SQLCop].[test_Fragmented_Indexes]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    DECLARE @Output VarChar(max)
    Set @Output = ''

    Create Table #Result (ProblemItem VarChar(1000))

    If Exists(Select compatibility_level from sys.databases Where database_id = db_ID() And compatibility_level > 80)
        If Exists(Select 1 From fn_my_permissions(NULL, 'DATABASE') WHERE permission_name = 'VIEW DATABASE STATE')
            Begin
                Insert Into #Result(ProblemItem)
                Exec('
                        SELECT  OBJECT_NAME(OBJECT_ID) + ''.'' + s.name As ProblemItem
                        FROM    sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL , NULL, N''LIMITED'') d
                                join sysindexes s
                                    ON  d.OBJECT_ID = s.id
                                    and d.index_id = s.indid
                        Where   avg_fragmentation_in_percent >= 30
                                And OBJECT_NAME(OBJECT_ID) + ''.'' + s.name > ''''
                                And page_count > 1000
                                Order By Object_Name(OBJECT_ID), s.name')
            End
        Else
            Set @Output = 'You do not have VIEW DATABASE STATE permissions within this database'
        Else
            Set @Output = 'Unable to check index fragmentation when compatibility is set to 80 or below'

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Fragmented-indexes'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Instant_File_Initialization]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Instant_File_Initialization]
GO

CREATE PROCEDURE [SQLCop].[test_Instant_File_Initialization]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    DECLARE @Output VarChar(max)
    Set @Output = ''

    CREATE TABLE #Output(Value VarChar(8000))

    If Exists(select * from sys.configurations Where name='xp_cmdshell' and value_in_use = 1)
        Begin
            If Is_SrvRoleMember('sysadmin') = 1
                Begin
                    Insert Into #Output EXEC ('xp_cmdshell ''whoami /priv''');

                    If Not Exists(Select 1 From #Output Where Value LIKE '%SeManageVolumePrivilege%')
                        Select @Output = 'Instant File Initialization disabled'
                    Else
                        Select  @Output = 'Instant File Initialization disabled'
                        From    #Output
                        Where   Value LIKE '%SeManageVolumePrivilege%'
                                And Value Like '%disabled%'
                End
            Else
                Set @Output = 'You do not have the appropriate permissions to run xp_cmdshell'
        End
    Else
        Begin
            Set @Output = 'xp_cmdshell must be enabled to determine if instant file initialization is enabled.'
        End
    Drop Table #Output

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Instant-file-initialization'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;
go

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Invalid_Objects]') AND type IN ( N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Invalid_Objects]
GO

CREATE PROCEDURE [SQLCop].[test_Invalid_Objects]
AS
BEGIN
    --  Test to identify Invalid Stored Procedures and Views
    --  If any invalid objects are found then fail the test with list of affected objects
    --  If you require a comprehensive list of Invalid Objects you can use the SQL Prompt find invalid objects functionality:
    --  https://documentation.red-gate.com/sp/sql-refactoring/refactoring-an-object-or-batch/finding-invalid-objects

    --  Written by Chris Unwin 17/09/2019

    SET NOCOUNT ON;

    --Assemble
    -- Declare and set output

    DECLARE @Output VARCHAR(MAX);
    Set @Output = '';

    -- Act
    -- Fetch all invalid objects from sys.sql_expression_dpenedencies and write to output

    SELECT @Output
        = @Output + 'Invalid ' + (CASE
                                      WHEN ob.type = 'P' THEN
                                          'stored procedure '
                                      WHEN ob.type = 'V' THEN
                                          'view '
                                      ELSE
                                          'object type ' + ob.type + ' '
                                  END
                                 ) + '[' + SCHEMA_NAME(ob.schema_id) + '].[' + OBJECT_NAME(dep.referencing_id)
          + '] relies on missing object [' + dep.referenced_schema_name + '].[' + dep.referenced_entity_name + ']'
          + CHAR(13) + CHAR(10)
    FROM sys.sql_expression_dependencies dep
        INNER JOIN sys.objects ob
            ON ob.object_id = dep.referencing_id
    WHERE dep.is_ambiguous = 0
          AND dep.referenced_id IS NULL
          AND dep.referenced_schema_name <> 'tSQLt'
          AND SCHEMA_NAME(ob.schema_id) <> 'tSQLt'
          AND SCHEMA_NAME(ob.schema_id) <> 'SQLCop';

    -- Assert
    -- Check if output is blank and pass, else fail with list of invalid objects

    IF @Output > ''
    BEGIN
        SET @Output = Char(13) + Char(10) + @Output;
        EXEC tSQLt.Fail @Output;
    END;
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Login_Language]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Login_Language]
GO

CREATE PROCEDURE [SQLCop].[test_Login_Language]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Declare @DefaultLanguage VarChar(100)

    Set @Output = ''

    Select  @DefaultLanguage = L.name
    From    sys.configurations C
            Inner Join sys.syslanguages L
              On C.value = L.langid
              And C.name = 'default language'

    Select  @Output = @Output + name + Char(13) + Char(10)
    From    sys.server_principals
    Where   default_language_name <> @DefaultLanguage
    Order By name

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Login-language'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Max_degree_of_parallelism]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Max_degree_of_parallelism]
GO

CREATE PROCEDURE [SQLCop].[test_Max_degree_of_parallelism]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max), @Warning VarChar(max)
    Set @Output = ''
    Set @Warning = 'Warning: Max degree of parallelism is setup to use all cores'

    IF (SERVERPROPERTY('EngineEdition') = 5 OR SERVERPROPERTY('EngineEdition') = 8)
        BEGIN
            select @Output = @Warning
            from   sys.database_scoped_configurations
            where  name = 'MAXDOP'
                and value = 0
        END
    ELSE
        BEGIN
            select @Output = @Warning
            from   sys.configurations
            where  name = 'max degree of parallelism'
                and value_in_use = 0
        END

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Max-degree-of-parallelism'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Missing_Foreign_Key_Indexes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Missing_Foreign_Key_Indexes]
GO

CREATE PROCEDURE [SQLCop].[test_Missing_Foreign_Key_Indexes]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    DECLARE @Output VarChar(max)
    Set @Output = ''

    If Exists(Select 1 From fn_my_permissions(NULL, 'DATABASE') WHERE permission_name = 'VIEW DATABASE STATE')
        SELECT  @Output = @Output + Convert(VarChar(300), fk.foreign_key_name) + Char(13) + Char(10)
        FROM    (
                SELECT  fk.name AS foreign_key_name,
                        'PARENT' as foreign_key_type,
                        fkc.parent_object_id AS object_id,
                        STUFF(( SELECT ', ' + QUOTENAME(c.name)
                                FROM    sys.foreign_key_columns ifkc
                                        INNER JOIN sys.columns c
                                            ON ifkc.parent_object_id = c.object_id
                                            AND ifkc.parent_column_id = c.column_id
                                WHERE fk.object_id = ifkc.constraint_object_id
                                ORDER BY ifkc.constraint_column_id
                                FOR XML PATH('')), 1, 2, '') AS fk_columns,
                        (   SELECT  QUOTENAME(ifkc.parent_column_id,'(')
                            FROM    sys.foreign_key_columns ifkc
                            WHERE   fk.object_id = ifkc.constraint_object_id
                            ORDER BY ifkc.constraint_column_id
                            FOR XML PATH('')) AS fk_columns_compare
                FROM    sys.foreign_keys fk
                        INNER JOIN sys.foreign_key_columns fkc
                            ON fk.object_id = fkc.constraint_object_id
                WHERE fkc.constraint_column_id = 1

                UNION ALL

                SELECT  fk.name AS foreign_key_name,
                        'REFERENCED' as foreign_key_type,
                        fkc.referenced_object_id AS object_id,
                        STUFF(( SELECT  ', ' + QUOTENAME(c.name)
                                FROM    sys.foreign_key_columns ifkc
                                        INNER JOIN sys.columns c
                                            ON ifkc.referenced_object_id = c.object_id
                                            AND ifkc.referenced_column_id = c.column_id
                                WHERE fk.object_id = ifkc.constraint_object_id
                                ORDER BY ifkc.constraint_column_id
                                FOR XML PATH('')), 1, 2, '') AS fk_columns,
                        (   SELECT  QUOTENAME(ifkc.referenced_column_id,'(')
                            FROM    sys.foreign_key_columns ifkc
                            WHERE   fk.object_id = ifkc.constraint_object_id
                            ORDER BY ifkc.constraint_column_id
                            FOR XML PATH('')) AS fk_columns_compare
                FROM    sys.foreign_keys fk
                        INNER JOIN sys.foreign_key_columns fkc
                            ON fk.object_id = fkc.constraint_object_id
                WHERE   fkc.constraint_column_id = 1
                ) fk
                INNER JOIN (
                    SELECT  object_id,
                            SUM(row_count) AS row_count
                    FROM    sys.dm_db_partition_stats ps
                    WHERE   index_id IN (1,0)
                    GROUP BY object_id
                ) rc
                    ON fk.object_id = rc.object_id
                LEFT OUTER JOIN (
                    SELECT  i.object_id,
                            i.name,
                            (
                            SELECT  QUOTENAME(ic.column_id,'(')
                            FROM    sys.index_columns ic
                            WHERE   i.object_id = ic.object_id
                                    AND i.index_id = ic.index_id
                                    AND is_included_column = 0
                            ORDER BY key_ordinal ASC
                            FOR XML PATH('')
                            ) AS indexed_compare
                    FROM    sys.indexes i
                    ) i
                ON fk.object_id = i.object_id
                AND i.indexed_compare LIKE fk.fk_columns_compare + '%'
        WHERE   i.name IS NULL
        ORDER BY OBJECT_NAME(fk.object_id), fk.fk_columns
    Else
        Set @Output = 'You do not have VIEW DATABASE STATE permissions within this database'

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Missing-foreign-key-indexes'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Missing_Foreign_Keys]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Missing_Foreign_Keys]
GO

CREATE PROCEDURE [SQLCop].[test_Missing_Foreign_Keys]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    DECLARE @Output VarChar(max)
    DECLARE @AcceptableSymbols VARCHAR(100)

    SET @AcceptableSymbols = '_$'
    Set @Output = ''

    SELECT  @Output = @Output + C.TABLE_SCHEMA + '.' + C.TABLE_NAME + '.' + C.COLUMN_NAME + Char(13) + Char(10)
    FROM    INFORMATION_SCHEMA.COLUMNS C
            INNER Join INFORMATION_SCHEMA.TABLES T
              ON C.TABLE_NAME = T.TABLE_NAME
              AND T.TABLE_TYPE = 'BASE TABLE'
              AND T.TABLE_SCHEMA = C.TABLE_SCHEMA
            LEFT Join INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE U
              ON C.TABLE_NAME = U.TABLE_NAME
              AND C.COLUMN_NAME = U.COLUMN_NAME
              AND U.TABLE_SCHEMA = C.TABLE_SCHEMA
    WHERE   U.COLUMN_NAME IS Null
            And C.TABLE_SCHEMA <> 'tSQLt'
            AND C.COLUMN_NAME COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI Like '%id'
    ORDER BY C.TABLE_SCHEMA, C.TABLE_NAME, C.COLUMN_NAME

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Missing-foreign-keys'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End

END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Old_Backups]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Old_Backups]
GO

CREATE PROCEDURE [SQLCop].[test_Old_Backups]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    Select  @Output = @Output + 'Outdated Backup For '+ D.name + Char(13) + Char(10)
    FROM    sys.databases As D
            Left Join msdb.dbo.backupset As B
              On  B.database_name = D.name
              And B.type = 'd'
    WHERE   D.state != 6
    GROUP BY D.name
    Having Coalesce(DATEDIFF(D, Max(backup_finish_date), Getdate()), 1000) > 7
    ORDER BY D.Name

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Old-backups'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Ole_Automation_Procedures]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Ole_Automation_Procedures]
GO

CREATE PROCEDURE [SQLCop].[test_Ole_Automation_Procedures]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    select @Output = @Output + 'Warning: Ole Automation procedures are enabled' + Char(13) + Char(10)
    from   sys.configurations
    where  name = 'Ole Automation Procedures'
           and value_in_use = 1

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Ole-automation-procedures'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Orphaned_Users]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Orphaned_Users]
GO

CREATE PROCEDURE [SQLCop].[test_Orphaned_Users]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    Set NOCOUNT ON
    If is_rolemember('db_owner') = 1
        Begin
            Declare @Temp Table(UserName sysname, UserSid VarBinary(85))

            Insert Into @Temp Exec sp_change_users_login 'report'

            Select @Output = @Output + UserName + Char(13) + Char(10)
            From   @Temp
            Order By UserName
        End
    Else
        Set @Output = 'Only members of db_owner can perform this check.'

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Orphaned-Users'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End

END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Page_life_expectancy]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Page_life_expectancy]
GO

CREATE PROCEDURE [SQLCop].[test_Page_life_expectancy]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max), @PermissionsError VarChar(max)
    Set @Output = ''
    Set @PermissionsError = SQLCop.DmOsPerformanceCountersPermissionErrors()
    
    If (@PermissionsError = '')
        SELECT  @Output = @Output + Convert(VarChar(100), cntr_value) + Char(13) + Char(10)
        FROM    sys.dm_os_performance_counters
        WHERE   counter_name collate SQL_LATIN1_GENERAL_CP1_CI_AI = 'Page life expectancy'
                AND OBJECT_NAME collate SQL_LATIN1_GENERAL_CP1_CI_AI like '%:Buffer Manager%'
                And cntr_value <= 300
    Else
        Set @Output = @PermissionsError

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Page-life-expectancy'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;
go
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('[SQLCop].[DmOsPerformanceCountersPermissionErrors]') AND TYPE = 'FN')
DROP FUNCTION [SQLCop].[DmOsPerformanceCountersPermissionErrors]
GO

CREATE FUNCTION [SQLCop].[DmOsPerformanceCountersPermissionErrors]()
RETURNS VARCHAR(MAX)
AS
BEGIN
    DECLARE @Result VARCHAR(MAX)
    SET @Result = ''

    IF (SERVERPROPERTY('EngineEdition') = 5)
        BEGIN
            IF (DATABASEPROPERTYEX(DB_NAME(), 'Edition') = 'Premium')
                BEGIN
                    IF NOT EXISTS(SELECT 1 FROM sys.fn_my_permissions(NULL, 'DATABASE') WHERE permission_name = 'VIEW DATABASE STATE')
                        SET @Result = 'You do not have VIEW DATABASE STATE permissions for this database.'
                END
            ELSE
                BEGIN
                    IF NOT EXISTS(SELECT 1 FROM sys.fn_my_permissions('sys.dm_os_performance_counters', 'OBJECT') WHERE permission_name = 'EXECUTE')
                        SET @Result = 'You do not have server admin or Azure active directory admin permissions.'
                END
        END
    ELSE
        BEGIN
            IF NOT EXISTS(SELECT 1 FROM sys.fn_my_permissions(NULL, 'SERVER') WHERE permission_name = 'VIEW SERVER STATE')
                SET @Result = 'You do not have VIEW SERVER STATE permissions within this instance.'
        END
    RETURN @Result
END
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Procedures_Named_SP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Procedures_Named_SP]
GO

CREATE PROCEDURE [SQLCop].[test_Procedures_Named_SP]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    SELECT  @Output = @Output + SPECIFIC_SCHEMA + '.' + SPECIFIC_NAME + Char(13) + Char(10)
    From    INFORMATION_SCHEMA.ROUTINES
    Where   SPECIFIC_NAME COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI LIKE 'sp[_]%'
            And SPECIFIC_NAME COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI NOT LIKE '%diagram%'
            AND ROUTINE_SCHEMA <> 'tSQLt'
    Order By SPECIFIC_SCHEMA,SPECIFIC_NAME

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Procedures-named-SP_'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Procedures_that_call_undocumented_procedures]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Procedures_that_call_undocumented_procedures]
GO

CREATE PROCEDURE [SQLCop].[test_Procedures_that_call_undocumented_procedures]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012
    -- Updates contributed by Claude Harvey

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    DECLARE @Temp TABLE(ProcedureName VARCHAR(50))

    INSERT INTO @Temp VALUES('sp_MStablespace')
    INSERT INTO @Temp VALUES('sp_who2')
    INSERT INTO @Temp VALUES('sp_tempdbspace')
    INSERT INTO @Temp VALUES('sp_MSkilldb')
    INSERT INTO @Temp VALUES('sp_MSindexspace')
    INSERT INTO @Temp VALUES('sp_MShelptype')
    INSERT INTO @Temp VALUES('sp_MShelpindex')
    INSERT INTO @Temp VALUES('sp_MShelpcolumns')
    INSERT INTO @Temp VALUES('sp_MSforeachtable')
    INSERT INTO @Temp VALUES('sp_MSforeachdb')
    INSERT INTO @Temp VALUES('sp_fixindex')
    INSERT INTO @Temp VALUES('sp_columns_rowset')
    INSERT INTO @Temp VALUES('sp_MScheck_uid_owns_anything')
    INSERT INTO @Temp VALUES('sp_MSgettools_path')
    INSERT INTO @Temp VALUES('sp_gettypestring')
    INSERT INTO @Temp VALUES('sp_MSdrop_object')
    INSERT INTO @Temp VALUES('sp_MSget_qualified_name')
    INSERT INTO @Temp VALUES('sp_MSgetversion')
    INSERT INTO @Temp VALUES('xp_dirtree')
    INSERT INTO @Temp VALUES('xp_subdirs')
    INSERT INTO @Temp VALUES('xp_enum_oledb_providers')
    INSERT INTO @Temp VALUES('xp_enumcodepages')
    INSERT INTO @Temp VALUES('xp_enumdsn')
    INSERT INTO @Temp VALUES('xp_enumerrorlogs')
    INSERT INTO @Temp VALUES('xp_enumgroups')
    INSERT INTO @Temp VALUES('xp_fileexist')
    INSERT INTO @Temp VALUES('xp_fixeddrives')
    INSERT INTO @Temp VALUES('xp_getnetname')
    INSERT INTO @Temp VALUES('xp_readerrorlog')
    INSERT INTO @Temp VALUES('sp_msdependencies')
    INSERT INTO @Temp VALUES('xp_qv')
    INSERT INTO @Temp VALUES('xp_delete_file')
    INSERT INTO @Temp VALUES('sp_checknames')
    INSERT INTO @Temp VALUES('sp_enumoledbdatasources')
    INSERT INTO @Temp VALUES('sp_MS_marksystemobject')
    INSERT INTO @Temp VALUES('sp_MSaddguidcolumn')
    INSERT INTO @Temp VALUES('sp_MSaddguidindex')
    INSERT INTO @Temp VALUES('sp_MSaddlogin_implicit_ntlogin')
    INSERT INTO @Temp VALUES('sp_MSadduser_implicit_ntlogin')
    INSERT INTO @Temp VALUES('sp_MSdbuseraccess')
    INSERT INTO @Temp VALUES('sp_MSdbuserpriv')
    INSERT INTO @Temp VALUES('sp_MSloginmappings')
    INSERT INTO @Temp VALUES('sp_MStablekeys')
    INSERT INTO @Temp VALUES('sp_MStablerefs')
    INSERT INTO @Temp VALUES('sp_MSuniquetempname')
    INSERT INTO @Temp VALUES('sp_MSuniqueobjectname')
    INSERT INTO @Temp VALUES('sp_MSuniquecolname')
    INSERT INTO @Temp VALUES('sp_MSuniquename')
    INSERT INTO @Temp VALUES('sp_MSunc_to_drive')
    INSERT INTO @Temp VALUES('sp_MSis_pk_col')
    INSERT INTO @Temp VALUES('xp_get_MAPI_default_profile')
    INSERT INTO @Temp VALUES('xp_get_MAPI_profiles')
    INSERT INTO @Temp VALUES('xp_regdeletekey')
    INSERT INTO @Temp VALUES('xp_regdeletevalue')
    INSERT INTO @Temp VALUES('xp_regread')
    INSERT INTO @Temp VALUES('xp_regenumvalues')
    INSERT INTO @Temp VALUES('xp_regaddmultistring')
    INSERT INTO @Temp VALUES('xp_regremovemultistring')
    INSERT INTO @Temp VALUES('xp_regwrite')
    INSERT INTO @Temp VALUES('xp_varbintohexstr')
    INSERT INTO @Temp VALUES('sp_MSguidtostr')

    SELECT @Output = @Output + SCHEMA_NAME(o.schema_id) + '.' + o.name + Char(13) + Char(10)
    FROM   sys.objects o
           INNER JOIN syscomments c
             ON o.object_id = c.id
             AND o.type = 'P'
           INNER JOIN @Temp t
             ON c.text COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI LIKE '%' + t.ProcedureName + '%'
    WHERE  type = 'P'
           AND o.is_ms_shipped = 0
           AND SCHEMA_NAME(o.schema_id) <> 'tSQLt'
           AND SCHEMA_NAME(o.schema_id) <> 'SQLCop'
    ORDER BY SCHEMA_NAME(o.schema_id), o.name

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Procedures-that-call-undocumented-procedures'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Procedures_using_dynamic_SQL_without_sp_executesql]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Procedures_using_dynamic_SQL_without_sp_executesql]
GO

CREATE PROCEDURE [SQLCop].[test_Procedures_using_dynamic_SQL_without_sp_executesql]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    SELECT  @Output = @Output + SCHEMA_NAME(so.uid) + '.' + so.name + Char(13) + Char(10)
    From    sys.sql_modules sm
            Inner Join sys.sysobjects so
                On  sm.object_id = so.id
                And so.type = 'P'
    Where   so.uid <> Schema_Id('tSQLt')
            And so.uid <> Schema_Id('SQLCop')
            And Replace(sm.definition, ' ', '') COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI Like '%Exec(%'
            And Replace(sm.definition, ' ', '') COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI Not Like '%sp_Executesql%'
            And OBJECTPROPERTY(so.id, N'IsMSShipped') = 0
    Order By SCHEMA_NAME(so.uid),so.name

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Procedures-using-dynamic-SQL-without-sp_executesql'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End

END;
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Procedures_with_Identity]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Procedures_with_Identity]
GO

CREATE PROCEDURE [SQLCop].[test_Procedures_with_Identity]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    Select  @Output = @Output + Schema_Name(schema_id) + '.' + name + Char(13) + Char(10)
    From    sys.all_objects
    Where   type = 'P'
            AND name Not In('sp_helpdiagrams','sp_upgraddiagrams','sp_creatediagram','testProcedures with @@Identity')
            And Object_Definition(object_id) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI Like '%@@identity%'
            And is_ms_shipped = 0
            and schema_id <> Schema_id('tSQLt')
            and schema_id <> Schema_id('SQLCop')
    ORDER BY Schema_Name(schema_id), name

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Procedures-with-@@Identity'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End

END;
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Procedures_With_SET_ROWCOUNT]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Procedures_With_SET_ROWCOUNT]
GO

CREATE PROCEDURE [SQLCop].[test_Procedures_With_SET_ROWCOUNT]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    SELECT  @Output = @Output + Schema_Name(schema_id) + '.' + name + Char(13) + Char(10)
    From    sys.all_objects
    Where   type = 'P'
            AND name Not In('sp_helpdiagrams','sp_upgraddiagrams','sp_creatediagram','testProcedures With SET ROWCOUNT')
            And Replace(Object_Definition(Object_id), ' ', '') COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI Like '%SETROWCOUNT%'
            And is_ms_shipped = 0
            and schema_id <> Schema_id('tSQLt')
            and schema_id <> Schema_id('SQLCop')
    ORDER BY Schema_Name(schema_id) + '.' + name

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Procedures-With-SET-ROWCOUNT'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Procedures_without_SET_NOCOUNT_ON]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Procedures_without_SET_NOCOUNT_ON]
GO

CREATE PROCEDURE [SQLCop].[test_Procedures_without_SET_NOCOUNT_ON]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    SELECT  @Output = @Output + Schema_Name(schema_id) + '.' + name + Char(13) + Char(10)
    From    sys.all_objects
    Where   Type = 'P'
            AND name Not In('sp_helpdiagrams','sp_upgraddiagrams','sp_creatediagram','testProcedures without SET NOCOUNT ON')
            And Object_Definition(Object_id) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI not Like '%SET NOCOUNT ON%'
            And is_ms_shipped = 0
            and schema_id <> Schema_id('tSQLt')
            and schema_id <> Schema_id('SQLCop')
    ORDER BY Schema_Name(schema_id) + '.' + name

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Procedures-without-set-nocount-on'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End

END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Service_Account]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Service_Account]
GO

CREATE PROCEDURE [SQLCop].[test_Service_Account]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    --Declare a variable to hold the value
    DECLARE @ServiceAccount varchar(100)

    --Retrieve the Service account from registry
    EXECUTE master.dbo.xp_instance_regread
            N'HKEY_LOCAL_MACHINE',
            N'SYSTEM\CurrentControlSet\Services\MSSQLSERVER',
            N'ObjectName',
            @ServiceAccount OUTPUT,
            N'no_output'

    --Display the Service Account
    SELECT @Output = 'Service account set to LocalSystem'
    Where  @ServiceAccount = 'LocalSystem'

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Service-Account'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End

END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Table_name_problems]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Table_name_problems]
GO

CREATE PROCEDURE [SQLCop].[test_Table_name_problems]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    DECLARE @Output VarChar(max)
    DECLARE @AcceptableSymbols VARCHAR(100)

    --SET @AcceptableSymbols = '_$'
    SET @AcceptableSymbols = '0-9_$' -- we allow numbers!
    Set @Output = ''

    SELECT  @Output = @Output + TABLE_SCHEMA + '.' + TABLE_NAME + Char(13) + Char(10)
    FROM    INFORMATION_SCHEMA.TABLES
    WHERE   TABLE_NAME COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI Like '%[^a-z' + @AcceptableSymbols + ']%'
            AND TABLE_SCHEMA <> 'tSQLt'
    ORDER BY TABLE_SCHEMA,TABLE_NAME

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Table-name-problems'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Tables_that_start_with_tbl]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Tables_that_start_with_tbl]
GO

CREATE PROCEDURE [SQLCop].[test_Tables_that_start_with_tbl]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    DECLARE @Output VarChar(max)
    Set @Output = ''

    SELECT  @Output = @Output + TABLE_SCHEMA + '.' + TABLE_NAME + Char(13) + Char(10)
    From    INFORMATION_SCHEMA.TABLES
    WHERE   TABLE_TYPE = 'BASE TABLE'
            And TABLE_NAME COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI LIKE 'tbl%'
            And TABLE_SCHEMA <> 'tSQLt'
    Order By TABLE_SCHEMA,TABLE_NAME

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Tables-that-start-with-tbl'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Tables_without_a_primary_key]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Tables_without_a_primary_key]
GO

CREATE PROCEDURE [SQLCop].[test_Tables_without_a_primary_key]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012
    -- Updates contributed by Claude Harvey

    SET NOCOUNT ON

    DECLARE @Output VarChar(max)
    Set @Output = ''

    SELECT  @Output = @Output + QUOTENAME(AllTables.schemaName) + '.' + QUOTENAME(AllTables.name) + Char(13) + Char(10)
    FROM    (
            SELECT  name, object_id, SCHEMA_NAME(schema_id) AS schemaName
            From    sys.tables
            ) AS AllTables
            LEFT JOIN (
                SELECT parent_object_id
                From sys.objects
                WHERE  type = 'PK'
                ) AS PrimaryKeys
                ON AllTables.object_id = PrimaryKeys.parent_object_id
    WHERE   PrimaryKeys.parent_object_id Is Null
            AND AllTables.schemaName <> 'tSQLt'

    ORDER BY AllTables.schemaName, AllTables.name

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Tables-without-a-primary-key'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Tables_without_any_data]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Tables_without_any_data]
GO

CREATE PROCEDURE [SQLCop].[test_Tables_without_any_data]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    DECLARE @Output VarChar(max)
    Set @Output = ''

    SELECT  @Output = @Output + QUOTENAME(SCHEMA_NAME(t.schema_id)) + '.' + QUOTENAME(t.name) + Char(13) + Char(10)
    FROM    sys.tables t JOIN sys.dm_db_partition_stats p ON t.object_id=p.object_id
    WHERE   SCHEMA_NAME(t.schema_id) <> 'tSQLt'
    AND     p.row_count = 0
    ORDER BY SCHEMA_NAME(t.schema_id), t.name

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'Empty tables in your database:'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_UniqueIdentifier_with_NewId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_UniqueIdentifier_with_NewId]
GO

CREATE PROCEDURE [SQLCop].[test_UniqueIdentifier_with_NewId]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    DECLARE @Output VarChar(max)
    Set @Output = ''

    SELECT  @Output = @Output + so.name + '.' + col.name + Char(13) + Char(10)
    FROM    sysobjects so
            INNER JOIN sysindexes sind
                ON so.id=sind.id
            INNER JOIN sysindexkeys sik
                ON sind.id=sik.id
                AND sind.indid=sik.indid
            INNER JOIN syscolumns col
                ON col.id=sik.id
                AND col.colid=sik.colid
            INNER JOIN systypes
                ON col.xtype = systypes.xtype
            INNER JOIN syscomments
                ON col.cdefault = syscomments.id
    WHERE   sind.Status & 16 = 16
            AND systypes.name = 'uniqueidentifier'
            AND keyno = 1
            AND sind.OrigFillFactor = 0
            AND syscomments.TEXT COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI Like '%newid%'
            and so.name <> 'tSQLt'
    ORDER BY so.name, sik.keyno

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Uniqueidentifier-with-NewId'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Unnamed_Constraints]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Unnamed_Constraints]
GO

CREATE PROCEDURE [SQLCop].[test_Unnamed_Constraints]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    DECLARE @Output VarChar(max)
    Set @Output = ''

    SELECT  @Output = @Output + CONSTRAINT_SCHEMA + '.' + CONSTRAINT_NAME + Char(13) + Char(10)
    From    INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
    Where   CONSTRAINT_NAME collate sql_latin1_general_CP1_CI_AI Like '%[_][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]'
            And TABLE_NAME <> 'sysdiagrams'
            And CONSTRAINT_SCHEMA <> 'tSQLt'
    Order By CONSTRAINT_SCHEMA,CONSTRAINT_NAME

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Unnamed-constraints'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End

END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_User_Aliases]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_User_Aliases]
GO

CREATE PROCEDURE [SQLCop].[test_User_Aliases]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    Select @Output = @Output + Name + Char(13) + Char(10)
    From   sysusers
    Where  IsAliased = 1
    Order By Name

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/User-aliases'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Varchar_Size_Problem]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Varchar_Size_Problem]
GO

CREATE PROCEDURE [SQLCop].[test_Varchar_Size_Problem]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    Select  @Output = @Output + ProblemItem + Char(13) + Char(10)
    From    (
            SELECT  DISTINCT su.name + '.' + so.Name As ProblemItem
            From    syscomments sc
                    Inner Join sysobjects so
                        On  sc.id = so.id
                        And so.xtype = 'P'
                    INNER JOIN sys.schemas su
                        ON so.uid = su.schema_id
            Where   REPLACE(Replace(sc.text, ' ', ''), 'varchar]','varchar') COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI Like '%varchar[^(]%'
                    And ObjectProperty(sc.Id, N'IsMSSHIPPED') = 0
                    And su.schema_id <> schema_id('tSQLt')
                    and su.schema_id <> Schema_id('SQLCop')
            ) As Problems
    Order By ProblemItem

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Varchar-size-problem'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End

END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_Wide_Table]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_Wide_Table]
GO

CREATE PROCEDURE [SQLCop].[test_Wide_Table]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    DECLARE @Output VarChar(max)
    Set @Output = ''

    Select  @Output = @Output + C.TABLE_SCHEMA + '.' + C.TABLE_NAME + Char(13) + Char(10)
    From    INFORMATION_SCHEMA.TABLES T
            INNER JOIN INFORMATION_SCHEMA.COLUMNS C
              On  T.TABLE_NAME = C.TABLE_NAME
              AND T.TABLE_SCHEMA = C.TABLE_SCHEMA
              And T.TABLE_TYPE = 'BASE TABLE'
            INNER JOIN systypes S
                On C.DATA_TYPE = S.name
    WHERE   C.TABLE_SCHEMA <> 'tSQLt'
    GROUP BY C.TABLE_SCHEMA,C.TABLE_NAME
    HAVING SUM(ISNULL(NULLIF(CONVERT(BIGINT,S.Length), 8000), 0) + ISNULL(NULLIF(C.CHARACTER_MAXIMUM_LENGTH, 2147483647), 0)) > 8060
    ORDER BY C.TABLE_SCHEMA,C.TABLE_NAME

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Wide-tables'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;

GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test_xp_cmdshell_is_enabled]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test_xp_cmdshell_is_enabled]
GO

CREATE PROCEDURE [SQLCop].[test_xp_cmdshell_is_enabled]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    select @Output = @Output + 'Warning: xp_cmdshell is enabled' + Char(13) + Char(10)
    from   sys.configurations
    where  name = 'xp_cmdshell'
           and value_in_use = 1

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/xp_cmdshell-is-enabled'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End
END;
