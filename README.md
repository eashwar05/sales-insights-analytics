# Sales Insights Data Analytics Project (MySQL + Power BI)

## 📌 Project Overview & Business Problem
Atliq Hardware is an electronics hardware consumer goods company facing rapid market changes and dynamic customer demands. The Sales Director was finding it increasingly difficult to track overall business performance, identify declining regional trends, and make data-driven decisions due to a heavy reliance on manual data gathering from various regional managers.

**Objective:** To unlock deep, previously invisible sales insights for the executive team, automate the reporting pipeline to eliminate manual data aggregation hours, and provide a single source of truth for strategic decision support.

---

## 👥 Stakeholders & Impact Matrix
This automated analytics pipeline delivers targeted value across multiple functional teams:
* **Sales Director:** Real-time visibility into overall revenue, quantity sold, and regional market trends to support immediate tactical decisions.
* **Marketing Team:** Advanced customer and product segmentation metrics to optimize campaign targeting and promotional strategies.
* **Customer Service Team:** Clear tracking of the top-performing clients to prioritize high-value relationship management and client support pipelines.
* **Analytics & IT Teams:** A structured, performant data pipeline that offloads manual ad-hoc request generation through automated scheduled refreshes.

---

## 🛠️ Tech Stack & Architecture
* **Database:** MySQL Server / MySQL Workbench (Relational Data Ingestion)
* **Business Intelligence Tool:** Power BI Desktop & Power BI Service (Cloud)
* **Data Modeling Layer:** Star Schema Design
* **Database Engineering:** SQL Views (ETL/Data Cleansing Layer)
* **Analytical Calculations:** Data Analysis Expressions (DAX)

---

## 🏗️ Data Architecture & Star Schema
To ensure optimal calculation performance, quick slice-and-dice response times, and clean structural integrity, the project is designed using a **Star Schema** model. It contains one centralized Fact Table surrounded by four distinct Dimension Tables connected via **1-to-Many (*:1)** active relationships:

* **Fact Table:** `vw_clean_transactions` (Stores revenue metrics, quantities, and operational codes)
* **Dimension Tables:**
    * `customers` (Customer profiles and distribution channels)
    * `markets` (Geographical distribution and macro-zones)
    * `products` (Product codes and manufacturing brands)
    * `date` (Time intelligence alignment spanning years and months)

---

## 🧹 Data Engineering & ETL Pipeline (SQL View Layer)
During initial Exploratory Data Analysis (EDA) in MySQL, several critical data anomalies were discovered that would have skewed business figures if not resolved:
1.  **Text Formatting Anomalies:** Text fields contained hidden carriage returns (`\r`), generating split groups for identical entities (e.g., treating `'INR'` and `'INR\r'` as separate currencies).
2.  **Currency Inconsistencies:** Transactions were mixed across `INR` and `USD`, preventing accurate direct summation of the sales values.
3.  **Outlier Out-of-Bounds Values:** Several records logged a `sales_amount` of `0` or `-1` (corrupted entries or undocumented return logic).

To address this cleanly before data entered Power BI, a secure database view (`vw_clean_transactions`) was built to act as an automated data processing filter:

```sql
CREATE VIEW `vw_clean_transactions` AS
SELECT 
    `product_code`,
    `customer_code`,
    `market_code`,
    `order_date`,
    `sales_qty`,
    `sales_amount` AS `original_sales_amount`,
    
    -- 1. Strip hidden \r carriage return characters
    REPLACE(`currency`, '\r', '') AS `currency`,
    
    -- 2. Standardize all revenue figures to INR (Assuming 1 USD = 75 INR)
    CASE 
        WHEN REPLACE(`currency`, '\r', '') = 'USD' THEN `sales_amount` * 75
        ELSE `sales_amount`
    END AS `normalized_sales_amount`
    
FROM `transactions`
-- 3. Filter out zero or negative data anomalies
WHERE `sales_amount` > 0;
