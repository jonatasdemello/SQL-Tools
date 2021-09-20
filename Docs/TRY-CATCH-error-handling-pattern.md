# TRY CATCH error handling pattern

Example Pattern:

```
BEGIN TRY
    BEGIN TRANSACTION

    -- Do Work

    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW; -- Rethrow Exception
END CATCH 
```

See CoursePlanner.DiplomaClone for a real example. 