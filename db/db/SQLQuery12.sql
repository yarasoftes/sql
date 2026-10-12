USE ShopDB;
GO

IF OBJECT_ID('dbo.Person_User', 'U') IS NOT NULL DROP TABLE dbo.Person_User;
IF OBJECT_ID('dbo.Person_Address', 'U') IS NOT NULL DROP TABLE dbo.Person_Address;
IF OBJECT_ID('dbo.Production_Category', 'U') IS NOT NULL DROP TABLE dbo.Production_Category;
IF OBJECT_ID('dbo.Production_Product', 'U') IS NOT NULL DROP TABLE dbo.Production_Product;
IF OBJECT_ID('dbo.Sales_OrderHeader', 'U') IS NOT NULL DROP TABLE dbo.Sales_OrderHeader;
IF OBJECT_ID('dbo.Sales_OrderDetail', 'U') IS NOT NULL DROP TABLE dbo.Sales_OrderDetail;
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