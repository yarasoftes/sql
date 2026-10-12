USE ShopDB;
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