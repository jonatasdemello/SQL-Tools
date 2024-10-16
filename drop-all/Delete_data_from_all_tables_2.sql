-- Delete data from all tables:

-- Start of Script - Find_Table_Reference_Levels.sql
/*
https://www.sqlteam.com/forums/topic.asp?TOPIC_ID=72957

The script below can be used to determine the reference levels of all tables in a database in order to be able to create a script to load tables in the correct order to prevent Foreign Key violations.

This script returns 3 result sets. The first shows the tables in order by level and table name. The second shows tables and tables that reference it in order by table and referencing table. The third shows tables and tables it references in order by table and referenced table.

Tables at level 0 have no related tables, except self-references. Tables at level 1 reference no other table, but are referenced by other tables. Tables at levels 2 and above are tables which reference lower level tables and may be referenced by higher levels. Tables with a level of NULL may indicate a circular reference (example: TableA references TableB and TableB references TableA).

Tables at levels 0 and 1 can be loaded first without FK violations, and then the tables at higher levels can be loaded in order by level from lower to higher to prevent FK violations. All tables at the same level can be loaded at the same time without FK violations.

Tested on SQL 2000 only. Please post any errors found.

Edit 2006/10/10:
Fixed bug with tables that have multiple references, and moved tables that have only self-references to level 1 from level 0.




Find Table Reference Levels

This script finds table references and ranks them by level in order
to be able to load tables with FK references in the correct order.
Tables can then be loaded one level at a time from lower to higher.
This script also shows all the relationships for each table
by tables it references and by tables that reference it.

Level 0 is tables which have no FK relationships.

Level 1 is tables which reference no other tables, except
themselves, and are only referenced by higher level tables
or themselves.

Levels 2 and above are tables which reference lower levels
and may be referenced by higher levels or themselves.

*/

declare @r table (
PK_TABLE nvarchar(200),
FK_TABLE nvarchar(200),
primary key clustered (PK_TABLE,FK_TABLE))

declare @rs table (
PK_TABLE nvarchar(200),
FK_TABLE nvarchar(200),
primary key clustered (PK_TABLE,FK_TABLE))

declare @t table (
REF_LEVEL int,
TABLE_NAME nvarchar(200) not null primary key clustered )

declare @table table (
TABLE_NAME nvarchar(200) not null primary key clustered )
set nocount off

print 'Load tables for database '+db_name()

insert into @table
select
	TABLE_NAME = a.TABLE_SCHEMA+'.'+a.TABLE_NAME
from
	INFORMATION_SCHEMA.TABLES a
where
	a.TABLE_TYPE = 'BASE TABLE'	and
	a.TABLE_SCHEMA+'.'+a.TABLE_NAME <> 'dbo.dtproperties'
order by
	1

print 'Load PK/FK references'
insert into @r
select	distinct
	PK_TABLE = 
	b.TABLE_SCHEMA+'.'+b.TABLE_NAME,
	FK_TABLE = 
	c.TABLE_SCHEMA+'.'+c.TABLE_NAME
from
	INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS a
	join
	INFORMATION_SCHEMA.TABLE_CONSTRAINTS b
	on
	a.CONSTRAINT_SCHEMA = b.CONSTRAINT_SCHEMA and
	a.UNIQUE_CONSTRAINT_NAME = b.CONSTRAINT_NAME
	join
	INFORMATION_SCHEMA.TABLE_CONSTRAINTS c
	on
	a.CONSTRAINT_SCHEMA = c.CONSTRAINT_SCHEMA and
	a.CONSTRAINT_NAME = c.CONSTRAINT_NAME
order by
	1,2

print 'Make copy of PK/FK references'
insert into @rs
select 
	*
from
	@r
order by
	1,2

print 'Load un-referenced tables as level 0'
insert into @t
select
	REF_LEVEL = 0,
	a.TABLE_NAME
from
	@table a
