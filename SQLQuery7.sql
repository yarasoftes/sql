USE master;
GO

IF DB_ID('GamePlatform') IS NOT NULL
BEGIN
    ALTER DATABASE GamePlatform
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE GamePlatform;
END
GO

CREATE DATABASE GamePlatform;
GO

USE GamePlatform;
GO

CREATE TABLE Users
(
    UserID INT IDENTITY(1,1) NOT NULL,
    Login NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    RegistrationDate DATETIME2 NOT NULL
        CONSTRAINT DF_Users_RegistrationDate DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Users PRIMARY KEY (UserID),
    CONSTRAINT UQ_Users_Login UNIQUE (Login),
    CONSTRAINT UQ_Users_Email UNIQUE (Email)
);
GO

CREATE TABLE UserProfiles
(
    UserID INT NOT NULL,
    FirstName NVARCHAR(50) NULL,
    LastName NVARCHAR(50) NULL,
    BirthDate DATE NULL,
    Country NVARCHAR(100) NULL,
    AvatarURL NVARCHAR(500) NULL,

    CONSTRAINT PK_UserProfiles PRIMARY KEY (UserID),
    CONSTRAINT FK_UserProfiles_Users
        FOREIGN KEY (UserID)
        REFERENCES Users(UserID)
        ON DELETE CASCADE
);
GO

CREATE TABLE Developers
(
    DeveloperID INT IDENTITY(1,1) NOT NULL,
    DeveloperName NVARCHAR(150) NOT NULL,
    Country NVARCHAR(100) NULL,
    FoundedYear INT NULL,
    Website NVARCHAR(300) NULL,

    CONSTRAINT PK_Developers PRIMARY KEY (DeveloperID),
    CONSTRAINT UQ_Developers_Name UNIQUE (DeveloperName)
);
GO

CREATE TABLE Publishers
(
    PublisherID INT IDENTITY(1,1) NOT NULL,
    PublisherName NVARCHAR(150) NOT NULL,
    Country NVARCHAR(100) NULL,
    Website NVARCHAR(300) NULL,

    CONSTRAINT PK_Publishers PRIMARY KEY (PublisherID),
    CONSTRAINT UQ_Publishers_Name UNIQUE (PublisherName)
);
GO

CREATE TABLE Genres
(
    GenreID INT IDENTITY(1,1) NOT NULL,
    GenreName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500) NULL,

    CONSTRAINT PK_Genres PRIMARY KEY (GenreID),
    CONSTRAINT UQ_Genres_Name UNIQUE (GenreName)
);
GO

CREATE TABLE Tags
(
    TagID INT IDENTITY(1,1) NOT NULL,
    TagName NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_Tags PRIMARY KEY (TagID),
    CONSTRAINT UQ_Tags_Name UNIQUE (TagName)
);
GO

CREATE TABLE Games
(
    GameID INT IDENTITY(1,1) NOT NULL,
    PublisherID INT NULL,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    ReleaseDate DATE NULL,
    Price DECIMAL(10,2) NOT NULL,
    AgeRating NVARCHAR(20) NULL,

    CONSTRAINT PK_Games PRIMARY KEY (GameID),

    CONSTRAINT FK_Games_Publishers
        FOREIGN KEY (PublisherID)
        REFERENCES Publishers(PublisherID)
        ON DELETE SET NULL,

    CONSTRAINT CK_Games_Price
        CHECK (Price >= 0)
);
GO

CREATE TABLE GameTags
(
    GameID INT NOT NULL,
    TagID INT NOT NULL,

    CONSTRAINT PK_GameTags
        PRIMARY KEY (GameID, TagID),

    CONSTRAINT FK_GameTags_Games
        FOREIGN KEY (GameID)
        REFERENCES Games(GameID)
        ON DELETE CASCADE,

    CONSTRAINT FK_GameTags_Tags
        FOREIGN KEY (TagID)
        REFERENCES Tags(TagID)
        ON DELETE CASCADE
);
GO

CREATE TABLE GameDevelopers
(
    GameID INT NOT NULL,
    DeveloperID INT NOT NULL,
    Role NVARCHAR(100) NULL,

    CONSTRAINT PK_GameDevelopers
        PRIMARY KEY (GameID, DeveloperID),

    CONSTRAINT FK_GameDevelopers_Games
        FOREIGN KEY (GameID)
        REFERENCES Games(GameID)
        ON DELETE CASCADE,

    CONSTRAINT FK_GameDevelopers_Developers
        FOREIGN KEY (DeveloperID)
        REFERENCES Developers(DeveloperID)
        ON DELETE CASCADE
);
GO

