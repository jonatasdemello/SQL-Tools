-- Cursor
use cc3_dev;
set nocount on;

declare @EducatorId INT = 2
declare @AssignmentId INT

DECLARE cursor_name CURSOR 
    FOR select top 100 AssignmentId from School.Assignment where InstitutionId = 44500;

Open cursor_name;

FETCH NEXT FROM cursor_name into @AssignmentId

WHILE @@FETCH_STATUS = 0  
    BEGIN
        exec School.GroupGetByInstitutionId_AllPublic @AssignmentId, @EducatorId, 1, 1

        FETCH NEXT FROM cursor_name into @AssignmentId;
    END;

CLOSE cursor_name;
DEALLOCATE cursor_name;
