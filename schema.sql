-- =========================================================
-- E-Commerce Data Warehouse Schema
-- PostgreSQL DDL
-- =========================================================

CREATE TABLE IF NOT EXISTS DimDate (
    DateKey INT PRIMARY KEY,
    Date DATE NOT NULL,
    Year INT NOT NULL,
    Quarter INT NOT NULL CHECK (Quarter BETWEEN 1 AND 4),
    Month VARCHAR(20) NOT NULL,
    MonthNo INT NOT NULL CHECK (MonthNo BETWEEN 1 AND 12)
);

CREATE TABLE IF NOT EXISTS DimProduct (
    ProductKey INT PRIMARY KEY,
    SKU VARCHAR(50) NOT NULL UNIQUE,
    ProductName VARCHAR(200) NOT NULL,
    Category VARCHAR(100) NOT NULL,
    CostOfGoodsSold DECIMAL(18,2) NOT NULL CHECK (CostOfGoodsSold >= 0),
    UnitPrice DECIMAL(18,2) NOT NULL CHECK (UnitPrice >= 0),
    ProfitMargin DECIMAL(8,4) NOT NULL CHECK (ProfitMargin BETWEEN 0 AND 1)
);

CREATE TABLE IF NOT EXISTS DimCustomer (
    CustomerKey INT PRIMARY KEY,
    CustomerID VARCHAR(50) NOT NULL UNIQUE,
    Region VARCHAR(50) NOT NULL,
    Country VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS FactSales (
    OrderID VARCHAR(50) PRIMARY KEY,
    OrderDateKey INT NOT NULL,
    CustomerKey INT NOT NULL,
    ProductKey INT NOT NULL,
    CustomerSegment VARCHAR(20) NOT NULL CHECK (CustomerSegment IN ('New', 'Returning')),
    OrderQuantity INT NOT NULL CHECK (OrderQuantity > 0),
    SalesAmount DECIMAL(18,2) NOT NULL CHECK (SalesAmount >= 0),
    CostOfGoodsSold DECIMAL(18,2) NOT NULL CHECK (CostOfGoodsSold >= 0),
    FulfillmentStatus VARCHAR(20) NOT NULL CHECK (FulfillmentStatus IN ('Shipped', 'Pending', 'Cancelled')),

    CONSTRAINT fk_factsales_dimdate
        FOREIGN KEY (OrderDateKey)
        REFERENCES DimDate(DateKey),

    CONSTRAINT fk_factsales_dimcustomer
        FOREIGN KEY (CustomerKey)
        REFERENCES DimCustomer(CustomerKey),

    CONSTRAINT fk_factsales_dimproduct
        FOREIGN KEY (ProductKey)
        REFERENCES DimProduct(ProductKey)
);

CREATE INDEX idx_dimdate_year_month
    ON DimDate (Year, MonthNo);

CREATE INDEX idx_dimproduct_category
    ON DimProduct (Category);

CREATE INDEX idx_dimcustomer_region_country
    ON DimCustomer (Region, Country);

CREATE INDEX idx_factsales_orderdatekey
    ON FactSales (OrderDateKey);

CREATE INDEX idx_factsales_customerkey
    ON FactSales (CustomerKey);

CREATE INDEX idx_factsales_productkey
    ON FactSales (ProductKey);

CREATE INDEX idx_factsales_segment
    ON FactSales (CustomerSegment);

CREATE INDEX idx_factsales_fulfillmentstatus
    ON FactSales (FulfillmentStatus);
