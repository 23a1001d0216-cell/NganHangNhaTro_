USE NhaTroDB;
GO

CREATE TABLE AspNetUsers (
    Id NVARCHAR(450) PRIMARY KEY,
    UserName NVARCHAR(256),
    Email NVARCHAR(256),
    PasswordHash NVARCHAR(MAX),
    FullName NVARCHAR(150) NOT NULL,
    Role NVARCHAR(50) NOT NULL,
    Status NVARCHAR(50) NOT NULL DEFAULT N'Active',
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT CK_AspNetUsers_Role
        CHECK (Role IN (N'Tenant', N'Landlord', N'Admin')),

    CONSTRAINT CK_AspNetUsers_Status
        CHECK (Status IN (N'Active', N'Locked'))
);

CREATE TABLE Categories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(150) NOT NULL,
    Type NVARCHAR(50) NOT NULL,

    CONSTRAINT CK_Categories_Type
        CHECK (Type IN (N'Location', N'RoomType'))
);

CREATE TABLE Rooms (
    RoomId INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(250) NOT NULL,
    Price DECIMAL(18,2) NOT NULL,
    Area FLOAT NOT NULL,
    Address NVARCHAR(300) NOT NULL,
    Description NVARCHAR(MAX),
    ImageUrl NVARCHAR(500),
    Status NVARCHAR(50) NOT NULL DEFAULT N'Pending',
    RejectionReason NVARCHAR(500),
    CategoryId INT NOT NULL,
    LandlordId NVARCHAR(450) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT CK_Rooms_Price
        CHECK (Price >= 0),

    CONSTRAINT CK_Rooms_Area
        CHECK (Area > 0),

    CONSTRAINT CK_Rooms_Status
        CHECK (Status IN (
            N'Pending',
            N'Approved',
            N'Rejected',
            N'Rented'
        )),

    CONSTRAINT FK_Rooms_Categories
        FOREIGN KEY (CategoryId)
        REFERENCES Categories(CategoryId),

    CONSTRAINT FK_Rooms_AspNetUsers
        FOREIGN KEY (LandlordId)
        REFERENCES AspNetUsers(Id)
);

CREATE TABLE Favorites (
    FavoriteId INT IDENTITY(1,1) PRIMARY KEY,
    TenantId NVARCHAR(450) NOT NULL,
    RoomId INT NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Favorites_AspNetUsers
        FOREIGN KEY (TenantId)
        REFERENCES AspNetUsers(Id),

    CONSTRAINT FK_Favorites_Rooms
        FOREIGN KEY (RoomId)
        REFERENCES Rooms(RoomId),

    CONSTRAINT UQ_Favorites_Tenant_Room
        UNIQUE (TenantId, RoomId)
);

CREATE TABLE Contacts (
    ContactId INT IDENTITY(1,1) PRIMARY KEY,
    RoomId INT NOT NULL,
    SenderName NVARCHAR(150) NOT NULL,
    SenderPhone NVARCHAR(20) NOT NULL,
    Message NVARCHAR(500),
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Contacts_Rooms
        FOREIGN KEY (RoomId)
        REFERENCES Rooms(RoomId)
);

INSERT INTO Categories (CategoryName, Type)
VALUES
    (N'Quận Cầu Giấy', N'Location'),
    (N'Quận Đống Đa', N'Location'),
    (N'Quận Thanh Xuân', N'Location'),
    (N'Phòng trọ bình dân', N'RoomType'),
    (N'Phòng trọ khép kín', N'RoomType'),
    (N'Căn hộ mini', N'RoomType');

	USE NhaTroDB;
GO