CREATE TABLE GameGenres
(
    GameID INT NOT NULL,
    GenreID INT NOT NULL,

    CONSTRAINT PK_GameGenres
        PRIMARY KEY (GameID, GenreID),

    CONSTRAINT FK_GameGenres_Games
        FOREIGN KEY (GameID)
        REFERENCES Games(GameID)
        ON DELETE CASCADE,

    CONSTRAINT FK_GameGenres_Genres
        FOREIGN KEY (GenreID)
        REFERENCES Genres(GenreID)
        ON DELETE CASCADE
);
GO

CREATE TABLE Platforms
(
    PlatformID INT IDENTITY(1,1) NOT NULL,
    PlatformName NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_Platforms PRIMARY KEY (PlatformID),
    CONSTRAINT UQ_Platforms_Name UNIQUE (PlatformName)
);
GO

CREATE TABLE GamePlatforms
(
    GameID INT NOT NULL,
    PlatformID INT NOT NULL,
    ReleaseDate DATE NULL,

    CONSTRAINT PK_GamePlatforms
        PRIMARY KEY (GameID, PlatformID),

    CONSTRAINT FK_GamePlatforms_Games
        FOREIGN KEY (GameID)
        REFERENCES Games(GameID)
        ON DELETE CASCADE,

    CONSTRAINT FK_GamePlatforms_Platforms
        FOREIGN KEY (PlatformID)
        REFERENCES Platforms(PlatformID)
        ON DELETE CASCADE
);
GO

CREATE TABLE Reviews
(
    ReviewID INT IDENTITY(1,1) NOT NULL,
    UserID INT NOT NULL,
    GameID INT NOT NULL,
    Rating INT NOT NULL,
    ReviewText NVARCHAR(MAX) NULL,
    ReviewDate DATETIME2 NOT NULL
        CONSTRAINT DF_Reviews_ReviewDate DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Reviews PRIMARY KEY (ReviewID),

    CONSTRAINT FK_Reviews_Users
        FOREIGN KEY (UserID)
        REFERENCES Users(UserID)
        ON DELETE CASCADE,

    CONSTRAINT FK_Reviews_Games
        FOREIGN KEY (GameID)
        REFERENCES Games(GameID)
        ON DELETE CASCADE,

    CONSTRAINT CK_Reviews_Rating
        CHECK (Rating BETWEEN 1 AND 10),

    CONSTRAINT UQ_Reviews_UserGame
        UNIQUE (UserID, GameID)
);
GO

CREATE TABLE UserGames
(
    UserID INT NOT NULL,
    GameID INT NOT NULL,
    PurchaseDate DATETIME2 NOT NULL
        CONSTRAINT DF_UserGames_PurchaseDate DEFAULT SYSDATETIME(),
    HoursPlayed DECIMAL(10,2) NOT NULL
        CONSTRAINT DF_UserGames_HoursPlayed DEFAULT 0,

    CONSTRAINT PK_UserGames
        PRIMARY KEY (UserID, GameID),

    CONSTRAINT FK_UserGames_Users
        FOREIGN KEY (UserID)
        REFERENCES Users(UserID)
        ON DELETE CASCADE,

    CONSTRAINT FK_UserGames_Games
        FOREIGN KEY (GameID)
        REFERENCES Games(GameID)
        ON DELETE CASCADE,

    CONSTRAINT CK_UserGames_Hours
        CHECK (HoursPlayed >= 0)
);
GO

CREATE INDEX IX_Games_PublisherID
ON Games(PublisherID);
GO

CREATE INDEX IX_GameTags_TagID
ON GameTags(TagID);
GO

CREATE INDEX IX_GameDevelopers_DeveloperID
ON GameDevelopers(DeveloperID);
GO

CREATE INDEX IX_GameGenres_GenreID
ON GameGenres(GenreID);
GO

CREATE INDEX IX_GamePlatforms_PlatformID
ON GamePlatforms(PlatformID);
GO

CREATE INDEX IX_Reviews_GameID
ON Reviews(GameID);
GO

CREATE INDEX IX_Reviews_UserID
ON Reviews(UserID);
GO

INSERT INTO Users
    (Login, Email, PasswordHash)
VALUES
    ('alex01', 'alex@mail.com', 'hash001'),
    ('max123', 'max@mail.com', 'hash002'),
    ('anna_gamer', 'anna@mail.com', 'hash003'),
    ('dmitry88', 'dmitry@mail.com', 'hash004'),
    ('kate_play', 'kate@mail.com', 'hash005');
