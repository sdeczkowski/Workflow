-- Dodawanie zadania
CREATE PROCEDURE AddTask
    @TenantID NVARCHAR(50),
    @OwnerID NVARCHAR(50),
    @Title NVARCHAR(255),
    @Priority NVARCHAR(50),
    @Description NVARCHAR(MAX),
    @Status NVARCHAR(50)
AS
BEGIN
    DECLARE @CreatedDate DATETIME = GETDATE();
    EXEC('
		INSERT INTO Tenant'+@TenantID+'.Tasks (OwnerID, Title, PriorityTag, Description, Status, CreatedDate, ModifiedDate)
		VALUES ('+@OwnerID+', '''+@Title+''', '''+@Priority+''', '''+@Description+''', '''+@Status+''', '''+@CreatedDate+''', '''+@CreatedDate+''');'
	);
END

GO

-- Edytowanie zadania
CREATE PROCEDURE EditTask
	@TenantID NVARCHAR(50),
    @TaskID INT,
    @ChangedByID INT,
    @NewTitle NVARCHAR(255),
    @NewPriority NVARCHAR(50),
    @NewDescription NVARCHAR(MAX),
    @NewStatus NVARCHAR(50)
AS
BEGIN
    DECLARE @OldTitle NVARCHAR(255), @OldPriority NVARCHAR(50), @OldDescription NVARCHAR(MAX), @OldStatus NVARCHAR(50), @ModifiedDate DATETIME = GETDATE();

	DECLARE @OldTempTable TABLE (
	    Title NVARCHAR(255),
	    PriorityTag NVARCHAR(50),
		Description NVARCHAR(MAX),
		Status NVARCHAR(50)
	);

	DECLARE @SQL NVARCHAR(MAX);
	SET @SQL = N'SELECT Title, PriorityTag, Description, Status FROM Tenant'+@TenantID+'.Tasks WHERE TaskID = @TaskID';
	
	DECLARE @ParamDef NVARCHAR(MAX);
	SET @ParamDef = N'@TaskID INT';
	
	INSERT INTO @OldTempTable
	EXEC sp_executesql @SQL, @ParamDef, @TaskID;
	

    SELECT @OldTitle = Title, @OldPriority = PriorityTag, @OldDescription = Description, @OldStatus = Status
    FROM @OldTempTable;
    
    EXEC('
	UPDATE Tenant'+@TenantID+'.Tasks
    SET Title = '''+@NewTitle+''', PriorityTag = '''+@NewPriority+''', Description = '''+@NewDescription+''', Status = '''+@NewStatus+''', ModifiedDate = '''+@ModifiedDate+'''
    WHERE TaskID = '+@TaskID+'
	');
    
    EXEC('
	INSERT INTO Tenant'+@TenantID+'.TaskHistory (TaskID, ChangedByID, ChangeDate, OldTitle, NewTitle, OldPriorityTag, NewPriorityTag, OldDescription, NewDescription, OldStatus, NewStatus)
    VALUES ('''+@TaskID+''', '''+@ChangedByID+''', '''+@ModifiedDate+''', '''+@OldTitle+''', '''+@NewTitle+''', '''+@OldPriority+''', '''+@NewPriority+''',
	'''+@OldDescription+''', '''+@NewDescription+''', '''+@OldStatus+''', '''+@NewStatus+''')
	');
END

GO

-- Usuwanie zadania
CREATE PROCEDURE DeleteTask
	@TenantID NVARCHAR(50),
    @TaskID INT
AS
BEGIN
    EXEC('DELETE FROM Tenant'+@TenantID+'.Tasks WHERE TaskID = '+@TaskID);
    EXEC('DELETE FROM Tenant'+@TenantID+'.TaskHistory WHERE TaskID = '+@TaskID);
END

GO

-- Podgl¹d zadañ u¿ytkownika
CREATE PROCEDURE GetUserTasks
	@TenantID NVARCHAR(50),
    @UserID INT
AS
BEGIN
    EXEC('SELECT * FROM Tenant'+@TenantID+'.Tasks WHERE OwnerID = '+@UserID);
END

GO

-- Podgl¹d zadañ podw³adnych (dla menad¿erów)
CREATE PROCEDURE GetSubordinateTasks
	@TenantID NVARCHAR(50),
    @ManagerID INT
AS
BEGIN
    EXEC('SELECT * FROM Tenant'+@TenantID+'.Tasks WHERE OwnerID IN (SELECT UserID FROM Tenant'+@TenantID+'.Users WHERE ManagerID = '+@ManagerID+')');
END

GO

-- Podgl¹d historii zmian zadania
CREATE PROCEDURE GetTaskHistory
	@TenantID NVARCHAR(50),
    @TaskID INT
AS
BEGIN
    EXEC('SELECT * FROM Tenant'+@TenantID+'.TaskHistory WHERE TaskID = '+@TaskID+' ORDER BY ChangeDate');
END

GO

-- Statystyki zadañ z podzia³em na miesi¹ce
CREATE PROCEDURE GetTaskStatistics
	@TenantID NVARCHAR(50),
    @ManagerID INT
AS
BEGIN
    EXEC('
		SELECT 
		    u.UserID,
		    u.Username,
		    YEAR(t.CreatedDate) AS Year,
		    MONTH(t.CreatedDate) AS Month,
		    t.Status,
		    COUNT(*) AS TaskCount
		FROM Tenant'+@TenantID+'.Tasks t
		JOIN Users u ON t.OwnerID = u.UserID
		WHERE u.ManagerID = '+@ManagerID+'
		GROUP BY u.UserID, u.Username, YEAR(t.CreatedDate), MONTH(t.CreatedDate), t.Status
		ORDER BY u.UserID, Year, Month, t.Status
	');
END

