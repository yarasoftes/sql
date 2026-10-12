USE ShopDB;
GO

PRINT '=== 1. СПИСОК ВСЕХ ТАБЛИЦ ===';
SELECT name AS TableName, create_date
FROM sys.tables
ORDER BY name;
GO

PRINT '=== 2. КОЛИЧЕСТВО СОЗДАННЫХ ТАБЛИЦ ===';
SELECT COUNT(*) AS TotalTables
FROM sys.tables;
GO

PRINT '=== 3. ВСЕ ИНДЕКСЫ (по каждой таблице) ===';
SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_primary_key AS IsPrimaryKey,
    i.is_unique AS IsUnique
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
WHERE i.name IS NOT NULL
ORDER BY t.name, i.name;
GO

PRINT '=== 4. ТАБЛИЦЫ И ИХ ФАЙЛОВЫЕ ГРУППЫ ===';
SELECT 
    t.name AS TableName,
    fg.name AS FileGroupName
FROM sys.tables t
JOIN sys.indexes i ON t.object_id = i.object_id
JOIN sys.filegroups fg ON i.data_space_id = fg.data_space_id
WHERE i.index_id <= 1
ORDER BY fg.name, t.name;
GO

PRINT '=== 5. СПИСОК ФАЙЛОВЫХ ГРУПП ===';
SELECT name AS FileGroupName, is_default
FROM sys.filegroups;
GO

PRINT '=== 6. ФАЙЛЫ БАЗЫ (mdf / ndf / ldf) ===';
SELECT 
    name AS LogicalName,
    physical_name AS PhysicalPath,
    type_desc AS FileType,
    size * 8 / 1024 AS SizeMB
FROM sys.database_files;
GO

PRINT '=== 7. РАЗМЕР ТАБЛИЦ (кол-во строк) ===';
SELECT 
    t.name AS TableName,
    SUM(p.rows) AS RowCount
FROM sys.tables t
JOIN sys.partitions p ON t.object_id = p.object_id
WHERE p.index_id IN (0, 1)
GROUP BY t.name
ORDER BY t.name;
GO

PRINT '=== 8. ПРОВЕРКА: НЕТ ЛИ ТАБЛИЦ В PRIMARY ===';
SELECT 
    t.name AS TableName,
    fg.name AS FileGroupName
FROM sys.tables t
JOIN sys.indexes i ON t.object_id = i.object_id
JOIN sys.filegroups fg ON i.data_space_id = fg.data_space_id
WHERE i.index_id <= 1 AND fg.name = 'PRIMARY';
GO

PRINT '=== 9. ОТЧЁТ: ВНЕШНИЕ КЛЮЧИ (связи) ===';
SELECT 
    fk.name AS FK_Name,
    tp.name AS ParentTable,
    cp.name AS ParentColumn,
    tr.name AS ReferencedTable,
    cr.name AS ReferencedColumn
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
JOIN sys.tables tp ON fkc.parent_object_id = tp.object_id
JOIN sys.columns cp ON fkc.parent_object_id = cp.object_id AND fkc.parent_column_id = cp.column_id
JOIN sys.tables tr ON fkc.referenced_object_id = tr.object_id
JOIN sys.columns cr ON fkc.referenced_object_id = cr.object_id AND fkc.referenced_column_id = cr.column_id
ORDER BY tp.name;
GO

PRINT '=== 10. ИНДЕКСЫ ПО ТИПАМ (сводка) ===';
SELECT 
    type_desc AS IndexType,
    COUNT(*) AS CountIndexes
FROM sys.indexes
WHERE name IS NOT NULL
GROUP BY type_desc;
GO