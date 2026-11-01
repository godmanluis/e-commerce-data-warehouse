-- =========================================================
-- E-Commerce Reporting Layer
-- =========================================================

CREATE OR REPLACE VIEW vw_sales_reporting AS
SELECT
    f."OrderID",
    d."Date",
    d."Year",
    d."Quarter",
    d."Month",
    d."MonthNo",
    c."CustomerKey",
    c."CustomerID",
    c."Region",
    c."Country",
    p."ProductKey",
    p."SKU",
    p."ProductName",
    p."Category",
    p."CostOfGoodsSold" AS "ProductCostOfGoodsSold",
    p."UnitPrice",
    p."ProfitMargin",
    f."CustomerSegment",
    f."OrderQuantity",
    f."SalesAmount",
    f."CostOfGoodsSold" AS "FactCostOfGoodsSold",
    f."FulfillmentStatus",
    (f."SalesAmount" - f."CostOfGoodsSold") AS "GrossProfit"
FROM public."FactSales" f
LEFT JOIN public."DimDate" d
    ON f."OrderDateKey" = d."DateKey"
LEFT JOIN public."DimCustomer" c
    ON f."CustomerKey" = c."CustomerKey"
LEFT JOIN public."DimProduct" p
    ON f."ProductKey" = p."ProductKey";

-- Revenue summary
SELECT
    SUM("SalesAmount") AS "TotalRevenue",
    SUM("GrossProfit") AS "GrossProfit",
    ROUND(
        CASE
            WHEN SUM("SalesAmount") = 0 THEN 0
            ELSE SUM("GrossProfit") / SUM("SalesAmount")
        END * 100, 2
    ) AS "GrossMarginPercent"
FROM vw_sales_reporting;

-- Monthly revenue trend
SELECT
    "Year",
    "Month",
    "MonthNo",
    SUM("SalesAmount") AS "TotalRevenue",
    SUM("GrossProfit") AS "GrossProfit"
FROM vw_sales_reporting
GROUP BY "Year", "Month", "MonthNo"
ORDER BY "Year", "MonthNo";

-- Category performance
SELECT
    "Category",
    SUM("SalesAmount") AS "TotalRevenue",
    SUM("GrossProfit") AS "GrossProfit",
    ROUND(
        CASE
            WHEN SUM("SalesAmount") = 0 THEN 0
            ELSE SUM("GrossProfit") / SUM("SalesAmount")
        END * 100, 2
    ) AS "GrossMarginPercent",
    COUNT(DISTINCT "OrderID") AS "Orders"
FROM vw_sales_reporting
GROUP BY "Category"
ORDER BY "TotalRevenue" DESC;

-- Regional revenue
SELECT
    "Region",
    "Country",
    SUM("SalesAmount") AS "TotalRevenue",
    SUM("GrossProfit") AS "GrossProfit",
    COUNT(DISTINCT "OrderID") AS "Orders"
FROM vw_sales_reporting
GROUP BY "Region", "Country"
ORDER BY "TotalRevenue" DESC;

-- Customer segment mix
SELECT
    "CustomerSegment",
    COUNT(DISTINCT "CustomerKey") AS "Customers",
    SUM("SalesAmount") AS "Revenue",
    ROUND(
        CASE
            WHEN SUM("SalesAmount") = 0 THEN 0
            ELSE SUM("GrossProfit") / SUM("SalesAmount")
        END * 100, 2
    ) AS "GrossMarginPercent"
FROM vw_sales_reporting
GROUP BY "CustomerSegment"
ORDER BY "Revenue" DESC;

-- Fulfillment rate
SELECT
    "FulfillmentStatus",
    COUNT(*) AS "Orders",
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS "PercentOfOrders"
FROM vw_sales_reporting
GROUP BY "FulfillmentStatus";

-- Top products
SELECT
    "ProductName",
    "Category",
    SUM("SalesAmount") AS "TotalRevenue",
    SUM("GrossProfit") AS "GrossProfit",
    ROUND(
        CASE
            WHEN SUM("SalesAmount") = 0 THEN 0
            ELSE SUM("GrossProfit") / SUM("SalesAmount")
        END * 100, 2
    ) AS "GrossMarginPercent"
FROM vw_sales_reporting
GROUP BY "ProductName", "Category"
ORDER BY "TotalRevenue" DESC
LIMIT 15;

-- Data quality checks
SELECT
    COUNT(*) AS "duplicate_orders"
FROM (
    SELECT "OrderID"
    FROM vw_sales_reporting
    GROUP BY "OrderID"
    HAVING COUNT(*) > 1
) d;

SELECT *
FROM vw_sales_reporting
WHERE "SalesAmount" < 0
   OR "CostOfGoodsSold" < 0
   OR "OrderQuantity" <= 0
LIMIT 50;
