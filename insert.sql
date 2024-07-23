-- Przed uruchomieniem należy umieścić nazwę bazy docelowej w klauzuli USE
use [-]
-- Wstawianie danych testowych do tabeli Users
declare @UserCounter int = 0;
declare @MenagerID int = 0;
declare @TenantID int = 1;
declare @SchemaName nvarchar(50);
declare @SchemaCounter int = 1;
while @SchemaCounter <= 10
begin
	set @SchemaName = 'Tenant' + CAST(@SchemaCounter AS NVARCHAR(10));
    while @UserCounter < 100
    begin
        exec('
		insert into '+ @SchemaName +'.Users ( Username, PasswordHash, RoleType, ManagerID)
        values (''User'' + cast('+ @UserCounter + ' as nvarchar(10)),
                hashbytes(''SHA2_256'', ''password''), case when ' + @UserCounter + ' % 10 = 0 then ''Manager'' else ''Basic'' end,
				case when ' + @UserCounter +' % 10 = 0 then null else ' + @MenagerID + ' end);
		');
		if @UserCounter % 10 = 0 set @MenagerID = @UserCounter + 1;
        set @UserCounter = @UserCounter + 1;
    end
    set @UserCounter = 0;
	set @SchemaCounter = @SchemaCounter + 1;
end

-- Wstawianie danych testowych do tabeli Tasks
declare @TaskCounter int = 1;
declare @UserID int = 1;

set @SchemaCounter = 1;
while @SchemaCounter <= 10
begin
	set @SchemaName = 'Tenant' + CAST(@SchemaCounter AS NVARCHAR(10));
	while @UserID <= 100
	begin
	    while @TaskCounter <= 1000
	    begin
	        exec('
			insert into '+ @SchemaName +'.Tasks (OwnerID, Title, PriorityTag, Description, Status, CreatedDate, ModifiedDate)
	        values (
	            '+ @UserID +',
	            ''Task Title '' + cast('+ @TaskCounter +' as nvarchar(10)),
	            case when '+ @TaskCounter +' % 5 = 0 then ''High'' when '+ @TaskCounter +' % 5 = 1 then ''Medium'' else ''Low'' end,
	            ''Task Description '' + cast('+ @TaskCounter +' as nvarchar(10)),
	            case when '+ @TaskCounter +' % 4 = 0 then ''Completed'' when '+ @TaskCounter +' % 4 = 1 then ''In Progress'' else ''Pending'' end,
	            dateadd(DAY, -'+ @TaskCounter +', getdate()),
	            dateadd(DAY, -'+ @TaskCounter +', getdate())
	        );'
			);
	
	        set @TaskCounter = @TaskCounter + 1;
	    end
	    set @TaskCounter = 1;  
	    set @UserID = @UserID + 1;
	end
	set @UserID = 1;
	set @SchemaCounter = @SchemaCounter + 1;
end
