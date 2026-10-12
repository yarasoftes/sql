USE ShopDB;
GO

PRINT '=== 1. СПИСОК ТАБЛИЦ ===';
SELECT name AS TableName, create_date
FROM sys.tables
ORDER BY name;
GO

PRINT '=== 2. КОЛИЧЕСТВО ТАБЛИЦ ===';
SELECT COUNT(*) AS TotalTables FROM sys.tables;
GO

PRINT '=== 3. ИНДЕКСЫ ===';
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

PRINT '=== 5. ФАЙЛОВЫЕ ГРУППЫ ===';
SELECT name AS FileGroupName, is_default FROM sys.filegroups;
GO

PRINT '=== 6. ФАЙЛЫ БАЗЫ (отчёт) ===';
SELECT 
    name AS LogicalName,
    physical_name AS PhysicalPath,
    type_desc AS FileType,
    size * 8 / 1024 AS SizeMB
FROM sys.database_files;
GO

PRINT '=== 7. СВЯЗИ (внешние ключи) ===';
SELECT 
    fk.name AS FK_Name,
    tp.name AS ParentTable,
    tr.name AS ReferencedTable
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
JOIN sys.tables tp ON fkc.parent_object_id = tp.object_id
JOIN sys.tables tr ON fkc.referenced_object_id = tr.object_id
ORDER BY tp.name;
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