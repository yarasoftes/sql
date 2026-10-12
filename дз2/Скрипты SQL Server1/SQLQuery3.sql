USE master;
GO

IF DB_ID('IndexesDB') IS NOT NULL
BEGIN
    ALTER DATABASE IndexesDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE IndexesDB;
END
GO

CREATE DATABASE IndexesDB
ON PRIMARY (
    NAME = 'IndexesDB_Data',
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\IndexesDB.mdf',
    SIZE = 20MB,
    MAXSIZE = 500MB,
    FILEGROWTH = 10MB
)
LOG ON (
    NAME = 'IndexesDB_Log',
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\IndexesDB_log.ldf',
    SIZE = 10MB,
    MAXSIZE = 200MB,
    FILEGROWTH = 10MB
);
GO

USE IndexesDB;
GO

ALTER DATABASE IndexesDB ADD FILEGROUP FG_Slow;
ALTER DATABASE IndexesDB ADD FILEGROUP FG_Fast;
GO

ALTER DATABASE IndexesDB ADD FILE (
    NAME = 'IndexesDB_Slow',
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\IndexesDB_Slow.ndf',
    SIZE = 10MB,
    MAXSIZE = 200MB,
    FILEGROWTH = 5MB
) TO FILEGROUP FG_Slow;
GO

ALTER DATABASE IndexesDB ADD FILE (
    NAME = 'IndexesDB_Fast',
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\IndexesDB_Fast.ndf',
    SIZE = 10MB,
    MAXSIZE = 200MB,
    FILEGROWTH = 5MB
) TO FILEGROUP FG_Fast;
GO

CREATE TABLE SlowLogs (
    LogID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Message NVARCHAR(500) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
) ON FG_Slow;
GO

CREATE TABLE FastProducts (
    ProductID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Category NVARCHAR(50) NOT NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
) ON FG_Fast;
GO

SET NOCOUNT ON;
DECLARE @i INT = 0;

BEGIN TRANSACTION
WHILE @i < 10000
BEGIN
    INSERT INTO SlowLogs (Message)
    VALUES ('Log message #' + CAST(@i AS NVARCHAR(10)));

    INSERT INTO FastProducts (Name, Category, Price, IsActive)
    VALUES (
        'Product ' + CAST(@i AS NVARCHAR(10)),
        CASE @i % 4
            WHEN 0 THEN 'Electronics'
            WHEN 1 THEN 'Books'
            WHEN 2 THEN 'Clothes'
            ELSE 'Food'
        END,
        CAST(RAND() * 1000 AS DECIMAL(10,2)),
        CASE WHEN @i % 2 = 0 THEN 1 ELSE 0 END
    );

    SET @i = @i + 1;
END
COMMIT TRANSACTION;
GO

CREATE CLUSTERED INDEX IX_FastProducts_ProductID
ON FastProducts (ProductID)
ON FG_Fast;
GO

CREATE NONCLUSTERED INDEX IX_FastProducts_Category
ON FastProducts (Category)
ON FG_Fast;
GO

CREATE NONCLUSTERED INDEX IX_FastProducts_Name_Price
ON FastProducts (Name, Price)
ON FG_Fast;
GO

CREATE NONCLUSTERED INDEX IX_FastProducts_Active_Filtered
ON FastProducts (Name)
WHERE IsActive = 1
ON FG_Fast;
GO

CREATE NONCLUSTERED COLUMNSTORE INDEX IX_FastProducts_Columnstore
ON FastProducts (Name, Category, Price)
ON FG_Fast;
GO

SELECT name AS IndexName, type_desc, is_unique
FROM sys.indexes
WHERE object_id = OBJECT_ID('dbo.FastProducts');
GO

SELECT * FROM FastProducts WHERE Category = 'Electronics';
GO

SELECT * FROM FastProducts WHERE IsActive = 1;
GO

SELECT Category, COUNT(*) AS Cnt, AVG(Price) AS AvgPrice
FROM FastProducts
GROUP BY Category;
GO

SELECT name AS FileGroupName FROM sys.filegroups;
GO

SELECT name AS FileName, physical_name, size
FROM sys.database_files;
GO

SELECT t.name AS TableName, fg.name AS FileGroupName
FROM sys.tables t
JOIN sys.indexes i ON t.object_id = i.object_id
JOIN sys.filegroups fg ON i.data_space_id = fg.data_space_id
WHERE i.index_id <= 1;
GO