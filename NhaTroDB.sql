IF DB_ID(N'NhaTroDB') IS NULL
BEGIN
    EXEC(N'CREATE DATABASE NhaTroDB');
END
GO

USE NhaTroDB;
GO

SET NOCOUNT ON;
GO



IF OBJECT_ID(N'dbo.Contacts', N'U') IS NOT NULL
    DROP TABLE dbo.Contacts;
GO

IF OBJECT_ID(N'dbo.Favorites', N'U') IS NOT NULL
    DROP TABLE dbo.Favorites;
GO

IF OBJECT_ID(N'dbo.Rooms', N'U') IS NOT NULL
    DROP TABLE dbo.Rooms;
GO

IF OBJECT_ID(N'dbo.Categories', N'U') IS NOT NULL
    DROP TABLE dbo.Categories;
GO

IF OBJECT_ID(N'dbo.AspNetUsers', N'U') IS NOT NULL
    DROP TABLE dbo.AspNetUsers;
GO

-- TAO BANG ASPNETUSERS


CREATE TABLE dbo.AspNetUsers
(
    Id NVARCHAR(450) NOT NULL,
    UserName NVARCHAR(256) NOT NULL,
    Email NVARCHAR(256) NOT NULL,
    PasswordHash NVARCHAR(MAX) NULL,
    FullName NVARCHAR(150) NOT NULL,
    Role NVARCHAR(50) NOT NULL,
    Status NVARCHAR(50) NOT NULL
        CONSTRAINT DF_AspNetUsers_Status DEFAULT N'Active',
    CreatedAt DATETIME NOT NULL
        CONSTRAINT DF_AspNetUsers_CreatedAt DEFAULT GETDATE(),

    CONSTRAINT PK_AspNetUsers
        PRIMARY KEY (Id),

    CONSTRAINT UQ_AspNetUsers_UserName
        UNIQUE (UserName),

    CONSTRAINT UQ_AspNetUsers_Email
        UNIQUE (Email),

    CONSTRAINT CK_AspNetUsers_Role
        CHECK (Role IN (N'Tenant', N'Landlord', N'Admin')),

    CONSTRAINT CK_AspNetUsers_Status
        CHECK (Status IN (N'Active', N'Locked'))
);
GO


--  TAO BANG CATEGORIES

CREATE TABLE dbo.Categories
(
    CategoryId INT IDENTITY(1,1) NOT NULL,
    CategoryName NVARCHAR(150) NOT NULL,
    Type NVARCHAR(50) NOT NULL,
    Description NVARCHAR(500) NULL,
    IsActive BIT NOT NULL
        CONSTRAINT DF_Categories_IsActive DEFAULT 1,
    CreatedAt DATETIME NOT NULL
        CONSTRAINT DF_Categories_CreatedAt DEFAULT GETDATE(),

    CONSTRAINT PK_Categories
        PRIMARY KEY (CategoryId),

    CONSTRAINT CK_Categories_Type
        CHECK (Type IN (N'Location', N'RoomType'))
);
GO


--  TAO BANG ROOMS
CREATE TABLE dbo.Rooms
(
    RoomId INT IDENTITY(1,1) NOT NULL,
    Title NVARCHAR(250) NOT NULL,
    Price DECIMAL(18,2) NOT NULL,
    Area DECIMAL(10,2) NOT NULL,
    Address NVARCHAR(300) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    ImageUrl NVARCHAR(500) NULL,

    LocationCategoryId INT NOT NULL,
    RoomTypeCategoryId INT NOT NULL,
    LandlordId NVARCHAR(450) NOT NULL,

    ModerationStatus NVARCHAR(30) NOT NULL
        CONSTRAINT DF_Rooms_ModerationStatus DEFAULT N'Pending',

    RentalStatus NVARCHAR(30) NOT NULL
        CONSTRAINT DF_Rooms_RentalStatus DEFAULT N'Available',

    RejectionReason NVARCHAR(500) NULL,

    CreatedAt DATETIME NOT NULL
        CONSTRAINT DF_Rooms_CreatedAt DEFAULT GETDATE(),

    UpdatedAt DATETIME NULL,

    CONSTRAINT PK_Rooms
        PRIMARY KEY (RoomId),

    CONSTRAINT CK_Rooms_Price
        CHECK (Price >= 0),

    CONSTRAINT CK_Rooms_Area
        CHECK (Area > 0),

    CONSTRAINT CK_Rooms_ModerationStatus
        CHECK (
            ModerationStatus IN
            (N'Pending', N'Approved', N'Rejected')
        ),

    CONSTRAINT CK_Rooms_RentalStatus
        CHECK (
            RentalStatus IN (N'Available', N'Rented')
        ),

    CONSTRAINT FK_Rooms_LocationCategory
        FOREIGN KEY (LocationCategoryId)
        REFERENCES dbo.Categories(CategoryId),

    CONSTRAINT FK_Rooms_RoomTypeCategory
        FOREIGN KEY (RoomTypeCategoryId)
        REFERENCES dbo.Categories(CategoryId),

    CONSTRAINT FK_Rooms_AspNetUsers
        FOREIGN KEY (LandlordId)
        REFERENCES dbo.AspNetUsers(Id)
);
GO