-- Mo rong schema cho cac man hinh ho so, chi phi phong va nhieu anh.
ALTER TABLE AspNetUsers ADD PhoneNumber NVARCHAR(20) NULL, AvatarUrl NVARCHAR(500) NULL, DateOfBirth DATE NULL, Address NVARCHAR(300) NULL;
ALTER TABLE Rooms ADD ElectricityPrice DECIMAL(18,2) NOT NULL CONSTRAINT DF_Rooms_ElectricityPrice DEFAULT(0), WaterPrice DECIMAL(18,2) NOT NULL CONSTRAINT DF_Rooms_WaterPrice DEFAULT(0), ServiceFee DECIMAL(18,2) NOT NULL CONSTRAINT DF_Rooms_ServiceFee DEFAULT(0), LocationCategoryId INT NULL, RoomTypeCategoryId INT NULL, Amenities NVARCHAR(500) NULL;
UPDATE r SET LocationCategoryId = c.CategoryId FROM Rooms r INNER JOIN Categories c ON c.CategoryId = r.CategoryId AND c.Type = 'Location';
UPDATE r SET RoomTypeCategoryId = c.CategoryId FROM Rooms r INNER JOIN Categories c ON c.CategoryId = r.CategoryId AND c.Type = 'RoomType';
ALTER TABLE Rooms ADD CONSTRAINT FK_Rooms_LocationCategory FOREIGN KEY(LocationCategoryId) REFERENCES Categories(CategoryId);
ALTER TABLE Rooms ADD CONSTRAINT FK_Rooms_RoomTypeCategory FOREIGN KEY(RoomTypeCategoryId) REFERENCES Categories(CategoryId);
ALTER TABLE Contacts ADD SenderEmail NVARCHAR(256) NULL, SenderUserId NVARCHAR(450) NULL;

CREATE TABLE RoomImages (
    RoomImageId INT IDENTITY(1,1) PRIMARY KEY,
    RoomId INT NOT NULL,
    ImageUrl NVARCHAR(500) NOT NULL,
    DisplayOrder INT NOT NULL DEFAULT(0),
    CONSTRAINT FK_RoomImages_Rooms FOREIGN KEY(RoomId) REFERENCES Rooms(RoomId) ON DELETE CASCADE
);
CREATE TABLE RoomViews (
    RoomViewId BIGINT IDENTITY(1,1) PRIMARY KEY,
    RoomId INT NOT NULL,
    ViewedAt DATETIME NOT NULL DEFAULT(GETDATE()),
    CONSTRAINT FK_RoomViews_Rooms FOREIGN KEY(RoomId) REFERENCES Rooms(RoomId) ON DELETE CASCADE
);

CREATE INDEX IX_RoomViews_ViewedAt ON RoomViews(ViewedAt);
ALTER TABLE Contacts ADD CONSTRAINT FK_Contacts_AspNetUsers_SenderUserId FOREIGN KEY(SenderUserId) REFERENCES AspNetUsers(Id) ON DELETE SET NULL;

	USE NhaTroDB;
GO


SELECT * FROM AspNetUsers;
SELECT * FROM Categories;
SELECT * FROM Rooms;
SELECT * FROM Favorites;
SELECT * FROM Contacts;

SELECT RoomId, Title, Status
FROM Rooms;

SELECT DB_NAME() AS DatabaseDangKiemTra;

SELECT COUNT(*) AS SoLuongPhong
FROM dbo.Rooms;

SELECT COUNT(*) AS SoLuongDanhMuc
FROM dbo.Categories;

SELECT Email, Role
FROM dbo.AspNetUsers
WHERE Email IN (
    'chutro@nht.local',
    'admin@nht.local'
);

SELECT RoomId, Title, Status, Price, LandlordId
FROM dbo.Rooms
ORDER BY CreatedAt DESC;

SELECT RoomId, Title, CategoryId, LocationCategoryId,
       RoomTypeCategoryId, Status
FROM dbo.Rooms;

SELECT CategoryId, CategoryName, Type
FROM dbo.Categories
ORDER BY Type, CategoryId;

SELECT COUNT(*) AS SoLuongPhong FROM dbo.Rooms;

SELECT Title, Price, Status
FROM dbo.Rooms
ORDER BY CreatedAt DESC;

WITH RoomImages AS
(
    SELECT
        RoomId,
        ROW_NUMBER() OVER (ORDER BY RoomId) AS RowNum
    FROM dbo.Rooms
)
UPDATE r
SET ImageUrl = CASE ri.RowNum
    WHEN 1 THEN 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1200&q=85'
    WHEN 2 THEN 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1200&q=85'
    WHEN 3 THEN 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=1200&q=85'
    WHEN 4 THEN 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=1200&q=85'
    WHEN 5 THEN 'https://images.unsplash.com/photo-1484154218962-a197022b5858?auto=format&fit=crop&w=1200&q=85'
    WHEN 6 THEN 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?auto=format&fit=crop&w=1200&q=85'
END
FROM dbo.Rooms r
INNER JOIN RoomImages ri ON r.RoomId = ri.RoomId
WHERE ri.RowNum <= 6;

USE NhaTroDB;
GO

