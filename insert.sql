SELECT 
        u.UserID,
        u.Username,
        YEAR(t.CreatedDate) AS Year,
        MONTH(t.CreatedDate) AS Month,
        t.Status,
        COUNT(*) AS TaskCount
    FROM Tasks t
    JOIN Users u ON t.OwnerID = u.UserID
    WHERE u.ManagerID = 11
    GROUP BY u.UserID, u.Username, YEAR(t.CreatedDate), MONTH(t.CreatedDate), t.Status
    ORDER BY u.UserID, Year, Month, t.Status;