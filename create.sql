-- Sprawdzanie, czy schematy ju¿ istniej¹ i usuwanie ich w razie potrzeby
DECLARE @SchemaCounter INT = 1;
DECLARE @SchemaName NVARCHAR(50);
WHILE @SchemaCounter <= 10
BEGIN
    SET @SchemaName = 'Tenant' + CAST(@SchemaCounter AS NVARCHAR(10));
    IF EXISTS (SELECT * FROM sys.schemas WHERE name = @SchemaName)
    BEGIN
        EXEC('DROP SCHEMA ' + @SchemaName);
    END
    SET @SchemaCounter = @SchemaCounter + 1;
END

-- Tworzenie 10 schematów
SET @SchemaCounter = 1;
WHILE @SchemaCounter <= 10
BEGIN
    SET @SchemaName = 'Tenant' + CAST(@SchemaCounter AS NVARCHAR(10));
    EXEC('CREATE SCHEMA ' + @SchemaName);
    SET @SchemaCounter = @SchemaCounter + 1;
END

-- Tworzenie tabel w ka¿dym schemacie
SET @SchemaCounter = 1;
WHILE @SchemaCounter <= 10
BEGIN
    SET @SchemaName = 'Tenant' + CAST(@SchemaCounter AS NVARCHAR(10));
    EXEC('     	
		create table '+ @SchemaName +'.Users (
		    UserID int identity(1,1) primary key,
		    Username nvarchar(255) not null,
		    PasswordHash varbinary(MAX) not null,
		    RoleType nvarchar(50) check (RoleType in (''Basic'', ''Manager'')) not null,
		    ManagerID int null,
		    foreign key (ManagerID) references '+ @SchemaName +'.Users(UserID)
		);
    ');
	EXEC('
		create table '+ @SchemaName +'.Tasks (
		    TaskID int identity(1,1) primary key,
		    OwnerID int not null,
		    Title nvarchar(255) not null,
		    PriorityTag nvarchar(50) check (PriorityTag in (''Low'', ''High'', ''Medium'')) not null,
		    Description nvarchar(MAX) not null,
		    Status nvarchar(50) check (Status in (''Completed'', ''In Progress'', ''Pending'')) not null,
		    CreatedDate datetime not null,
		    ModifiedDate datetime not null,
		    foreign key (OwnerID) references '+ @SchemaName +'.Users(UserID)
		);'
	);
	EXEC('
		create table '+ @SchemaName +'.TaskHistory (
		    HistoryID int identity(1,1) primary key,
		    TaskID int not null,
		    ChangedByID int not null,
		    ChangeDate datetime not null,
		    OldTitle nvarchar(255),
		    NewTitle nvarchar(255),
		    OldPriorityTag nvarchar(50),
		    NewPriorityTag nvarchar(50) check (NewPriorityTag in (''Low'', ''High'', ''Medium'')),
		    OldDescription nvarchar(MAX),
		    NewDescription nvarchar(MAX),
		    OldStatus nvarchar(50),
		    NewStatus nvarchar(50) check (NewStatus in (''Completed'', ''In Progress'', ''Pending'')),
		    foreign key (TaskID) references '+ @SchemaName +'.Tasks(TaskID),
		    foreign key (ChangedByID) references '+ @SchemaName +'.Users(UserID)
		);'
	);
	EXEC('create index idx_tasks_ownerid on '+ @SchemaName +'.Tasks(OwnerID);');
	EXEC('create index idx_taskhistory_taskid_changedate on '+ @SchemaName +'.TaskHistory(TaskID, ChangeDate);');
    SET @SchemaCounter = @SchemaCounter + 1;
END