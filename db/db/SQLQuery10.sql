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