IF COL_LENGTH('dbo.Rooms', 'LocationCategoryId') IS NULL
BEGIN
    ALTER TABLE dbo.Rooms
    ADD LocationCategoryId INT NULL;
END;
GO

IF COL_LENGTH('dbo.Rooms', 'RoomTypeCategoryId') IS NULL
BEGIN
    ALTER TABLE dbo.Rooms
    ADD RoomTypeCategoryId INT NULL;
END;
GO

USE NhaTroDB;
GO

SELECT
    COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'Rooms'
  AND COLUMN_NAME IN (
      'LocationCategoryId',
      'RoomTypeCategoryId'
  );
GO




USE NhaTroDB;
GO

SELECT CategoryId, CategoryName, Type
FROM dbo.Categories
ORDER BY Type, CategoryId;
GO

SELECT
    RoomId,
    Title,
    CategoryId,
    LocationCategoryId,
    RoomTypeCategoryId,
    Status
FROM dbo.Rooms
ORDER BY RoomId;
GO

USE NhaTroDB;
GO

SELECT COUNT(*) AS SoLuongPhong
FROM dbo.Rooms;

SELECT COUNT(*) AS SoLuongDanhMuc
FROM dbo.Categories;

SELECT CategoryId, CategoryName, Type
FROM dbo.Categories
ORDER BY Type, CategoryId;
GO


USE NhaTroDB;
GO

IF NOT EXISTS (
    SELECT 1 FROM dbo.AspNetUsers
    WHERE Id = N'SAMPLE_LANDLORD_01'
)
BEGIN
    INSERT INTO dbo.AspNetUsers
        (Id, UserName, Email, PasswordHash, FullName, Role, Status)
    VALUES
        (N'SAMPLE_LANDLORD_01',
         N'chutro_mau1',
         N'chutro1@example.com',
         NULL,
         N'Nguyễn Văn Nam',
         N'Landlord',
         N'Active');
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.AspNetUsers
    WHERE Id = N'SAMPLE_LANDLORD_02'
)
BEGIN
    INSERT INTO dbo.AspNetUsers
        (Id, UserName, Email, PasswordHash, FullName, Role, Status)
    VALUES
        (N'SAMPLE_LANDLORD_02',
         N'chutro_mau2',
         N'chutro2@example.com',
         NULL,
         N'Trần Thị Hoa',
         N'Landlord',
         N'Active');
END;
GO


USE NhaTroDB;
GO

