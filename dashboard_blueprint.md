# Power BI Dashboard Blueprint

## Page 1: Executive Overview

### KPI Cards
- Total Revenue
- Gross Profit
- Gross Margin %
- Revenue YoY %
- Fulfillment Rate %

### Visuals
- Line Chart: Revenue by Month
- Bar Chart: Revenue by Category
- Donut Chart: New vs Returning Revenue
- Map: Revenue by Country / Region
- Matrix: Top Products by Revenue and Gross Margin

### Slicers
- Year
- Quarter
- Region
- Category
- Customer Segment
- Fulfillment Status

## Page 2: Product & Margin Analysis

### Visuals
- Matrix: ProductName, Category, Revenue, Gross Profit, Gross Margin %
- Bar Chart: Gross Profit by Product
- Clustered Bar: Revenue vs COGS by Product
- Table: Top margin opportunities

### Slicers
- Category
- Region
- Customer Segment

## Page 3: Customer Insights

### Visuals
- Bar Chart: Revenue by Region
- Donut Chart: New vs Returning Revenue
- Matrix: Revenue by Customer Segment and Region
- KPI Card: Revenue per Customer

### Slicers
- Region
- Year
- Product Category

## Page 4: Operations & Fulfillment

### Visuals
- Column Chart: Fulfillment Status by Month
- KPI Cards: Fulfillment Rate %, Total Orders, Pending Orders
- Bar Chart: Revenue by Fulfillment Status

### Slicers
- Region
- Category
- Month

## Core DAX Measures

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

## Executive Storytelling Summary
This dashboard communicates whether the business is growing, where profitability is strongest, how customer behavior is shifting, and whether operations are healthy. It gives leadership a clear picture of revenue performance, margin optimization opportunities, and fulfillment discipline.