GO

INSERT INTO UserProfiles
    (UserID, FirstName, LastName, BirthDate, Country)
VALUES
    (1, 'Alex', 'Petrov', '2002-05-12', 'Estonia'),
    (2, 'Max', 'Ivanov', '2001-03-20', 'Russia'),
    (3, 'Anna', 'Smith', '2003-08-14', 'Germany'),
    (4, 'Dmitry', 'Volkov', '1999-11-01', 'Latvia'),
    (5, 'Kate', 'Brown', '2004-01-25', 'Finland');
GO

INSERT INTO Developers
    (DeveloperName, Country, FoundedYear)
VALUES
    ('Valve', 'USA', 1996),
    ('CD Projekt Red', 'Poland', 2002),
    ('FromSoftware', 'Japan', 1986),
    ('Supergiant Games', 'USA', 2009),
    ('Mojang Studios', 'Sweden', 2009);
GO

INSERT INTO Publishers
    (PublisherName, Country)
VALUES
    ('Valve Corporation', 'USA'),
    ('CD Projekt', 'Poland'),
    ('Bandai Namco', 'Japan'),
    ('Devolver Digital', 'USA'),
    ('Microsoft', 'USA');
GO

INSERT INTO Genres
    (GenreName, Description)
VALUES
    ('Action', 'Экшен игры'),
    ('RPG', 'Ролевые игры'),
    ('Adventure', 'Приключенческие игры'),
    ('Horror', 'Игры ужасов'),
    ('Strategy', 'Стратегии'),
    ('Sandbox', 'Игры с открытым игровым миром');
GO

INSERT INTO Tags
    (TagName)
VALUES
    ('Кооператив'),
    ('Пиксель-арт'),
    ('Хоррор'),
    ('Ранний доступ'),
    ('Открытый мир'),
    ('Сложная'),
    ('Онлайн'),
    ('Однопользовательская');
GO

INSERT INTO Platforms
    (PlatformName)
VALUES
    ('PC'),
    ('PlayStation 5'),
    ('Xbox Series X'),
    ('Nintendo Switch');
GO

INSERT INTO Games
    (PublisherID, Title, Description, ReleaseDate, Price, AgeRating)
VALUES
    (1, 'Half-Life 2', 'Классический научно-фантастический шутер.', '2004-11-16', 9.99, '16+'),
    (2, 'Cyberpunk 2077', 'Ролевая игра в открытом мире.', '2020-12-10', 59.99, '18+'),
    (3, 'Elden Ring', 'Action RPG в большом фэнтезийном мире.', '2022-02-25', 59.99, '16+'),
    (4, 'Hades', 'Динамичный roguelike action RPG.', '2020-09-17', 24.99, '12+'),
    (5, 'Minecraft', 'Песочница с исследованием и строительством.', '2011-11-18', 29.99, '7+'),
    (1, 'Portal 2', 'Головоломка от первого лица.', '2011-04-19', 9.99, '12+'),
    (3, 'Dark Souls III', 'Сложная action RPG.', '2016-04-12', 39.99, '16+'),
    (4, 'Dead Cells', 'Roguelike метроидвания.', '2018-08-07', 24.99, '12+'),
    (2, 'The Witcher 3', 'Большая ролевая игра с открытым миром.', '2015-05-19', 39.99, '18+'),
    (1, 'Left 4 Dead 2', 'Кооперативный шутер про выживание.', '2009-11-17', 9.99, '18+');
GO

INSERT INTO GameTags
    (GameID, TagID)
VALUES
    (1, 8),
    (2, 5),
    (2, 8),
    (3, 6),
    (3, 5),
    (4, 2),
    (4, 8),
    (5, 1),
    (5, 5),
    (6, 1),
    (7, 6),
    (8, 2),
    (9, 5),
    (10, 1),
    (10, 3),
    (10, 7);
GO

INSERT INTO GameDevelopers
    (GameID, DeveloperID, Role)
VALUES
    (1, 1, 'Основной разработчик'),
    (2, 2, 'Основной разработчик'),
    (3, 3, 'Основной разработчик'),
    (4, 4, 'Основной разработчик'),
    (5, 5, 'Основной разработчик'),
    (6, 1, 'Основной разработчик'),
    (7, 3, 'Основной разработчик'),
    (8, 4, 'Основной разработчик'),
    (9, 2, 'Основной разработчик'),
    (10, 1, 'Основной разработчик');
GO

INSERT INTO GameGenres
    (GameID, GenreID)