IF NOT EXISTS (
    SELECT 1 FROM dbo.Rooms
    WHERE Title = N'Phòng trọ sinh viên gần trường'
)
BEGIN
    INSERT INTO dbo.Rooms
    (
        Title, Price, Area, Address, Description, ImageUrl,
        Status, RejectionReason, CategoryId, LandlordId,
        LocationCategoryId, RoomTypeCategoryId
    )
    VALUES
    (
        N'Phòng trọ sinh viên gần trường',
        1800000, 20, N'Quận Cầu Giấy, Hà Nội',
        N'Phòng sạch sẽ, phù hợp sinh viên, có chỗ để xe.',
        N'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
        N'Approved', NULL, 1, N'SAMPLE_LANDLORD_01',
        1, 4
    );
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.Rooms
    WHERE Title = N'Phòng trọ khép kín Đống Đa'
)
BEGIN
    INSERT INTO dbo.Rooms
    (
        Title, Price, Area, Address, Description, ImageUrl,
        Status, RejectionReason, CategoryId, LandlordId,
        LocationCategoryId, RoomTypeCategoryId
    )
    VALUES
    (
        N'Phòng trọ khép kín Đống Đa',
        2800000, 25, N'Quận Đống Đa, Hà Nội',
        N'Phòng có nhà vệ sinh riêng, khu vực an ninh.',
        N'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85',
        N'Approved', NULL, 2, N'SAMPLE_LANDLORD_02',
        2, 5
    );
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.Rooms
    WHERE Title = N'Căn hộ mini Thanh Xuân'
)
BEGIN
    INSERT INTO dbo.Rooms
    (
        Title, Price, Area, Address, Description, ImageUrl,
        Status, RejectionReason, CategoryId, LandlordId,
        LocationCategoryId, RoomTypeCategoryId
    )
    VALUES
    (
        N'Căn hộ mini Thanh Xuân',
        4500000, 35, N'Quận Thanh Xuân, Hà Nội',
        N'Căn hộ mini rộng rãi, phù hợp người đi làm.',
        N'https://images.unsplash.com/photo-1493809842364-78817add7ffb',
        N'Approved', NULL, 3, N'SAMPLE_LANDLORD_01',
        3, 6
    );
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.Rooms
    WHERE Title = N'Phòng trọ giá rẻ Cầu Giấy'
)
BEGIN
    INSERT INTO dbo.Rooms
    (
        Title, Price, Area, Address, Description, ImageUrl,
        Status, RejectionReason, CategoryId, LandlordId,
        LocationCategoryId, RoomTypeCategoryId
    )
    VALUES
    (
        N'Phòng trọ giá rẻ Cầu Giấy',
        1500000, 18, N'Quận Cầu Giấy, Hà Nội',
        N'Phòng nhỏ gọn, tiết kiệm chi phí thuê.',
        N'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688',
        N'Approved', NULL, 1, N'SAMPLE_LANDLORD_02',
        1, 4
    );
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.Rooms
    WHERE Title = N'Phòng khép kín Thanh Xuân'
)
BEGIN
    INSERT INTO dbo.Rooms
    (
        Title, Price, Area, Address, Description, ImageUrl,
        Status, RejectionReason, CategoryId, LandlordId,
        LocationCategoryId, RoomTypeCategoryId
    )
    VALUES
    (
        N'Phòng khép kín Thanh Xuân',
        3200000, 28, N'Quận Thanh Xuân, Hà Nội',
        N'Phòng khép kín, thuận tiện đi lại.',
        N'https://images.unsplash.com/photo-1484154218962-a197022b5858',
        N'Approved', NULL, 3, N'SAMPLE_LANDLORD_01',
        3, 5
    );
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.Rooms
    WHERE Title = N'Căn hộ mini Đống Đa'
)
BEGIN
    INSERT INTO dbo.Rooms
    (
        Title, Price, Area, Address, Description, ImageUrl,
        Status, RejectionReason, CategoryId, LandlordId,
        LocationCategoryId, RoomTypeCategoryId
    )
    VALUES
    (
        N'Căn hộ mini Đống Đa',
        5000000, 40, N'Quận Đống Đa, Hà Nội',
        N'Căn hộ diện tích rộng, phù hợp người đi làm.',
        N'https://images.unsplash.com/photo-1497366754035-f200968a6e72',
        N'Approved', NULL, 2, N'SAMPLE_LANDLORD_02',
        2, 6
    );
END;
GO


USE NhaTroDB;
GO

SELECT
    RoomId,
    Title,
    Price,
    Area,
    Address,
    Status,
    CategoryId,
    LocationCategoryId,
    RoomTypeCategoryId,
    LandlordId
FROM dbo.Rooms
ORDER BY RoomId;
GO

SELECT COUNT(*) AS SoLuongPhong
FROM dbo.Rooms;
GO


USE NhaTroDB;
GO

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'Rooms'
ORDER BY ORDINAL_POSITION;
GO


-- Bổ sung thêm Amenities,ElectricityPrice,ServiceFee,WaterPrice

USE NhaTroDB;
GO

IF COL_LENGTH('dbo.Rooms', 'Amenities') IS NULL
BEGIN
    ALTER TABLE dbo.Rooms
    ADD Amenities NVARCHAR(500) NULL;
END;
GO

IF COL_LENGTH('dbo.Rooms', 'ElectricityPrice') IS NULL
BEGIN
    ALTER TABLE dbo.Rooms
    ADD ElectricityPrice DECIMAL(18,2) NOT NULL
        CONSTRAINT DF_Rooms_ElectricityPrice DEFAULT (0);
END;
GO

IF COL_LENGTH('dbo.Rooms', 'ServiceFee') IS NULL
BEGIN
    ALTER TABLE dbo.Rooms
    ADD ServiceFee DECIMAL(18,2) NOT NULL
        CONSTRAINT DF_Rooms_ServiceFee DEFAULT (0);
END;
GO

IF COL_LENGTH('dbo.Rooms', 'WaterPrice') IS NULL
BEGIN
    ALTER TABLE dbo.Rooms
    ADD WaterPrice DECIMAL(18,2) NOT NULL
        CONSTRAINT DF_Rooms_WaterPrice DEFAULT (0);
END;
GO


USE NhaTroDB;
GO

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'Rooms'
  AND COLUMN_NAME IN (
      'Amenities',
      'ElectricityPrice',
      'ServiceFee',
      'WaterPrice'
  )
ORDER BY COLUMN_NAME;
GO