where
	a.TABLE_NAME not in
	(
	select PK_TABLE from @r union all 
	select FK_TABLE from @r
	)
order by
	1

-- select * from @r
print 'Remove self references'
delete from @r
where
	PK_TABLE = FK_TABLE

declare @level int
set @level = 0

while @level < 100
	begin
	set @level = @level + 1

	print 'Delete lower level references'
	delete from @r
	where
		PK_TABLE in 
		( select TABLE_NAME from @t )
		or
		FK_TABLE in 
		( select TABLE_NAME from @t )

	print 'Load level '+convert(varchar(20),@level)+' tables'

	insert into @t
	select
		REF_LEVEL =@level,
		a.TABLE_NAME
	from
		@table a
	where
		a.TABLE_NAME not in
		( select FK_TABLE from @r )
		and
		a.TABLE_NAME not in
		( select TABLE_NAME from @t )
	order by
		1

	if not exists (select * from  @r )
		begin
		print 'Done loading table levels'
		print ''
		break
		end

	end


print 'Count of Tables by level'
print ''

select
	REF_LEVEL,
	TABLE_COUNT = count(*)
from 
	@t
group by
	REF_LEVEL
order by
	REF_LEVEL

print 'Tables in order by level and table name'
print 'Note: Null REF_LEVEL nay indicate possible circular reference'
print ''
select
	b.REF_LEVEL,
	TABLE_NAME = convert(varchar(40),a.TABLE_NAME)
from 
	@table a
	left join
	@t b
	on a.TABLE_NAME = b.TABLE_NAME
order by
	b.REF_LEVEL,
	a.TABLE_NAME

print 'Tables and Referencing Tables'
print ''
select
	b.REF_LEVEL,
	TABLE_NAME = convert(varchar(40),a.TABLE_NAME),
	REFERENCING_TABLE =convert(varchar(40),c.FK_TABLE)
from 
	@table a
	left join
	@t b
	on a.TABLE_NAME = b.TABLE_NAME
	left join
	@rs c
	on a.TABLE_NAME = c.PK_TABLE
order by
	a.TABLE_NAME,
	c.FK_TABLE


print 'Tables and Tables Referenced'
print ''
select
	b.REF_LEVEL,
	TABLE_NAME = convert(varchar(40),a.TABLE_NAME),
	TABLE_REFERENCED =convert(varchar(40),c.PK_TABLE)
from 
	@table a
	left join
	@t b
	on a.TABLE_NAME = b.TABLE_NAME
	left join
	@rs c
	on a.TABLE_NAME = c.FK_TABLE
order by
	a.TABLE_NAME,
	c.PK_TABLE


-- End of Script