VALUES
    (1, 1),
    (2, 2),
    (2, 3),
    (3, 1),
    (3, 2),
    (4, 1),
    (4, 2),
    (5, 6),
    (6, 1),
    (6, 3),
    (7, 1),
    (7, 2),
    (8, 1),
    (9, 2),
    (9, 3),
    (10, 1);
GO

INSERT INTO GamePlatforms
    (GameID, PlatformID, ReleaseDate)
VALUES
    (1, 1, '2004-11-16'),
    (2, 1, '2020-12-10'),
    (2, 2, '2020-12-10'),
    (2, 3, '2020-12-10'),
    (3, 1, '2022-02-25'),
    (3, 2, '2022-02-25'),
    (3, 3, '2022-02-25'),
    (4, 1, '2020-09-17'),
    (4, 4, '2020-09-17'),
    (5, 1, '2011-11-18'),
    (5, 4, '2011-11-18'),
    (6, 1, '2011-04-19'),
    (7, 1, '2016-04-12'),
    (7, 2, '2016-04-12'),
    (8, 1, '2018-08-07'),
    (9, 1, '2015-05-19'),
    (10, 1, '2009-11-17');
GO

INSERT INTO UserGames
    (UserID, GameID, HoursPlayed)
VALUES
    (1, 1, 25.5),
    (1, 3, 72.2),
    (1, 5, 150.0),
    (2, 2, 80.5),
    (2, 4, 35.7),
    (3, 5, 220.1),
    (3, 6, 12.5),
    (4, 7, 90.0),
    (4, 9, 110.5),
    (5, 4, 20.2),
    (5, 8, 40.8);
GO

INSERT INTO Reviews
    (UserID, GameID, Rating, ReviewText)
VALUES
    (1, 1, 10, 'Отличная классика.'),
    (1, 3, 9, 'Большой и интересный мир.'),
    (2, 2, 8, 'Интересная RPG.'),
    (3, 5, 10, 'Можно играть очень долго.'),
    (4, 7, 9, 'Очень сложная игра.'),
    (5, 4, 9, 'Отличный roguelike.');
GO

SELECT COUNT(*) AS TableCount
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';
GO

SELECT COUNT(*) AS ForeignKeyCount
FROM sys.foreign_keys;
GO

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO

SELECT
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS ChildTable,
    OBJECT_NAME(fk.referenced_object_id) AS ParentTable
FROM sys.foreign_keys fk
ORDER BY ChildTable;
GO

SELECT
    g.Title AS Game,
    d.DeveloperName AS Developer,
    gd.Role
FROM Games g
JOIN GameDevelopers gd
    ON g.GameID = gd.GameID
JOIN Developers d
    ON gd.DeveloperID = d.DeveloperID
ORDER BY g.Title;
GO

SELECT
    g.Title AS Game,
    t.TagName AS Tag
FROM Games g
JOIN GameTags gt
    ON g.GameID = gt.GameID
JOIN Tags t
    ON gt.TagID = t.TagID
ORDER BY g.Title, t.TagName;
GO

SELECT
    g.Title AS Game,
    gr.GenreName AS Genre
FROM Games g
JOIN GameGenres gg
    ON g.GameID = gg.GameID
JOIN Genres gr
    ON gg.GenreID = gr.GenreID
ORDER BY g.Title;
GO

SELECT
    u.UserID,
    u.Login,
    u.Email,
    up.FirstName,
    up.LastName,
    up.Country
FROM Users u
JOIN UserProfiles up
    ON u.UserID = up.UserID;
GO

SELECT
    g.Title,
    AVG(CAST(r.Rating AS DECIMAL(4,2))) AS AverageRating,
    COUNT(r.ReviewID) AS ReviewCount
FROM Games g
LEFT JOIN Reviews r
    ON g.GameID = r.GameID
GROUP BY g.GameID, g.Title
ORDER BY AverageRating DESC;
GO

SELECT
    d.DeveloperName,
    COUNT(gd.GameID) AS GamesCount
FROM Developers d
LEFT JOIN GameDevelopers gd
    ON d.DeveloperID = gd.DeveloperID
GROUP BY d.DeveloperID, d.DeveloperName
ORDER BY GamesCount DESC;
GO

SELECT
    u.Login,
    g.Title,
    ug.HoursPlayed,
    ug.PurchaseDate
FROM UserGames ug
JOIN Users u
    ON ug.UserID = u.UserID
JOIN Games g
    ON ug.GameID = g.GameID
WHERE u.UserID = 1;
GO