--  TAO BANG FAVORITES

CREATE TABLE dbo.Favorites
(
    FavoriteId INT IDENTITY(1,1) NOT NULL,
    TenantId NVARCHAR(450) NOT NULL,
    RoomId INT NOT NULL,
    CreatedAt DATETIME NOT NULL
        CONSTRAINT DF_Favorites_CreatedAt DEFAULT GETDATE(),

    CONSTRAINT PK_Favorites
        PRIMARY KEY (FavoriteId),

    CONSTRAINT FK_Favorites_AspNetUsers
        FOREIGN KEY (TenantId)
        REFERENCES dbo.AspNetUsers(Id),

    CONSTRAINT FK_Favorites_Rooms
        FOREIGN KEY (RoomId)
        REFERENCES dbo.Rooms(RoomId)
        ON DELETE CASCADE,

    CONSTRAINT UQ_Favorites_Tenant_Room
        UNIQUE (TenantId, RoomId)
);
GO

--  TAO BANG CONTACTS

CREATE TABLE dbo.Contacts
(
    ContactId INT IDENTITY(1,1) NOT NULL,
    RoomId INT NOT NULL,
    SenderName NVARCHAR(150) NOT NULL,
    SenderPhone NVARCHAR(20) NOT NULL,
    Message NVARCHAR(500) NULL,
    CreatedAt DATETIME NOT NULL
        CONSTRAINT DF_Contacts_CreatedAt DEFAULT GETDATE(),

    CONSTRAINT PK_Contacts
        PRIMARY KEY (ContactId),

    CONSTRAINT FK_Contacts_Rooms
        FOREIGN KEY (RoomId)
        REFERENCES dbo.Rooms(RoomId)
);
GO

--  TAO INDEX DE HO TRO TRUY VAN


CREATE INDEX IX_Rooms_Moderation_Rental
ON dbo.Rooms(ModerationStatus, RentalStatus);
GO

CREATE INDEX IX_Rooms_LocationCategoryId
ON dbo.Rooms(LocationCategoryId);
GO

CREATE INDEX IX_Rooms_RoomTypeCategoryId
ON dbo.Rooms(RoomTypeCategoryId);
GO

CREATE INDEX IX_Rooms_LandlordId
ON dbo.Rooms(LandlordId);
GO

CREATE INDEX IX_Favorites_TenantId
ON dbo.Favorites(TenantId);
GO

CREATE INDEX IX_Contacts_RoomId
ON dbo.Contacts(RoomId);
GO

-- THEM DU LIEU NGUOI DUNG

INSERT INTO dbo.AspNetUsers
    (Id, UserName, Email, PasswordHash, FullName, Role, Status)
VALUES
    (N'USR001', N'admin', N'admin@nhatro.com', NULL,
     N'Quản trị viên', N'Admin', N'Active'),

    (N'USR002', N'nam', N'nam@gmail.com', NULL,
     N'Nguyễn Văn Nam', N'Landlord', N'Active'),

    (N'USR003', N'hoa', N'hoa@gmail.com', NULL,
     N'Trần Thị Hoa', N'Landlord', N'Active'),

    (N'USR004', N'anh', N'anh@gmail.com', NULL,
     N'Lê Minh Anh', N'Tenant', N'Active'),

    (N'USR005', N'ha', N'ha@gmail.com', NULL,
     N'Phạm Thu Hà', N'Tenant', N'Active'),

    (N'USR006', N'minh', N'minh@gmail.com', NULL,
     N'Phạm Quang Minh', N'Tenant', N'Active');
GO

--  THEM DANH MUC DIA DIEM VA LOAI PHONG

