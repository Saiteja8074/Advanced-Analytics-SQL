# Advanced SQL Analytics ─ Customer & Product Reports 📊

## 📌 Project Overview

This repository contains a comprehensive **Advanced Analytics SQL project** that builds robust, analytical views and reports from raw transactional data. It focuses on **customer behaviour**, **product performance**, and **time-based analytics**, helping stakeholders derive key insights and KPIs from business data.

## 📋 Description

This SQL analytics project delivers a set of consolidated views and analytical queries to interpret real business performance. It includes:

### 🧠 Core Reporting Features

#### **1. Customer Report**

A deep analytical view that:

* Gathers customer details such as name, age, and transaction history.
* Segments customers into *VIP*, *Regular*, and *New* categories.
* Groups customers by age bands.
* Aggregates key customer metrics:
  * Total orders
  * Total sales
  * Total quantity purchased
  * Total distinct products bought
  * Lifespan (in months)
* Calculates essential KPIs:
  * Recency (months since last order)
  * Average order value
  * Average monthly spend

All of this is exposed via the `gold.report_customers` view for reporting and downstream analytics.

#### **2. Product Report**

A comprehensive view that:

* Extracts product information including name, category, subcategory, and cost.
* Segments products based on revenue performance (*high*, *mid*, *low*).
* Aggregates product metrics:
  * Total orders
  * Total sales
  * Total quantity sold
  * Total distinct customers
  * Product lifespan
* Calculates product-level KPIs:
  * Recency (months since last sale)
  * Average order revenue
  * Average monthly revenue

Delivered as the `gold.report_product` view for easy analytics consumption.

### 📈 Time-Series & Trend Analysis

The repository also includes key analytical queries such as:

* **Change over time:** Total sales, customers, and quantities aggregated by year/month.
* **Running totals & moving averages:** Cumulative sales and moving average pricing.
* **Performance analytics:** Yearly product performance versus category averages and prior year growth.
* **Part-to-Whole analysis:** Category contributions to total business sales.
* **Data segmentation:** Grouping products into cost ranges and analysing distribution.

These SQL scripts enable powerful temporal and comparative insights critical for business intelligence and executive reporting.

---

## 🛠 Tools & Technologies

This project uses standard SQL for analytical reporting and is designed to run on analytical databases that support window functions and CTEs (e.g., MySQL, PostgreSQL, Snowflake, SQL Server).

---

## 📂 Repository Structure 

```
📦 sql-advanced-analytics
├── 📁 views
│   ├── report_customers.sql
│   └── report_product.sql
├── 📁 analytics
│   ├── change_over_time.sql
│   ├── cumulative_analysis.sql
│   ├── performance_analysis.sql
│   └── segmentation.sql
├── README.md
└── LICENSE
```

---

## 🔍 Why This Matters

This project demonstrates real-world analytical SQL techniques such as aggregated reporting, segmentation, KPIs, and time-based trend analysis. It’s ideal for data analysts, BI engineers, or anyone looking to build production-grade analytics using SQL.

---

## 🏁 Getting Started

1. Load your dataset into your analytics database (`fact_sales`, `dim_customers`, `dim_products`).
2. Execute the SQL views under `views/`.
3. Use the analytical queries to generate reports via your BI tool (e.g., Tableau, Power BI) or SQL editor.

---

## 📜 License

This project is released under the **MIT License**
