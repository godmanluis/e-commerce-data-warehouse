# E-Commerce Data Warehouse & Revenue Optimization Dashboard

A portfolio-ready analytics project that builds a star-schema data warehouse for e-commerce sales, creates a SQL reporting layer, and supports an executive Power BI dashboard for operational and revenue insight.

## 📊 Live Project Links


https://messy-innocent-054.notion.site/Engineering-Portfolio-Emmanuel-G-LOUIS-c4da9e4903ca42c2b0ecbe02ee15dfa0



## 📌 Executive Summary

This project establishes a scalable e-commerce analytics foundation designed to transform transactional sales data into a structured, decision-ready data warehouse. By organizing source sales information into a star schema and layering a reporting model on top, the solution provides leadership with visibility into revenue, customer behavior, product profitability, and operational performance.

The warehouse supports:

- Revenue and margin monitoring
- Customer segment analysis
- Product profitability assessment
- Regional sales performance analysis
- Fulfillment and operational KPI tracking

The architecture is designed to be easy to extend, clean to understand, and suitable for modern BI consumption in Power BI.

---

## 🏗️ Data Architecture

The schema follows a classic star model with one fact table and multiple dimensions.

```text
                       +---------------------+
                       | DimCustomer         |
                       +---------------------+
                       | CustomerKey (PK)    |
                       | CustomerID          |
                       | Region              |
                       | Country             |
                       +----------+----------+
                                  |
                                  |
                         1:N   v
                       +---------------------+
                       | FactSales           |
                       +---------------------+
                       | OrderID             |
                       | OrderDateKey (FK)   |
                       | CustomerKey (FK)    |
                       | ProductKey (FK)     |
                       | CustomerSegment     |
                       | OrderQuantity       |
                       | SalesAmount         |
                       | CostOfGoodsSold     |
                       | FulfillmentStatus   |
                       +----------+----------+
                                  |
                                  | 1:N
                                  v
                       +---------------------+
                       | DimDate             |
                       +---------------------+
                       | DateKey (PK)        |
                       | Date                |
                       | Year                |
                       | Quarter             |
                       | Month               |
                       | MonthNo             |
                       +---------------------+

                       +---------------------+
                       | DimProduct          |
                       +---------------------+
                       | ProductKey (PK)     |
                       | SKU                 |
                       | ProductName         |
                       | Category            |
                       | CostOfGoodsSold     |
                       | UnitPrice           |
                       | ProfitMargin        |
                       +---------------------+
```

### Dimension tables
- DimDate: time intelligence and fiscal grouping
- DimCustomer: customer segmentation and geography
- DimProduct: product catalog and pricing

### Fact table
- FactSales: transactional sales data at order-item level

---

## 📐 Data Dictionary

### DimDate
| Column | Description |
|---|---|
| DateKey | Integer key in YYYYMMDD format |
| Date | Full date |
| Year | Calendar year |
| Quarter | Calendar quarter |
| Month | Month name |
| MonthNo | Numeric month |

### DimCustomer
| Column | Description |
|---|---|
| CustomerKey | Surrogate key |
| CustomerID | Natural customer identifier |
| Region | Customer region |
| Country | Customer country |

### DimProduct
| Column | Description |
|---|---|
| ProductKey | Surrogate key |
| SKU | Product stock keeping unit |
| ProductName | Product name |
| Category | Product category |
| CostOfGoodsSold | Cost per unit |
| UnitPrice | Sales price per unit |
| ProfitMargin | Product margin percentage |

### FactSales
| Column | Description |
|---|---|
| OrderID | Unique sales order identifier |
| OrderDateKey | Date foreign key |
| CustomerKey | Customer foreign key |
| ProductKey | Product foreign key |
| CustomerSegment | New or Returning |
| OrderQuantity | Quantity ordered |
| SalesAmount | Revenue for the order line |
| CostOfGoodsSold | COGS associated with the order line |
| FulfillmentStatus | Shipped, Pending, or Cancelled |

---

## ⚙️ ETL & Data Generation

The project includes a Python generator that creates realistic mock data across a three-year period.

### Data generation logic
- 250 customers
- 50 products
- 8,000 order records
- Repeat customer patterns
- Realistic pricing logic
- Margin variation per product
- Date-based customer segmentation
- Fulfillment status mix

### Output files
- DimDate.csv
- DimProduct.csv
- DimCustomer.csv
- FactSales.csv

---

## 🧠 Business Use Cases

This warehouse enables analysis in several key business areas:

