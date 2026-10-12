RESTORE DATABASE AdventureWorks2019
FROM DISK = 'C:\Backups\AdventureWorks2019.bak'
WITH MOVE 'AdventureWorks2019' 
        TO 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\AdventureWorks2019.mdf',
     MOVE 'AdventureWorks2019_log' 
        TO 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\AdventureWorks2019_log.ldf',
     REPLACE;
GO

SELECT name FROM sys.databases WHERE name = 'AdventureWorks2019';
GO

USE master;
GO

IF DB_ID('ShopDB') IS NOT NULL
BEGIN
    ALTER DATABASE ShopDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ShopDB;
END
GO

CREATE DATABASE ShopDB
ON PRIMARY (
    NAME = 'ShopDB_Data',
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\ShopDB.mdf',
    SIZE = 20MB, MAXSIZE = 500MB, FILEGROWTH = 10MB
)
LOG ON (
    NAME = 'ShopDB_Log',
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\ShopDB_log.ldf',
    SIZE = 10MB, MAXSIZE = 200MB, FILEGROWTH = 10MB
);
GO

USE ShopDB;
GO

ALTER DATABASE ShopDB ADD FILEGROUP FG_Users;
ALTER DATABASE ShopDB ADD FILEGROUP FG_Sales;
ALTER DATABASE ShopDB ADD FILEGROUP FG_Products;
GO

ALTER DATABASE ShopDB ADD FILE (
    NAME = 'ShopDB_Users',
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\ShopDB_Users.ndf',
    SIZE = 10MB, MAXSIZE = 200MB, FILEGROWTH = 5MB
) TO FILEGROUP FG_Users;
GO

ALTER DATABASE ShopDB ADD FILE (
    NAME = 'ShopDB_Sales',
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\ShopDB_Sales.ndf',
    SIZE = 10MB, MAXSIZE = 200MB, FILEGROWTH = 5MB
) TO FILEGROUP FG_Sales;
GO

ALTER DATABASE ShopDB ADD FILE (
    NAME = 'ShopDB_Products',
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\ShopDB_Products.ndf',
    SIZE = 10MB, MAXSIZE = 200MB, FILEGROWTH = 5MB
) TO FILEGROUP FG_Products;
GO

CREATE TABLE Person_User (
    BusinessEntityID INT NOT NULL PRIMARY KEY,
    PersonType NCHAR(2) NOT NULL,
    Title NVARCHAR(8) NULL,
    FirstName NVARCHAR(50) NOT NULL,
    MiddleName NVARCHAR(50) NULL,
    LastName NVARCHAR(50) NOT NULL,
    Suffix NVARCHAR(10) NULL,
    EmailPromotion INT NOT NULL DEFAULT 0,
    ModifiedDate DATETIME NOT NULL DEFAULT GETDATE()
) ON FG_Users;
GO

CREATE TABLE Person_Address (
    AddressID INT NOT NULL PRIMARY KEY,
    AddressLine1 NVARCHAR(60) NOT NULL,
    AddressLine2 NVARCHAR(60) NULL,
    City NVARCHAR(30) NOT NULL,
    StateProvinceID INT NOT NULL,
    PostalCode NVARCHAR(15) NOT NULL,
    ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive BIT NOT NULL DEFAULT 1
) ON FG_Users;
GO

CREATE TABLE Production_Category (
    ProductCategoryID INT NOT NULL PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    ParentCategoryID INT NULL,
    Rowguid UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive BIT NOT NULL DEFAULT 1,
    SortOrder INT NOT NULL DEFAULT 0
) ON FG_Products;
GO

CREATE TABLE Production_Product (
    ProductID INT NOT NULL PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    ProductNumber NVARCHAR(25) NOT NULL,
    MakeFlag BIT NOT NULL DEFAULT 0,
    FinishedGoodsFlag BIT NOT NULL DEFAULT 0,
    Color NVARCHAR(15) NULL,
    StandardCost MONEY NOT NULL,
    ListPrice MONEY NOT NULL,
    ModifiedDate DATETIME NOT NULL DEFAULT GETDATE()
) ON FG_Products;
GO

CREATE TABLE Sales_OrderHeader (
    SalesOrderID INT NOT NULL PRIMARY KEY,
    RevisionNumber TINYINT NOT NULL,
    OrderDate DATETIME NOT NULL,
    DueDate DATETIME NOT NULL,
    ShipDate DATETIME NULL,
    Status TINYINT NOT NULL,
    OnlineOrderFlag BIT NOT NULL,
    CustomerID INT NOT NULL,
    SubTotal MONEY NOT NULL,
    TotalDue MONEY NOT NULL,
    ModifiedDate DATETIME NOT NULL DEFAULT GETDATE()
) ON FG_Sales;
GO

CREATE TABLE Sales_OrderDetail (
    SalesOrderID INT NOT NULL,
    SalesOrderDetailID INT NOT NULL,
    CarrierTrackingNumber NVARCHAR(25) NULL,
    OrderQty SMALLINT NOT NULL,
    ProductID INT NOT NULL,
    SpecialOfferID INT NOT NULL,
    UnitPrice MONEY NOT NULL,
    UnitPriceDiscount MONEY NOT NULL DEFAULT 0,
    ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (SalesOrderID, SalesOrderDetailID)
) ON FG_Sales;
GO

INSERT INTO Person_User
SELECT BusinessEntityID, PersonType, Title, FirstName, MiddleName, LastName, Suffix, EmailPromotion, ModifiedDate
FROM AdventureWorks2019.Person.Person;
GO

INSERT INTO Person_Address
SELECT AddressID, AddressLine1, AddressLine2, City, StateProvinceID, PostalCode, ModifiedDate, 1
FROM AdventureWorks2019.Person.Address;
GO

INSERT INTO Production_Category
SELECT ProductCategoryID, Name, NULL, rowguid, ModifiedDate, 1, 0
FROM AdventureWorks2019.Production.ProductCategory;
GO

INSERT INTO Production_Product
SELECT ProductID, Name, ProductNumber, MakeFlag, FinishedGoodsFlag, Color, StandardCost, ListPrice, ModifiedDate
FROM AdventureWorks2019.Production.Product;
GO

INSERT INTO Sales_OrderHeader
SELECT SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag,
       CustomerID, SubTotal, TotalDue, ModifiedDate
FROM AdventureWorks2019.Sales.SalesOrderHeader;
GO

INSERT INTO Sales_OrderDetail
SELECT SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID,
       SpecialOfferID, UnitPrice, UnitPriceDiscount, ModifiedDate
FROM AdventureWorks2019.Sales.SalesOrderDetail;
GO

SELECT t.name AS TableName, fg.name AS FileGroupName, p.rows AS RowCount
FROM sys.tables t
JOIN sys.indexes i ON t.object_id = i.object_id
JOIN sys.filegroups fg ON i.data_space_id = fg.data_space_id
JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
WHERE i.index_id <= 1
ORDER BY fg.name, t.name;
GO

SELECT 'Person_User' AS TableName, COUNT(*) AS Rows FROM Person_User
UNION ALL SELECT 'Person_Address', COUNT(*) FROM Person_Address
UNION ALL SELECT 'Production_Category', COUNT(*) FROM Production_Category
UNION ALL SELECT 'Production_Product', COUNT(*) FROM Production_Product
UNION ALL SELECT 'Sales_OrderHeader', COUNT(*) FROM Sales_OrderHeader
UNION ALL SELECT 'Sales_OrderDetail', COUNT(*) FROM Sales_OrderDetail;
GO