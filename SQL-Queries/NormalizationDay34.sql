-- Clean old tables if re-running
IF OBJECT_ID('dbo.OrderItems', 'U') IS NOT NULL DROP TABLE dbo.OrderItems;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;
GO

CREATE TABLE dbo.Customers
(
    CustomerId     INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName   VARCHAR(100) NOT NULL,
    CustomerPhone  VARCHAR(20)  NOT NULL,
    CustomerCity   VARCHAR(50)  NOT NULL
);

CREATE TABLE dbo.Orders
(
    OrderId     INT PRIMARY KEY,
    OrderDate   DATE NOT NULL,
    CustomerId  INT NOT NULL,
    CONSTRAINT FK_Orders_Customers
      FOREIGN KEY (CustomerId) REFERENCES dbo.Customers(CustomerId)
);

CREATE TABLE dbo.Products
(
    ProductId   INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL UNIQUE,
    ListPrice   DECIMAL(10,2) NOT NULL
);

CREATE TABLE dbo.OrderItems
(
    OrderId   INT NOT NULL,
    ProductId INT NOT NULL,
    Qty       INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_OrderItems PRIMARY KEY (OrderId, ProductId),
    CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderId) REFERENCES dbo.Orders(OrderId),
    CONSTRAINT FK_OrderItems_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId)
);
GO


-- Customers
INSERT INTO dbo.Customers(CustomerName, CustomerPhone, CustomerCity)
VALUES
('Arjun Kumar', '9876543210', 'Chennai'),
('Meera Iyer',  '9123456780', 'Bengaluru');

-- Products
INSERT INTO dbo.Products(ProductName, ListPrice)
VALUES
('Mouse', 500.00),
('Keyboard', 2000.00),
('Laptop Bag', 1200.00),
('Laptop Stand', 1600.00),
('USB Hub', 1000.00);

-- Orders (link to Customers by CustomerId)
-- (Assume Arjun=1, Meera=2 from inserts above)
INSERT INTO dbo.Orders(OrderId, OrderDate, CustomerId)
VALUES
(101, '2026-02-01', 1),
(102, '2026-02-02', 1),
(103, '2026-02-02', 2);

-- OrderItems (ONE product per row ✅)
-- Order 101: Mouse + Keyboard
INSERT INTO dbo.OrderItems(OrderId, ProductId, Qty, UnitPrice)
VALUES
(101, (SELECT ProductId FROM dbo.Products WHERE ProductName='Mouse'), 1, 500.00),
(101, (SELECT ProductId FROM dbo.Products WHERE ProductName='Keyboard'), 1, 2000.00);

-- Order 102: Laptop Bag
INSERT INTO dbo.OrderItems(OrderId, ProductId, Qty, UnitPrice)
VALUES
(102, (SELECT ProductId FROM dbo.Products WHERE ProductName='Laptop Bag'), 1, 1200.00);

-- Order 103: Mouse + Laptop Stand + USB Hub
INSERT INTO dbo.OrderItems(OrderId, ProductId, Qty, UnitPrice)
VALUES
(103, (SELECT ProductId FROM dbo.Products WHERE ProductName='Mouse'), 1, 500.00),
(103, (SELECT ProductId FROM dbo.Products WHERE ProductName='Laptop Stand'), 1, 1600.00),
(103, (SELECT ProductId FROM dbo.Products WHERE ProductName='USB Hub'), 1, 1000.00);


SELECT
    o.OrderId,
    o.OrderDate,
    c.CustomerName,
    c.CustomerPhone,
    c.CustomerCity,
    p.ProductName,
    oi.Qty,
    oi.UnitPrice,
    (oi.Qty * oi.UnitPrice) AS LineTotal
FROM dbo.Orders o
JOIN dbo.Customers c ON c.CustomerId = o.CustomerId
JOIN dbo.OrderItems oi ON oi.OrderId = o.OrderId
JOIN dbo.Products p ON p.ProductId = oi.ProductId
ORDER BY o.OrderId;