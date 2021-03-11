
IF NOT EXISTS(SELECT * FROM sys.schemas WHERE [name] = 'ddl')
BEGIN
	EXEC sp_executesql N'CREATE SCHEMA ddl AUTHORIZATION dbo'
END
GO

CREATE PROCEDURE ddl.ExistsColumnInTable
(
    @Schema varchar(255),
    @Table varchar(255),
    @Column varchar(255)
)
AS
BEGIN
    SET NOCOUNT ON;
   
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = @Schema AND table_name = @Table AND column_name = @Column
END
GO

-- test
exec ddl.ExistsColumnInTable 'Education', 'SchoolSport', 'SportId'
exec ddl.ExistsColumnInTable 'Education', 'SchoolSport', 'SportId1'
exec ddl.ExistsColumnInTable 'Education', 'SchoolSpor2t', 'SportId1'
exec ddl.ExistsColumnInTable 'Education1', 'SchoolSpor2t', 'SportId1'

go

-- Removing a Column from a Table
alter PROCEDURE ddl.RemoveColumnFromTable
(
    @Schema varchar(255),
    @Table varchar(255),
    @Column varchar(255)
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SQL VARCHAR(500);

    IF EXISTS(SELECT * FROM information_schema.columns
        WHERE table_schema = @Schema AND table_name = @Table AND column_name = @Column
    )
    BEGIN
        SELECT @SQL = 'ALTER TABLE ['+ @Schema +'].['+ @Table +'] DROP COLUMN ['+@Column+'];'
        EXEC sp_executesql @SQL;
        SELECT 1
    END
    ELSE
    BEGIN
        SELECT 0
    END
END
GO

exec ddl.RemoveColumnFromTable 'Education', 'SchoolSport', 'SportId'
exec ddl.RemoveColumnFromTable 'Education', 'SchoolSport', 'SportId1'
exec ddl.RemoveColumnFromTable 'Education', 'SchoolSpor2t', 'SportId1'
exec ddl.RemoveColumnFromTable 'Education1', 'SchoolSpor2t', 'SportId1'

