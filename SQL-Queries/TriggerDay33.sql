SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE dbo.usp_RunCursorDemo
(
@LowStockThreshold INT = 30,     -- for reorder cursor
@FashionIncreasePct DECIMAL(5,2) = 5.0   -- percent increase
)
AS
BEGIN
SET NOCOUNT ON;

------------------------------------------------------------
-- 1) Setup Tables
------------------------------------------------------------

IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL
    DROP TABLE dbo.Products;

CREATE TABLE dbo.Products
(
    ProductId     INT IDENTITY(1,1) PRIMARY KEY,
    ProductName   VARCHAR(100) NOT NULL,
    Category      VARCHAR(50)  NOT NULL,
    Price         DECIMAL(10,2) NOT NULL CHECK (Price > 0),
    StockQty      INT NOT NULL CHECK (StockQty >= 0),
    IsActive      BIT NOT NULL DEFAULT 1,
    CreatedAt     DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);

INSERT INTO dbo.Products (ProductName, Category, Price, StockQty)
VALUES
('Wireless Mouse', 'Electronics', 799.00, 50),
('Mechanical Keyboard', 'Electronics', 2499.00, 25),
('Running Shoes', 'Fashion', 1899.00, 40),
('Water Bottle', 'Fitness', 399.00, 120),
('Laptop Backpack', 'Accessories', 1499.00, 35),
('USB-C Cable', 'Electronics', 299.00, 15),
('Gym Gloves', 'Fitness', 499.00, 28);

------------------------------------------------------------
IF OBJECT_ID('dbo.ReorderLog', 'U') IS NOT NULL
    DROP TABLE dbo.ReorderLog;

CREATE TABLE dbo.ReorderLog
(
    LogId      INT IDENTITY(1,1) PRIMARY KEY,
    ProductId  INT NOT NULL,
    Message    VARCHAR(200) NOT NULL,
    CreatedAt  DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);

------------------------------------------------------------
-- 2.1 Cursor Beginner
------------------------------------------------------------
DECLARE @ProductId INT;
DECLARE @ProductName VARCHAR(100);
DECLARE @Price DECIMAL(10,2);

DECLARE curProducts CURSOR FAST_FORWARD FOR
    SELECT ProductId, ProductName, Price
    FROM dbo.Products
    ORDER BY ProductId;

OPEN curProducts;
FETCH NEXT FROM curProducts INTO @ProductId, @ProductName, @Price;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'ProductId=' + CAST(@ProductId AS VARCHAR(10))
        + ' | Name=' + @ProductName
        + ' | Price=' + CAST(@Price AS VARCHAR(20));

    FETCH NEXT FROM curProducts INTO @ProductId, @ProductName, @Price;
END

CLOSE curProducts;
DEALLOCATE curProducts;

------------------------------------------------------------
-- 2.2 Cursor Intermediate
------------------------------------------------------------
TRUNCATE TABLE dbo.ReorderLog;

DECLARE @StockQty INT;

DECLARE curLowStock CURSOR FAST_FORWARD FOR
    SELECT ProductId, ProductName, StockQty
    FROM dbo.Products
    WHERE StockQty < @LowStockThreshold
    ORDER BY StockQty;

OPEN curLowStock;
FETCH NEXT FROM curLowStock INTO @ProductId, @ProductName, @StockQty;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO dbo.ReorderLog(ProductId, Message)
    VALUES
    (
        @ProductId,
        'Reorder needed for ' + @ProductName +
        ' (Stock=' + CAST(@StockQty AS VARCHAR(10)) + ')'
    );

    FETCH NEXT FROM curLowStock INTO @ProductId, @ProductName, @StockQty;
END

CLOSE curLowStock;
DEALLOCATE curLowStock;

------------------------------------------------------------
-- 2.3 Cursor Advanced (Transaction)
------------------------------------------------------------
IF OBJECT_ID('dbo.PriceChangeLog', 'U') IS NOT NULL
    DROP TABLE dbo.PriceChangeLog;

CREATE TABLE dbo.PriceChangeLog
(
    LogId       INT IDENTITY(1,1) PRIMARY KEY,
    ProductId   INT NOT NULL,
    OldPrice    DECIMAL(10,2) NOT NULL,
    NewPrice    DECIMAL(10,2) NOT NULL,
    ChangedAt   DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);

DECLARE @OldPrice DECIMAL(10,2);
DECLARE @NewPrice DECIMAL(10,2);

DECLARE curFashion CURSOR FAST_FORWARD FOR
    SELECT ProductId, Price
    FROM dbo.Products
    WHERE Category = 'Fashion';

BEGIN TRY
    BEGIN TRAN;

    OPEN curFashion;
    FETCH NEXT FROM curFashion INTO @ProductId, @OldPrice;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @NewPrice = ROUND(@OldPrice * (1 + @FashionIncreasePct/100), 2);

        UPDATE dbo.Products
        SET Price = @NewPrice
        WHERE ProductId = @ProductId;

        INSERT INTO dbo.PriceChangeLog(ProductId, OldPrice, NewPrice)
        VALUES (@ProductId, @OldPrice, @NewPrice);

        FETCH NEXT FROM curFashion INTO @ProductId, @OldPrice;
    END

    CLOSE curFashion;
    DEALLOCATE curFashion;

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF CURSOR_STATUS('global','curFashion') >= -1
    BEGIN
        CLOSE curFashion;
        DEALLOCATE curFashion;
    END

    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    THROW;
END CATCH;

------------------------------------------------------------
-- Final Outputs
------------------------------------------------------------
SELECT * FROM dbo.Products;
SELECT * FROM dbo.ReorderLog;
SELECT * FROM dbo.PriceChangeLog;


END
GO

EXEC dbo.usp_RunCursorDemo;


INSERT INTO sales.customers
                  (first_name, last_name, phone, email, street, state, city, zip_code)
VALUES ('fvbg', 'v b', '1234567890', 'sdfbg', 'sdfg', 'dfg', 'dvfdb', '5000')
select * from [dbo].[LogTable];