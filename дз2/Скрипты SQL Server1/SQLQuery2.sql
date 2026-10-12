USE master;
GO

IF DB_ID('SteamDB') IS NOT NULL
BEGIN
    ALTER DATABASE SteamDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SteamDB;
END
GO

CREATE DATABASE SteamDB;
GO

USE SteamDB;
GO

CREATE TABLE UserAccount (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Login NVARCHAR(50) NOT NULL UNIQUE,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE UserProfile (
    ProfileID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    Nickname NVARCHAR(50) NOT NULL,
    Country NVARCHAR(50) NULL,
    Balance DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (Balance >= 0),
    CONSTRAINT FK_UserProfile_UserAccount FOREIGN KEY (UserID) REFERENCES UserAccount(UserID)
);

CREATE TABLE Publisher (
    PublisherID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Country NVARCHAR(50) NULL
);

CREATE TABLE Developer (
    DeveloperID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    FoundedYear INT NULL CHECK (FoundedYear BETWEEN 1900 AND 2100)
);

CREATE TABLE Genre (
    GenreID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Game (
    GameID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(150) NOT NULL,
    Price DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (Price >= 0),
    ReleaseDate DATE NULL,
    PublisherID INT NULL,
    DeveloperID INT NULL,
    CONSTRAINT FK_Game_Publisher FOREIGN KEY (PublisherID) REFERENCES Publisher(PublisherID),
    CONSTRAINT FK_Game_Developer FOREIGN KEY (DeveloperID) REFERENCES Developer(DeveloperID)
);

CREATE TABLE GameGenre (
    GameID INT NOT NULL,
    GenreID INT NOT NULL,
    PRIMARY KEY (GameID, GenreID),
    CONSTRAINT FK_GameGenre_Game FOREIGN KEY (GameID) REFERENCES Game(GameID),
    CONSTRAINT FK_GameGenre_Genre FOREIGN KEY (GenreID) REFERENCES Genre(GenreID)
);

CREATE TABLE Achievement (
    AchievementID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255) NULL,
    Points INT NOT NULL DEFAULT 10 CHECK (Points > 0)
);

CREATE TABLE GameAchievement (
    GameID INT NOT NULL,
    AchievementID INT NOT NULL,
    PRIMARY KEY (GameID, AchievementID),
    CONSTRAINT FK_GameAchievement_Game FOREIGN KEY (GameID) REFERENCES Game(GameID),
    CONSTRAINT FK_GameAchievement_Achievement FOREIGN KEY (AchievementID) REFERENCES Achievement(AchievementID)
);

CREATE TABLE Purchase (
    PurchaseID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    GameID INT NOT NULL,
    PurchaseDate DATETIME NOT NULL DEFAULT GETDATE(),
    Amount DECIMAL(10,2) NOT NULL CHECK (Amount >= 0),
    CONSTRAINT FK_Purchase_User FOREIGN KEY (UserID) REFERENCES UserAccount(UserID),
    CONSTRAINT FK_Purchase_Game FOREIGN KEY (GameID) REFERENCES Game(GameID)
);

CREATE TABLE Review (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    GameID INT NOT NULL,
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 10),
    Comment NVARCHAR(500) NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Review_User FOREIGN KEY (UserID) REFERENCES UserAccount(UserID),
    CONSTRAINT FK_Review_Game FOREIGN KEY (GameID) REFERENCES Game(GameID)
);

CREATE TABLE FriendList (
    UserID INT NOT NULL,
    FriendID INT NOT NULL,
    Since DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (UserID, FriendID),
    CONSTRAINT FK_FriendList_User FOREIGN KEY (UserID) REFERENCES UserAccount(UserID),
    CONSTRAINT FK_FriendList_Friend FOREIGN KEY (FriendID) REFERENCES UserAccount(UserID),
    CONSTRAINT CHK_NotSelfFriend CHECK (UserID <> FriendID)
);
GO

INSERT INTO UserAccount (Login, Email, PasswordHash) VALUES
('vasya', 'vasya@mail.com', 'hash1'),
('petya', 'petya@mail.com', 'hash2'),
('kolya', 'kolya@mail.com', 'hash3'),
('masha', 'masha@mail.com', 'hash4'),
('dasha', 'dasha@mail.com', 'hash5');

