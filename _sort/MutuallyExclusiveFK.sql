ALTER TABLE Entity3
    ADD CONSTRAINT ck_MutuallyExclusiveFK 
    CHECK (FK1 IS NULL OR FK2 IS NULL)
GO

If you want to make sure at least one of the columns is not null, you can do this:

ALTER TABLE Entity3
    ADD CONSTRAINT ck_MutuallyExclusiveFK 
    CHECK ((FK1 IS NULL OR FK2 IS NULL) AND (FK1 IS NOT NULL OR FK2 IS NOT NULL))
GO
