USE master;
GO

IF DB_ID('IndexTestDB') IS NOT NULL
BEGIN
    ALTER DATABASE IndexTestDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE IndexTestDB;
END
GO

CREATE DATABASE IndexTestDB;
GO

USE IndexTestDB;
GO

CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) NOT NULL,
    CustomerID INT NOT NULL,
    OrderDate DATETIME NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Description NVARCHAR(100) NULL
);
GO

SET NOCOUNT ON;
DECLARE @i INT = 0;

BEGIN TRANSACTION
WHILE @i < 1000000
BEGIN
    INSERT INTO Orders (CustomerID, OrderDate, Amount, Description)
    VALUES (
        CAST(RAND() * 10000 AS INT),
        DATEADD(day, -CAST(RAND() * 365 AS INT), GETDATE()),
        CAST(RAND() * 1000 AS DECIMAL(10,2)),
        'Order description ' + CAST(@i AS NVARCHAR(10))
    );
    SET @i = @i + 1;
END
COMMIT TRANSACTION;
GO

SELECT COUNT(*) AS TotalRows FROM Orders;
GO

SET STATISTICS IO ON;
GO

PRINT '=== ЗАПРОС 1: ДО ИНДЕКСА ===';
SELECT * FROM Orders WHERE CustomerID = 5000;
GO

CREATE CLUSTERED INDEX IX_Orders_CustomerID
ON Orders (CustomerID);
GO

PRINT '=== ЗАПРОС 2: ПОСЛЕ ИНДЕКСА ===';
SELECT * FROM Orders WHERE CustomerID = 5000;
GO

SET STATISTICS IO OFF;
GO