- Revenue trend monitoring
- Profitability analysis by product and category
- Customer segment and retention analysis
- Regional and country-level sales performance
- Operational performance via fulfillment reporting
- Executive KPI dashboards for leadership reviews

---

## 📊 Power BI Dashboard Blueprint

### Page 1: Executive Overview
KPI cards for:
- Total Revenue
- Gross Profit
- Gross Margin %
- Revenue YoY %
- Fulfillment Rate %

Visuals:
- Revenue trend by month
- Revenue by category
- New vs Returning customer mix
- Revenue by country/region
- Top products by revenue

### Page 2: Product & Margin Analysis
- Product-level contribution to revenue
- Gross margin by product and category
- COGS vs sales comparison
- Top margin opportunities

### Page 3: Customer Insights
- Revenue by customer segment
- New vs returning customer mix
- Geographic customer performance
- Customer value proxy by revenue and order count

### Page 4: Operations & Fulfillment
- Shipment performance by status
- Pending vs shipped transactions
- Regional fulfillment trends
- Order and fulfillment performance monitoring

---

## 🏎️ Key DAX Measures

```dax
Total Revenue = SUM(FactSales[SalesAmount])
```

```dax
Total COGS = SUM(FactSales[CostOfGoodsSold])
```

```dax
Gross Profit = [Total Revenue] - [Total COGS]
```

```dax
Gross Margin % =
DIVIDE([Gross Profit], [Total Revenue], 0)
```

```dax
Total Orders = DISTINCTCOUNT(FactSales[OrderID])
```

```dax
Average Order Value =
DIVIDE([Total Revenue], [Total Orders], 0)
```

```dax
Prior Year Revenue =
CALCULATE(
    [Total Revenue],
    SAMEPERIODLASTYEAR(DimDate[Date])
)
```

```dax
Revenue YoY % =
VAR CurrentRev = [Total Revenue]
VAR PastRev = [Prior Year Revenue]
RETURN
    IF(
        ISBLANK(PastRev),
        BLANK(),
        DIVIDE(CurrentRev - PastRev, PastRev, 0)
    )
```

```dax
Fulfillment Rate % =
DIVIDE(
    CALCULATE(
        COUNTROWS(FactSales),
        FactSales[FulfillmentStatus] = "Shipped"
    ),
    COUNTROWS(FactSales),
    0
)
```

---

## 🧾 SQL Reporting Layer

The reporting layer is built as a flattened view for analysis and Power BI consumption:

```sql
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
```

---

## 📈 Executive Insights

This dashboard enables stakeholders to:

- identify most profitable product lines
- evaluate growth against prior-period benchmarks
- measure customer retention versus new customer acquisition
- understand regional demand patterns
- monitor fulfillment quality and operational risks
- guide strategic pricing, merchandising, and inventory decisions

---

## ✅ Project Outcome

The final output is a clean, scalable analytics foundation that combines:

- a star schema warehouse
- realistic generated sales data
- SQL reporting layer
- Power BI dashboard foundation
- business-friendly executive insights

This project is well suited for portfolio presentation, analytics case studies, and strategic data storytelling.

---

## 🚀 Suggested Next Steps

1. Load the CSVs into PostgreSQL
2. Create the reporting view
3. Connect Power BI to the SQL database
4. Build the executive dashboard pages
5. Review dashboard metrics with business stakeholders
6. Present the project as a case study or portfolio asset

---

## 📁 Repository Contents

- `schema.sql` — PostgreSQL warehouse schema
- `reporting_view.sql` — reporting layer and analytical queries
- `dashboard_blueprint.md` — Power BI dashboard design
- `generate_mock_data.py` — mock e-commerce data generation
- `load_data_postgres.sql` — PostgreSQL CSV import configuration
- `README.md` — project overview and documentation

---

## 🧩 Project Impact

This project turns raw transactional sales data into a decision-ready analytics foundation. It supports executive reviews, product performance analysis, customer segmentation insights, and operational monitoring across revenue, margin, and fulfillment metrics.

Business applications include:
- revenue and profitability monitoring
- customer retention analysis
- product performance evaluation
- regional demand analysis
- fulfillment health tracking

This project is designed to showcase end-to-end analytics capability and is suitable for portfolio presentation, BI applications, and case studies.


https://messy-innocent-054.notion.site/Engineering-Portfolio-Emmanuel-G-LOUIS-c4da9e4903ca42c2b0ecbe02ee15dfa0


## 👤 Author

GitHub: @godmanluis