/*
Got this error:

Load PK/FK references
Server: Msg 2627, Level 14, State 1, Line 53
Violation of PRIMARY KEY constraint 'PK__@r__257187A8'. Cannot insert duplicate key in object '#247D636F'.
The statement has been terminated.

Adding DISTINCT to

print 'Load PK/FK references'
insert into @r
select DISTINCT
	PK_TABLE = 
	b.TABLE_SCHEMA+'.'+b.TABLE_NAME,
	FK_TABLE = 
	c.TABLE_SCHEMA+'.'+c.TABLE_NAME
from
	INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS a
	join
	INFORMATION_SCHEMA.TABLE_CONSTRAINTS b
	on
	a.CONSTRAINT_SCHEMA = b.CONSTRAINT_SCHEMA and
	a.UNIQUE_CONSTRAINT_NAME = b.CONSTRAINT_NAME
	join
	INFORMATION_SCHEMA.TABLE_CONSTRAINTS c
	on
	a.CONSTRAINT_SCHEMA = c.CONSTRAINT_SCHEMA and
	a.CONSTRAINT_NAME = c.CONSTRAINT_NAME
order by
	1,2

helped.

*/
/*
Here is a slightly different approach, which gets the database diagram as a resultset, ready to be put in any client application grid control.
Or any ASP page for that matter...

SET NOCOUNT ON

DECLARE	@Constraints TABLE
	(
		ConstraintID SMALLINT IDENTITY(0, 1),
		UNIQUE_CONSTRAINT_CATALOG NVARCHAR(128),
		UNIQUE_CONSTRAINT_SCHEMA NVARCHAR(128),
		UNIQUE_CONSTRAINT_NAME NVARCHAR(128),
		CONSTRAINT_CATALOG NVARCHAR(128),
		CONSTRAINT_SCHEMA NVARCHAR(128),
		CONSTRAINT_NAME NVARCHAR(128),
		TABLE_CATALOG NVARCHAR(128),
		TABLE_SCHEMA NVARCHAR(128),
		TABLE_NAME NVARCHAR(128),
		COLUMN_NAME NVARCHAR(128),
		DATA_TYPE NVARCHAR(128)
	)

INSERT		@Constraints
		(
			UNIQUE_CONSTRAINT_CATALOG,
			UNIQUE_CONSTRAINT_SCHEMA,
			UNIQUE_CONSTRAINT_NAME,
			CONSTRAINT_CATALOG,
			CONSTRAINT_SCHEMA,
			CONSTRAINT_NAME,
			TABLE_CATALOG,
			TABLE_SCHEMA,
			TABLE_NAME,
			COLUMN_NAME,
			DATA_TYPE
		)
SELECT		rc.UNIQUE_CONSTRAINT_CATALOG,
		rc.UNIQUE_CONSTRAINT_SCHEMA,
		rc.UNIQUE_CONSTRAINT_NAME,
		tc.CONSTRAINT_CATALOG,
		tc.CONSTRAINT_SCHEMA,
		tc.CONSTRAINT_NAME,
		kcu.TABLE_CATALOG,
		kcu.TABLE_SCHEMA,
		kcu.TABLE_NAME,
		c.COLUMN_NAME,
		c.DATA_TYPE
FROM		INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
INNER JOIN	INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON kcu.CONSTRAINT_CATALOG = tc.CONSTRAINT_CATALOG
			AND kcu.CONSTRAINT_SCHEMA = tc.CONSTRAINT_SCHEMA
			AND kcu.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
INNER JOIN	INFORMATION_SCHEMA.COLUMNS c ON c.TABLE_CATALOG = kcu.TABLE_CATALOG
			AND c.TABLE_SCHEMA = kcu.TABLE_SCHEMA
			AND c.TABLE_NAME = kcu.TABLE_NAME
			AND c.COLUMN_NAME = kcu.COLUMN_NAME
LEFT JOIN	INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc ON rc.CONSTRAINT_CATALOG = tc.CONSTRAINT_CATALOG
			AND rc.CONSTRAINT_SCHEMA = tc.CONSTRAINT_SCHEMA
			AND rc.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
WHERE		OBJECTPROPERTY(OBJECT_ID(tc.TABLE_NAME), 'IsMSShipped') = 0
		AND tc.CONSTRAINT_TYPE IN ('PRIMARY KEY', 'FOREIGN KEY')

DECLARE	@Tables TABLE
	(
		UNIQUE_CONSTRAINT_CATALOG NVARCHAR(128),
		UNIQUE_CONSTRAINT_SCHEMA NVARCHAR(128),
		UNIQUE_CONSTRAINT_NAME NVARCHAR(128),
		CONSTRAINT_CATALOG NVARCHAR(128),
		CONSTRAINT_SCHEMA NVARCHAR(128),
		CONSTRAINT_NAME NVARCHAR(128),
		TABLE_CATALOG NVARCHAR(128),
		TABLE_SCHEMA NVARCHAR(128),
		TABLE_NAME NVARCHAR(128),
		COLUMN_NAME NVARCHAR(128),
		DATA_TYPE NVARCHAR(128)
	)

INSERT		@Tables
		(
			UNIQUE_CONSTRAINT_CATALOG,
			UNIQUE_CONSTRAINT_SCHEMA,
			UNIQUE_CONSTRAINT_NAME,
			CONSTRAINT_CATALOG,
			CONSTRAINT_SCHEMA,
			CONSTRAINT_NAME,
			TABLE_CATALOG,
			TABLE_SCHEMA,
			TABLE_NAME,
			COLUMN_NAME,
			DATA_TYPE
		)
SELECT		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		TABLE_CATALOG,
		TABLE_SCHEMA,
		TABLE_NAME,
		NULL,
		NULL
FROM		INFORMATION_SCHEMA.TABLES
WHERE		OBJECTPROPERTY(OBJECT_ID(TABLE_NAME), 'IsMSShipped') = 0
		AND TABLE_TYPE = 'BASE TABLE'

DELETE		t
FROM		@Tables t
INNER JOIN	@Constraints c ON t.TABLE_CATALOG = c.TABLE_CATALOG
			AND t.TABLE_SCHEMA = c.TABLE_SCHEMA
			AND t.TABLE_NAME = c.TABLE_NAME

DECLARE	@Tree TABLE
	(
		RowID SMALLINT IDENTITY(0, 1),
		RowKey VARBINARY(5966),
		Generation SMALLINT,
		ConstraintID SMALLINT,
		CONSTRAINT_CATALOG NVARCHAR(128),
		CONSTRAINT_SCHEMA NVARCHAR(128),
		CONSTRAINT_NAME NVARCHAR(128),
		TABLE_CATALOG NVARCHAR(128),
		TABLE_SCHEMA NVARCHAR(128),
		TABLE_NAME NVARCHAR(128),
		COLUMN_NAME NVARCHAR(128),
		DATA_TYPE NVARCHAR(128)
	)

INSERT		@Tree
		(
			Generation,
			ConstraintID,
			CONSTRAINT_CATALOG,
			CONSTRAINT_SCHEMA,
			CONSTRAINT_NAME,
			TABLE_CATALOG,
			TABLE_SCHEMA,
			TABLE_NAME,
			COLUMN_NAME,
			DATA_TYPE
		)
SELECT		0,
		ConstraintID,
		CONSTRAINT_CATALOG,
		CONSTRAINT_SCHEMA,
		CONSTRAINT_NAME,
		TABLE_CATALOG,
		TABLE_SCHEMA,
		TABLE_NAME,
		COLUMN_NAME,
		DATA_TYPE
FROM		@Constraints
WHERE		UNIQUE_CONSTRAINT_CATALOG IS NULL
		AND UNIQUE_CONSTRAINT_SCHEMA IS NULL
		AND UNIQUE_CONSTRAINT_NAME IS NULL
UNION
SELECT		0,
		NULL,
		CONSTRAINT_CATALOG,
		CONSTRAINT_SCHEMA,
		CONSTRAINT_NAME,
		TABLE_CATALOG,
		TABLE_SCHEMA,
		TABLE_NAME,
		COLUMN_NAME,
		DATA_TYPE
FROM		@Tables
ORDER BY	TABLE_CATALOG,
		TABLE_SCHEMA,
		TABLE_NAME,
		COLUMN_NAME

DELETE		t
FROM		@Tree t
INNER JOIN	@Constraints c ON c.TABLE_CATALOG = t.TABLE_CATALOG
			AND c.TABLE_SCHEMA = t.TABLE_SCHEMA
			AND c.TABLE_NAME = t.TABLE_NAME
			and c.UNIQUE_CONSTRAINT_CATALOG IS NOT NULL
			AND c.UNIQUE_CONSTRAINT_SCHEMA IS NOT NULL
			AND c.UNIQUE_CONSTRAINT_NAME IS NOT NULL
INNER JOIN	@Tree x ON x.CONSTRAINT_CATALOG = c.UNIQUE_CONSTRAINT_CATALOG
			AND x.CONSTRAINT_SCHEMA = c.UNIQUE_CONSTRAINT_SCHEMA
			AND x.CONSTRAINT_NAME = c.UNIQUE_CONSTRAINT_NAME
			AND x.TABLE_CATALOG = t.TABLE_CATALOG
			AND x.TABLE_SCHEMA = t.TABLE_SCHEMA
			AND x.TABLE_NAME <> t.TABLE_NAME

DELETE		c
FROM		@Constraints c
INNER JOIN	@Tree t ON t.ConstraintID = c.ConstraintID

UPDATE	@Tree
SET	RowKey = CAST(RowID AS VARBINARY)

DECLARE	@Generation SMALLINT

SELECT	@Generation = 0

WHILE @@ROWCOUNT > 0
	BEGIN
		SELECT	@Generation = @Generation + 1		

		INSERT		@Tree
				(
					RowKey,
					Generation,
					ConstraintID,
					CONSTRAINT_CATALOG,
					CONSTRAINT_SCHEMA,
					CONSTRAINT_NAME,
					TABLE_CATALOG,
					TABLE_SCHEMA,
					TABLE_NAME,
					COLUMN_NAME,
					DATA_TYPE
				)
		SELECT		t.RowKey,
				@Generation,
				c.ConstraintID,
				c.CONSTRAINT_CATALOG,
				c.CONSTRAINT_SCHEMA,
				c.CONSTRAINT_NAME,
				c.TABLE_CATALOG,
				c.TABLE_SCHEMA,
				c.TABLE_NAME,
				c.COLUMN_NAME,
				c.DATA_TYPE
		FROM		@Constraints c
		INNER JOIN	(
					SELECT	RowKey,
						CONSTRAINT_CATALOG,
						CONSTRAINT_SCHEMA,
						CONSTRAINT_NAME
					FROM	@Tree
					WHERE	Generation = @Generation - 1
				) t ON t.CONSTRAINT_CATALOG = c.UNIQUE_CONSTRAINT_CATALOG
					AND t.CONSTRAINT_SCHEMA = c.UNIQUE_CONSTRAINT_SCHEMA
					AND t.CONSTRAINT_NAME = c.UNIQUE_CONSTRAINT_NAME
		ORDER BY	c.TABLE_CATALOG,
				c.TABLE_SCHEMA,
				c.TABLE_NAME,
				c.COLUMN_NAME

		UPDATE	@Tree
		SET	RowKey = RowKey + CAST(RowID AS VARBINARY)
		WHERE	Generation = @Generation

		UPDATE		t
		SET		t.ConstraintID = c.ConstraintID,
				t.CONSTRAINT_CATALOG = c.CONSTRAINT_CATALOG,
				t.CONSTRAINT_SCHEMA = c.CONSTRAINT_SCHEMA,
				t.CONSTRAINT_NAME = c.CONSTRAINT_NAME
		FROM		@Tree t
		INNER JOIN	@Constraints c ON c.TABLE_CATALOG = t.TABLE_CATALOG
					AND c.TABLE_SCHEMA = t.TABLE_SCHEMA
					AND c.TABLE_NAME = t.TABLE_NAME
		WHERE		t.Generation = @Generation
				AND c.UNIQUE_CONSTRAINT_CATALOG IS NULL
				AND c.UNIQUE_CONSTRAINT_SCHEMA IS NULL
				AND c.UNIQUE_CONSTRAINT_NAME IS NULL

		DELETE		c
		FROM		@Constraints c
		INNER JOIN	@Tree t ON t.ConstraintID = c.ConstraintID
	END

SELECT		Generation [Level],
		TABLE_CATALOG,
		TABLE_SCHEMA,
		TABLE_NAME,
		COLUMN_NAME,
		DATA_TYPE
FROM		@Tree
ORDER BY	RowKey
*/