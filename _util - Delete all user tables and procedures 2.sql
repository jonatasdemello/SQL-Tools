/* Delete all user tables and procedures */

DECLARE mycur CURSOR FOR 
	select O.type_desc,schema_id,O.name
	from 
		sys.objects             O LEFT OUTER JOIN
		sys.extended_properties E ON O.object_id = E.major_id
	WHERE
		O.name IS NOT NULL
		AND ISNULL(O.is_ms_shipped, 0) = 0
		AND ISNULL(E.name, '') <> 'microsoft_database_tools_support'
		AND ( O.type_desc = 'SQL_STORED_PROCEDURE' OR O.type_desc = 'SQL_SCALAR_FUNCTION' )
	ORDER BY O.type_desc,O.name;

OPEN mycur;

DECLARE @schema_id int;
DECLARE @fname varchar(256);
DECLARE @sname varchar(256);
DECLARE @ftype varchar(256);

FETCH NEXT FROM mycur INTO @ftype, @schema_id, @fname;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sname = SCHEMA_NAME( @schema_id );
    IF @ftype = 'SQL_STORED_PROCEDURE'
    BEGIN
        EXEC( 'DROP PROCEDURE "' + @sname + '"."' + @fname + '"' );
        PRINT 'DROP PROCEDURE "' + @sname + '"."' + @fname + '"' ;
    END
    IF @ftype = 'SQL_SCALAR_FUNCTION'
    BEGIN
        EXEC( 'DROP FUNCTION "' + @sname + '"."' + @fname + '"' );
		PRINT 'DROP FUNCTION "' + @sname + '"."' + @fname + '"' ;
	END
	
    FETCH NEXT FROM mycur INTO @ftype, @schema_id, @fname;
END

CLOSE mycur
DEALLOCATE mycur

GO