INSERT INTO dbo.Categories
    (CategoryName, Type, Description, IsActive)
VALUES
    (N'Quận Cầu Giấy', N'Location',
     N'Khu vực Cầu Giấy, Hà Nội', 1),

    (N'Quận Đống Đa', N'Location',
     N'Khu vực Đống Đa, Hà Nội', 1),

    (N'Quận Thanh Xuân', N'Location',
     N'Khu vực Thanh Xuân, Hà Nội', 1),

    (N'Quận Hai Bà Trưng', N'Location',
     N'Khu vực Hai Bà Trưng, Hà Nội', 1),

    (N'Quận Nam Từ Liêm', N'Location',
     N'Khu vực Nam Từ Liêm, Hà Nội', 1),

    (N'Phòng trọ bình dân', N'RoomType',
     N'Phòng trọ có mức giá tiết kiệm', 1),

    (N'Phòng trọ khép kín', N'RoomType',
     N'Phòng có khu vệ sinh riêng', 1),

    (N'Căn hộ mini', N'RoomType',
     N'Căn hộ diện tích nhỏ, tiện nghi', 1),

    (N'Phòng ở ghép', N'RoomType',
     N'Phòng dành cho nhiều người ở chung', 1);
GO

--  THEM 10 PHONG TRO MAU

INSERT INTO dbo.Rooms
(
    Title,
    Price,
    Area,
    Address,
    Description,
    ImageUrl,
    LocationCategoryId,
    RoomTypeCategoryId,
    LandlordId,
    ModerationStatus,
    RentalStatus,
    RejectionReason,
    CreatedAt,
    UpdatedAt
)
VALUES
(
    N'Phòng trọ gần trường đại học',
    2500000, 25.00,
    N'Cầu Giấy, Hà Nội',
    N'Phòng thoáng mát, gần trường đại học, phù hợp sinh viên.',
    N'/images/phong1.jpg',
    1, 6, N'USR002',
    N'Approved', N'Available', NULL,
    GETDATE(), NULL
),
(
    N'Phòng trọ khép kín tại Đống Đa',
    3200000, 30.00,
    N'Đống Đa, Hà Nội',
    N'Phòng có nhà vệ sinh riêng, an ninh tốt, dễ di chuyển.',
    N'/images/phong2.jpg',
    2, 7, N'USR003',
    N'Approved', N'Available', NULL,
    GETDATE(), NULL
),
(
    N'Căn hộ mini đầy đủ nội thất',
    4500000, 35.00,
    N'Thanh Xuân, Hà Nội',
    N'Căn hộ có điều hòa, giường, tủ và khu bếp.',
    N'/images/phong3.jpg',
    3, 8, N'USR002',
    N'Pending', N'Available', NULL,
    GETDATE(), NULL
),
(
    N'Phòng trọ cần bổ sung thông tin',
    1800000, 18.00,
    N'Cầu Giấy, Hà Nội',
    N'Phòng nhỏ, phù hợp một người ở.',
    N'/images/phong4.jpg',
    1, 6, N'USR003',
    N'Rejected', N'Available',
    N'Thông tin bài đăng chưa đầy đủ.',
    GETDATE(), NULL
),
(
    N'Phòng trọ đã cho thuê',
    2800000, 22.00,
    N'Đống Đa, Hà Nội',
    N'Phòng có ban công và chỗ để xe.',
    N'/images/phong5.jpg',
    2, 7, N'USR002',
    N'Approved', N'Rented', NULL,
    GETDATE(), NULL
),
(
    N'Phòng trọ giá tốt tại Hai Bà Trưng',
    2300000, 20.00,
    N'Hai Bà Trưng, Hà Nội',
    N'Phòng sạch sẽ, gần chợ và phương tiện công cộng.',
    N'/images/phong6.jpg',
    4, 6, N'USR003',
    N'Approved', N'Available', NULL,
    GETDATE(), NULL
),
(
    N'Phòng trọ có vệ sinh riêng',
    3500000, 28.00,
    N'Nam Từ Liêm, Hà Nội',
    N'Phòng khép kín, có cửa sổ và khu để xe.',
    N'/images/phong7.jpg',
    5, 7, N'USR002',
    N'Approved', N'Available', NULL,
    GETDATE(), NULL
),
(
    N'Căn hộ mini gần khu văn phòng',
    5200000, 40.00,
    N'Cầu Giấy, Hà Nội',
    N'Căn hộ mini có khu bếp riêng và không gian sinh hoạt tiện nghi.',
    N'/images/phong8.jpg',
    1, 8, N'USR003',
    N'Pending', N'Available', NULL,
    GETDATE(), NULL
),
(
    N'Phòng ở ghép tiết kiệm',
    1500000, 24.00,
    N'Thanh Xuân, Hà Nội',
    N'Phù hợp sinh viên muốn tiết kiệm chi phí thuê phòng.',
    N'/images/phong9.jpg',
    3, 9, N'USR002',
    N'Approved', N'Available', NULL,
    GETDATE(), NULL
),
(
    N'Phòng trọ yên tĩnh gần công viên',
    3000000, 26.50,
    N'Nam Từ Liêm, Hà Nội',
    N'Khu dân cư yên tĩnh, thuận tiện sinh hoạt.',
    N'/images/phong10.jpg',
    5, 6, N'USR003',
    N'Approved', N'Available', NULL,
    GETDATE(), NULL
);
GO

