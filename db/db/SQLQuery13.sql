USE ShopDB;
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