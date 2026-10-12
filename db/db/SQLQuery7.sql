USE ShopDB;
GO

IF OBJECT_ID('dbo.Person_User', 'U') IS NOT NULL DROP TABLE dbo.Person_User;
IF OBJECT_ID('dbo.Person_Address', 'U') IS NOT NULL DROP TABLE dbo.Person_Address;
IF OBJECT_ID('dbo.Production_Product', 'U') IS NOT NULL DROP TABLE dbo.Production_Product;
IF OBJECT_ID('dbo.Production_Category', 'U') IS NOT NULL DROP TABLE dbo.Production_Category;
IF OBJECT_ID('dbo.Sales_OrderHeader', 'U') IS NOT NULL DROP TABLE dbo.Sales_OrderHeader;
IF OBJECT_ID('dbo.Sales_OrderDetail', 'U') IS NOT NULL DROP TABLE dbo.Sales_OrderDetail;
GO

-- 1. Пользователи (из Person.Person)
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

INSERT INTO Person_User
SELECT BusinessEntityID, PersonType, Title, FirstName, MiddleName, LastName, Suffix, EmailPromotion, ModifiedDate
FROM AdventureWorks2019.Person.Person;
GO

-- 2. Адреса (из Person.Address)
CREATE TABLE Person_Address (
    AddressID INT NOT NULL PRIMARY KEY,
    AddressLine1 NVARCHAR(60) NOT NULL,
    AddressLine2 NVARCHAR(60) NULL,
    City NVARCHAR(30) NOT NULL,
    StateProvinceID INT NOT NULL,
    PostalCode NVARCHAR(15) NOT NULL,
    SpatialLocation NVARCHAR(100) NULL,
    ModifiedDate DATETIME NOT NULL DEFAULT GETDATE()
) ON FG_Users;
GO

INSERT INTO Person_Address
SELECT AddressID, AddressLine1, AddressLine2, City, StateProvinceID, PostalCode,
       CAST(SpatialLocation AS NVARCHAR(100)), ModifiedDate
FROM AdventureWorks2019.Person.Address;
GO

-- 3. Категории продуктов (из Production.ProductCategory)
CREATE TABLE Production_Category (
    ProductCategoryID INT NOT NULL PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    ParentCategoryID INT NULL,
    Rowguid UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    ModifiedDate DATETIME NOT NULL DEFAULT GETDATE()
) ON FG_Products;
GO

INSERT INTO Production_Category
SELECT ProductCategoryID, Name, NULL, rowguid, ModifiedDate
FROM AdventureWorks2019.Production.ProductCategory;
GO

-- 4. Продукты (из Production.Product)
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

INSERT INTO Production_Product
SELECT ProductID, Name, ProductNumber, MakeFlag, FinishedGoodsFlag, Color, StandardCost, ListPrice, ModifiedDate
FROM AdventureWorks2019.Production.Product;
GO

-- 5. Заголовки заказов (из Sales.SalesOrderHeader)
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

INSERT INTO Sales_OrderHeader
SELECT SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, CustomerID, SubTotal, TotalDue, ModifiedDate
FROM AdventureWorks2019.Sales.SalesOrderHeader;
GO

-- 6. Детали заказов (из Sales.SalesOrderDetail)
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

INSERT INTO Sales_OrderDetail
SELECT SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, ModifiedDate
FROM AdventureWorks2019.Sales.SalesOrderDetail;
GO