# Ecommerce Insights & Optimization

An interactive **Power BI business intelligence project** that analyzes e-commerce sales performance, product categories, shipping costs, and time-based trends to identify business opportunities and support data-driven decision-making.

## Project Overview

E-commerce businesses generate large volumes of transaction and product data. However, raw data alone does not explain which categories drive sales, where shipping costs create pressure, or how sales performance changes over time.

This project transforms e-commerce data into an interactive Power BI dashboard to help stakeholders understand sales contribution, compare category performance, investigate shipping-cost exposure, and identify opportunities for operational improvement.

The analysis focuses on three primary business questions:

- Which product categories and products contribute the most to recorded sales value?
- Which categories exhibit a high shipping-cost burden relative to sales?
- How does recorded sales activity change over time?

## Business Objectives

- Analyze overall sales performance using key performance indicators (KPIs).
- Identify top-performing product categories and products.
- Measure shipping costs relative to sales value.
- Investigate relationships between product attributes and freight costs.
- Examine monthly sales trends and category-level patterns.
- Translate analytical findings into practical business recommendations.
- Communicate results through an interactive, management-oriented dashboard.

## Tools & Technologies

- **Power BI Desktop** — Interactive dashboards and data visualization
- **DAX** — Measures, KPI calculations, ranking, percentage contribution, and time-based analysis
- **Power Query** — Data preparation, filtering, and data-type management
- **CSV** — Source data format

## Dataset Overview

The project uses a prepared e-commerce analytical dataset, `dashboard_data.csv`.

| Attribute | Details |
|---|---|
| Original records | 57,373 |
| Records included in the analysis period | 57,284 |
| Product categories | 74 |
| Distinct products | 21,629 |
| Main sales metric | Sum of the `price` field |
| Shipping metric | Sum of the `freight_value` field |
| Main analysis date | `ship_date`, used as a date proxy |

The source data contains sales-related, product, seller, shipping, and product-attribute fields. Records outside the defined analysis period were excluded using the `in_analysis_period` flag.

## Data Preparation & Modeling

The following preparation and modeling steps were performed:

1. Imported the CSV file into Power BI.
2. Filtered the data to records marked `in_analysis_period = TRUE`.
3. Reviewed and assigned appropriate data types to key fields.
4. Created a calendar table (`DimDate`) for time-based analysis.
5. Added year, month, month number, and month-year attributes.
6. Created an active one-to-many relationship between `DimDate[Date]` and `data[ship_date]`.
7. Developed reusable DAX measures for sales value, freight costs, order counts, line items, average line value, and freight-to-sales percentage.
8. Built category-level rankings, revenue contribution measures, and time-based calculations.

## Dashboard Pages

### 1. Executive Summary
Provides an overview of sales performance through KPI cards, a monthly sales trend, a Top 10 category chart, and interactive year and category filters.

![Overview](screenshots/1.png)

### 2. Category & Product Performance
Compares sales value by category, identifies top products, and presents a category scorecard with revenue contribution and rankings.

screenshots/2.png

### 3. Shipping Analysis
Examines freight-to-sales ratios across categories, investigates the relationship between product weight, price, and freight cost, and identifies products with high total freight charges.

### 4. Time Trends & Seasonality
Visualizes monthly sales trends, month-over-month changes, category-by-month performance, and time-based patterns.

screenshots/3.png

### 5. Insights & Actions
Summarizes the key findings, recommends potential optimization actions, and identifies measurable KPIs for further investigation.

screenshots/4.png

## Key Findings

The findings below are based on the supplied analysis-period data.

### 1. Sales value and freight exposure

- **Recorded sales value:** approximately R$6.88 million.
- **Total freight charges:** approximately R$1.15 million.
- **Freight-to-sales ratio:** approximately 16.65%.

Freight charges represent a material share of recorded sales value. This makes shipping efficiency an important area for further investigation.

### 2. Revenue concentration

The top five product categories contribute approximately **39.4%** of total recorded sales value, while the top ten contribute approximately **62.1%**.

This concentration suggests that product availability, assortment planning, and promotional decisions in leading categories deserve particular attention.

### 3. Leading categories

**Watches & Gifts** is the highest-revenue category in the supplied analysis, contributing approximately R$625,000, or 9.1% of total sales value.

**Health & Beauty** is another leading category, with approximately R$618,000 in recorded sales value.

### 4. Categories with elevated shipping burden

Several categories exhibit high freight-to-sales ratios:

- Electronics: approximately 31.7%.
- Office Furniture: approximately 25.8%.
- Furniture & Decor: approximately 23.6%.
- Housewares: approximately 23.0%.
- Bed/Bath/Table: approximately 19.8%.

These categories are candidates for closer review of packaging, carrier pricing, shipping terms, and minimum-order thresholds. Their ratios should be assessed alongside order volumes and other available operational variables.

