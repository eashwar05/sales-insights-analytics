-- =========================================================================
-- Script Name: clean_transactions.sql
-- Description: Cleans and normalizes the raw transactions table for Power BI ingestion.
--              1. Removes hidden '\r' carriage returns from currency strings.
--              2. Converts USD transactions to INR (assuming 1 USD = 75 INR).
--              3. Filters out invalid data (sales amounts <= 0).
-- Target DB:   sales
-- Author:      N Eashwar
-- =========================================================================

-- Specify the database context
USE `sales`;

-- Drop the view if it already exists to prevent conflict errors on deployment
DROP VIEW IF EXISTS `vw_clean_transactions`;

-- Create the production view for Power BI connection
CREATE VIEW `vw_clean_transactions` AS
SELECT 
    `product_code`,
    `customer_code`,
    `market_code`,
    `order_date`,
    `sales_qty`,
    `sales_amount` AS `original_sales_amount`,
    
    -- 1. Strip hidden \r carriage return characters from raw import strings
    REPLACE(`currency`, '\r', '') AS `currency`,
    
    -- 2. Standardize all revenue data to INR (Currency Normalization)
    CASE 
        WHEN REPLACE(`currency`, '\r', '') = 'USD' THEN `sales_amount` * 75
        ELSE `sales_amount`
    END AS `normalized_sales_amount`
    
FROM `transactions`
-- 3. Data Cleansing: Filter out zero or negative anomaly data points
WHERE `sales_amount` > 0;

-- Verification Query: Execute to confirm the view compiles and returns clean records
SELECT * FROM `vw_clean_transactions` LIMIT 10;