-- THEM PHONG YEU THICH


INSERT INTO dbo.Favorites (TenantId, RoomId)
VALUES
    (N'USR004', 1),
    (N'USR004', 2),
    (N'USR004', 6),
    (N'USR005', 1),
    (N'USR005', 7),
    (N'USR006', 9);
GO

--  THEM THONG TIN LIEN HE


INSERT INTO dbo.Contacts
    (RoomId, SenderName, SenderPhone, Message)
VALUES
    (1, N'Lê Minh Anh', N'0912345678',
     N'Tôi muốn hỏi phòng còn trống không.'),

    (2, N'Phạm Thu Hà', N'0987654321',
     N'Tôi muốn đến xem phòng vào cuối tuần.'),

    (6, N'Phạm Quang Minh', N'0901234567',
     N'Tôi muốn hỏi thêm về chi phí thuê phòng.');
GO

--  KIEM TRA DU LIEU SAU KHI TAO

PRINT N'===== NGUOI DUNG =====';
SELECT Id, UserName, Email, FullName, Role, Status, CreatedAt
FROM dbo.AspNetUsers
ORDER BY Id;

PRINT N'===== DANH MUC =====';
SELECT CategoryId, CategoryName, Type, IsActive
FROM dbo.Categories
ORDER BY CategoryId;

PRINT N'===== PHONG TRO =====';
SELECT
    r.RoomId,
    r.Title,
    r.Price,
    r.Area,
    r.Address,
    lc.CategoryName AS LocationName,
    rtc.CategoryName AS RoomTypeName,
    u.FullName AS LandlordName,
    r.ModerationStatus,
    r.RentalStatus,
    r.ImageUrl
FROM dbo.Rooms AS r
INNER JOIN dbo.Categories AS lc
    ON r.LocationCategoryId = lc.CategoryId
INNER JOIN dbo.Categories AS rtc
    ON r.RoomTypeCategoryId = rtc.CategoryId
INNER JOIN dbo.AspNetUsers AS u
    ON r.LandlordId = u.Id
ORDER BY r.RoomId;

PRINT N'===== PHONG YEU THICH =====';
SELECT
    f.FavoriteId,
    u.FullName AS TenantName,
    r.Title AS RoomTitle,
    f.CreatedAt
FROM dbo.Favorites AS f
INNER JOIN dbo.AspNetUsers AS u
    ON f.TenantId = u.Id
INNER JOIN dbo.Rooms AS r
    ON f.RoomId = r.RoomId
ORDER BY f.FavoriteId;

PRINT N'===== LIEN HE =====';
SELECT
    c.ContactId,
    r.Title AS RoomTitle,
    c.SenderName,
    c.SenderPhone,
    c.Message,
    c.CreatedAt
FROM dbo.Contacts AS c
INNER JOIN dbo.Rooms AS r
    ON c.RoomId = r.RoomId
ORDER BY c.ContactId;

PRINT N'===== SO LUONG BAN GHI =====';
SELECT N'AspNetUsers' AS TableName, COUNT(*) AS TotalRows
FROM dbo.AspNetUsers
UNION ALL
SELECT N'Categories', COUNT(*) FROM dbo.Categories
UNION ALL
SELECT N'Rooms', COUNT(*) FROM dbo.Rooms
UNION ALL
SELECT N'Favorites', COUNT(*) FROM dbo.Favorites
UNION ALL
SELECT N'Contacts', COUNT(*) FROM dbo.Contacts;
GO