### 5. Monthly sales patterns

May 2018 recorded the highest monthly sales value in the supplied analysis, at approximately R$567,000.

The monthly trend can help identify periods worth investigating for inventory and promotional planning. However, the available date field represents a shipping-deadline proxy rather than a confirmed order date, so these patterns should not be treated as definitive order-date seasonality.

### 6. Product attributes and freight

The supplied analysis reports a moderate positive association between product weight and freight cost (Spearman correlation approximately 0.45). Price and freight also show a positive association (approximately 0.44).

These relationships are exploratory and do not prove causation. Other factors, such as dimensions, destination, carrier, and shipping service level, may also influence freight charges.

## Business Recommendations

| Area | Recommended action | Suggested KPI |
|---|---|---|
| Shipping optimization | Investigate carrier pricing, packaging, and shipping thresholds for high-burden categories. | Freight-to-sales ratio |
| Category management | Protect availability and review promotion plans for leading categories. | Category revenue share and stock-out rate |
| Product strategy | Investigate the demand drivers of Watches & Gifts and Health & Beauty. | Sales value and campaign return |
| Time-based planning | Investigate the drivers behind observed monthly peaks before adjusting inventory plans. | Monthly sales value and stock availability |
| Data quality | Validate product identifiers and resolve unmatched product attributes during ingestion. | Unmatched-record rate |

These actions are proposed opportunities, not guaranteed savings. Their impact should be evaluated using before-and-after measurements and appropriate operational data.

## Key DAX Measures

The project uses reusable DAX measures, including:

- `Revenue` — Sum of the `price` field.
- `Freight Cost` — Sum of the `freight_value` field.
- `Orders` — Distinct count of `order_id`.
- `Line Items` — Count of records in the analytical table.
- `Avg Line Value` — Recorded sales value divided by line-item count.
- `Freight-to-Sales %` — Freight cost divided by recorded sales value.
- `Revenue Share %` — Category revenue as a proportion of revenue across categories.
- `Revenue Rank` — Category ranking by sales value.
- `Revenue MoM %` — Month-over-month change in recorded sales value.

## Limitations

The results should be interpreted with the following limitations in mind:

- **Sales value is not profit.** The dataset does not provide all required cost, discount, return, and margin information needed to calculate actual accounting profit.
- **Date limitation.** `ship_date` is a shipping-deadline proxy, not a confirmed order date.
- **Quantity limitation.** A dedicated quantity field is unavailable in the analytical dataset. Line-item counts should not automatically be interpreted as verified physical units sold.
- **Order-grain limitation.** The supplied extract reports each `order_id` as unique. Order-level metrics should be validated against the underlying source before being interpreted as representative transaction volume.
- **Product matching.** Approximately 820 analysis-period records have unmatched product attributes, limiting some category and weight analyses.
- **Correlation is not causation.** Associations between weight, price, and freight do not establish causal relationships.
- **Short time horizon.** The available period is insufficient to establish robust recurring seasonal patterns on its own.

## Conclusion

This project demonstrates how raw e-commerce data can be transformed into interactive business intelligence using Power BI and DAX.

The analysis identifies the categories contributing most to recorded sales value, quantifies shipping-cost exposure, investigates product characteristics associated with freight, and highlights monthly patterns that merit further investigation.

The main business takeaway is that **sales contribution and shipping efficiency should be evaluated together**. High-revenue categories may deserve continued commercial attention, while categories with elevated freight-to-sales ratios warrant closer operational review.

The dashboard provides a foundation for data-driven decisions, while the documented assumptions and limitations identify what additional information is needed for stronger profitability analysis.

## Repository Structure

A suggested structure for the repository is:

```text
Ecommerce_Insights_and_Optimization/
├── dashboard/
│   └── Ecommerce_Insights_and_Optimization.pbix
├── data/
│   └── dashboard_data.csv
├── report/
│   └── Ecommerce_Insights_and_Optimization_Final_Report.pdf
└── README.md
```

Add each file to the repository only if you intend to share it. If the source dataset cannot be redistributed, exclude it and document how authorized users can obtain it.

## How to Use

1. Clone or download this repository.
2. Open `dashboard/Ecommerce_Insights_and_Optimization.pbix` in Power BI Desktop.
3. If Power BI requests the source file, update the data source path to your local copy of `dashboard_data.csv`.
4. Refresh the data if the source file is available.
5. Explore the dashboard pages and use the available slicers to investigate different categories and time periods.
6. Refer to the final PDF report for detailed findings, recommendations, and limitations.

## Project Deliverables

- Interactive Power BI dashboard (`.pbix`)
- Final analytical report (`.pdf`)
- Data preparation and DAX-based KPI calculations
- Evidence-based findings and business recommendations

---

## Author

**Md Khaleel Ur Rahman**

Data Analytics | Business Intelligence | Power BI | DAX | Data Visualization