INSERT INTO UserProfile (UserID, Nickname, Country, Balance) VALUES
(1, 'VasyaPro', 'Russia', 500.00),
(2, 'PetyaKing', 'Ukraine', 250.50),
(3, 'KolyaGamer', 'Kazakhstan', 1000.00),
(4, 'MashaPlay', 'Belarus', 100.00),
(5, 'DashaCool', 'Russia', 750.75);

INSERT INTO Publisher (Name, Country) VALUES
('Valve', 'USA'),
('Ubisoft', 'France'),
('EA Games', 'USA'),
('CD Projekt', 'Poland'),
('Rockstar', 'USA');

INSERT INTO Developer (Name, FoundedYear) VALUES
('Valve Corp', 1996),
('Ubisoft Montreal', 1997),
('DICE', 1992),
('CD Projekt Red', 2002),
('Rockstar North', 1988);

INSERT INTO Genre (Name) VALUES
('Action'),
('RPG'),
('Shooter'),
('Strategy'),
('Sports');

INSERT INTO Game (Title, Price, ReleaseDate, PublisherID, DeveloperID) VALUES
('Counter-Strike 2', 0.00, '2023-09-27', 1, 1),
('Assassin''s Creed', 39.99, '2007-11-13', 2, 2),
('Battlefield 2042', 59.99, '2021-11-19', 3, 3),
('The Witcher 3', 29.99, '2015-05-19', 4, 4),
('GTA V', 19.99, '2013-09-17', 5, 5);

INSERT INTO GameGenre (GameID, GenreID) VALUES
(1, 3), (1, 1),
(2, 1), (2, 2),
(3, 3), (3, 1),
(4, 2), (4, 1),
(5, 1), (5, 2);

INSERT INTO Achievement (Name, Description, Points) VALUES
('First Blood', 'Убей первого врага', 10),
('Sharp Shooter', '100 попаданий в голову', 50),
('Veteran', 'Играй 100 часов', 100),
('Explorer', 'Открой всю карту', 30),
('Speedrun', 'Пройди игру за 5 часов', 75);

INSERT INTO GameAchievement (GameID, AchievementID) VALUES
(1, 1), (1, 2), (1, 3),
(2, 4), (2, 5),
(3, 1), (3, 3),
(4, 4), (4, 5),
(5, 2), (5, 5);

INSERT INTO Purchase (UserID, GameID, Amount) VALUES
(1, 1, 0.00),
(1, 4, 29.99),
(2, 3, 59.99),
(3, 5, 19.99),
(4, 2, 39.99),
(5, 4, 29.99);

INSERT INTO Review (UserID, GameID, Rating, Comment) VALUES
(1, 1, 10, 'Лучший шутер!'),
(1, 4, 9, 'Шедевр'),
(2, 3, 5, 'Так себе'),
(3, 5, 8, 'Классика'),
(4, 2, 7, 'Неплохо'),
(5, 4, 10, 'Топ!');

INSERT INTO FriendList (UserID, FriendID) VALUES
(1, 2), (1, 3),
(2, 1), (2, 4),
(3, 1), (3, 5),
(4, 2), (4, 5),
(5, 3), (5, 4);
GO

SELECT * FROM UserAccount;
SELECT * FROM UserProfile;
SELECT * FROM Publisher;
SELECT * FROM Developer;
SELECT * FROM Genre;
SELECT * FROM Game;
SELECT * FROM GameGenre;
SELECT * FROM Achievement;
SELECT * FROM GameAchievement;
SELECT * FROM Purchase;
SELECT * FROM Review;
SELECT * FROM FriendList;
GO

SELECT u.Login, p.Nickname, g.Title, pu.Amount
FROM Purchase pu
JOIN UserAccount u ON pu.UserID = u.UserID
JOIN UserProfile p ON u.UserID = p.UserID
JOIN Game g ON pu.GameID = g.GameID;

SELECT g.Title, AVG(CAST(r.Rating AS DECIMAL(4,2))) AS AvgRating
FROM Review r
JOIN Game g ON r.GameID = g.GameID
GROUP BY g.Title;

SELECT g.Title, ge.Name AS Genre
FROM Game g
JOIN GameGenre gg ON g.GameID = gg.GameID
JOIN Genre ge ON gg.GenreID = ge.GenreID
ORDER BY g.Title;
GO