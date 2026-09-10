USE Bayraktar;
GO

DROP TABLE IF EXISTS Persons.Items;
DROP TABLE IF EXISTS Persons.Categories;
DROP TABLE IF EXISTS Persons.Employees;
DROP TABLE IF EXISTS Persons.Customers;
DROP TABLE IF EXISTS Products.Items;
DROP TABLE IF EXISTS Products.Categories;
GO

DROP SCHEMA IF EXISTS Persons;
DROP SCHEMA IF EXISTS Products;
GO

CREATE SCHEMA Persons;
GO

CREATE SCHEMA Products;
GO

CREATE TABLE Persons.Employees (
    id          INT NULL,
    FirstName   NVARCHAR(50)  NULL,
    LastName    NVARCHAR(50)  NULL,
    Email       NVARCHAR(100) NULL,
    BirthDate   DATE          NULL
);
GO

CREATE TABLE Persons.Customers (
    id               INT NULL,
    FullName         NVARCHAR(100) NULL,
    Phone            NVARCHAR(20)  NULL,
    City             NVARCHAR(50)  NULL,
    RegistrationDate DATE          NULL
);
GO

DROP TABLE IF EXISTS Persons.Employees;
DROP TABLE IF EXISTS Persons.Customers;
GO

CREATE TABLE Persons.Employees (
    id          INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    FirstName   NVARCHAR(50)  NULL,
    LastName    NVARCHAR(50)  NULL,
    Email       NVARCHAR(100) NULL,
    BirthDate   DATE          NULL
);
GO

CREATE TABLE Persons.Customers (
    id               INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    FullName         NVARCHAR(100) NULL,
    Phone            NVARCHAR(20)  NULL,
    City             NVARCHAR(50)  NULL,
    RegistrationDate DATE          NULL
);
GO

CREATE TABLE Products.Categories (
    id            INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    CategoryName  NVARCHAR(50)  NOT NULL,
    Description   NVARCHAR(200) NULL,
    IsActive      BIT           DEFAULT 1,
    SortOrder     INT           DEFAULT 0
);
GO

CREATE TABLE Products.Items (
    id            INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    ProductName   NVARCHAR(100) NOT NULL,
    Price         DECIMAL(10,2) NULL,
    Quantity      INT           DEFAULT 0,
    Category      NVARCHAR(50)  NULL
);
GO

INSERT INTO Products.Categories (CategoryName, Description)
VALUES (N'Электроника', N'Гаджеты и техника');
GO

INSERT INTO Products.Items (ProductName, Price, Quantity, Category)
VALUES (N'Смартфон', 29999.00, 15, N'Электроника');
GO

INSERT INTO Persons.Employees (FirstName, LastName, Email, BirthDate)
VALUES (N'Иван', N'Иванов', N'ivan@mail.ru', '1990-05-12');
GO

INSERT INTO Persons.Customers (FullName, Phone, City, RegistrationDate)
VALUES (N'Пётр Петров', N'+79001234567', N'Москва', '2024-01-15');
GO

ALTER SCHEMA Persons TRANSFER Products.Categories;
GO

ALTER SCHEMA Persons TRANSFER Products.Items;
GO

SELECT name AS [Схема]
FROM sys.schemas
WHERE name IN ('Persons', 'Products')
ORDER BY name;
GO

SELECT 
    TABLE_SCHEMA AS [Схема],
    TABLE_NAME   AS [Таблица]
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA IN ('Persons', 'Products')
ORDER BY TABLE_SCHEMA, TABLE_NAME;
GO

SELECT 
    TABLE_SCHEMA AS [Схема],
    TABLE_NAME   AS [Таблица],
    COLUMN_NAME  AS [Столбец],
    IS_NULLABLE  AS [Nullable],
    COLUMNPROPERTY(OBJECT_ID(TABLE_SCHEMA+'.'+TABLE_NAME), COLUMN_NAME, 'IsIdentity') AS [IsIdentity]
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Persons' AND COLUMN_NAME = 'id'
ORDER BY TABLE_NAME;
GO

SELECT * FROM Persons.Categories;
GO

SELECT * FROM Persons.Items;в
GO

SELECT * FROM Persons.Employees;
GO

SELECT * FROM Persons.Customers;
GO