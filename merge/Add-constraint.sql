CREATE TABLE School.CommonAppSchool
(
	MemberId INT NOT NULL,
	CollegeName NVARCHAR(300),

	IsActive BIT CONSTRAINT DF_School_CommonAppSchool_IsActive DEFAULT 1,
	ModifiedDateUTC DATETIME2,

	PRIMARY KEY CLUSTERED (MemberId ASC)
);

ALTER TABLE School.CommonAppSchool
	ADD CONSTRAINT DF_School_CommonAppSchool_IsActive DEFAULT 1 FOR IsActive;
	