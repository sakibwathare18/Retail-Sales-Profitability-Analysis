-- =========================================================
-- Retail Sales & Profitability Analysis Project
-- Tool: PostgreSQL / SQL
-- Dataset: Superstore
-- Project: Retail Sales & Profitability Analysis Dashboard
-- =========================================================

-- =========================================================
-- 1. CREATE TABLE
-- =========================================================

CREATE TABLE superstore (
    row_id INT,
    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    customer_name VARCHAR(150),
    segment VARCHAR(50),
    country VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name TEXT,
    sales NUMERIC(12,2),
    quantity INT,
    discount NUMERIC(5,2),
    profit NUMERIC(12,2)
);

-- =========================================================
-- 2. DATA CLEANING / FEATURE ENGINEERING
-- =========================================================

-- Add shipping days column
ALTER TABLE superstore
ADD COLUMN shipping_days INT;

UPDATE superstore
SET shipping_days = ship_date - order_date;

-- Add profit margin column
ALTER TABLE superstore
ADD COLUMN profit_margin NUMERIC(10,4);

UPDATE superstore
SET profit_margin = CASE
    WHEN sales = 0 THEN 0
    ELSE profit / sales
END;

-- Add month number
ALTER TABLE superstore
ADD COLUMN month INT;

UPDATE superstore
SET month = EXTRACT(MONTH FROM order_date);

-- Add month name
ALTER TABLE superstore
ADD COLUMN month_name VARCHAR(20);

UPDATE superstore
SET month_name = TO_CHAR(order_date, 'Month');

-- Trim month name spaces
UPDATE superstore
SET month_name = TRIM(month_name);

-- Add year
ALTER TABLE superstore
ADD COLUMN year INT;

UPDATE superstore
SET year = EXTRACT(YEAR FROM order_date);

-- =========================================================
-- 3. DATA VALIDATION CHECKS
-- =========================================================

-- Check nulls
SELECT * 
FROM superstore
WHERE order_id IS NULL
   OR order_date IS NULL
   OR customer_id IS NULL
   OR sales IS NULL
   OR profit IS NULL;

-- Check duplicate order rows if needed
SELECT order_id, product_id, COUNT(*)
FROM superstore
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

-- Check date range
SELECT MIN(order_date) AS min_order_date,
       MAX(order_date) AS max_order_date
FROM superstore;

-- =========================================================
-- 4. KPI QUERIES
-- =========================================================

-- Total Sales
SELECT SUM(sales) AS total_sales
FROM superstore;

-- Total Profit
SELECT SUM(profit) AS total_profit
FROM superstore;

-- Total Orders
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM superstore;

-- Total Customers
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM superstore;

-- Total Quantity Sold
SELECT SUM(quantity) AS total_quantity
FROM superstore;

-- Average Order Value
SELECT SUM(sales) / COUNT(DISTINCT order_id) AS avg_order_value
FROM superstore;

-- Profit Margin %
SELECT (SUM(profit) / SUM(sales)) * 100 AS profit_margin_pct
FROM superstore;

-- Average Discount
SELECT AVG(discount) AS avg_discount
FROM superstore;

-- Average Shipping Days
SELECT AVG(shipping_days) AS avg_shipping_days
FROM superstore;

-- =========================================================
-- 5. EXECUTIVE OVERVIEW ANALYSIS
-- =========================================================

-- Monthly Sales Trend
SELECT year, month, month_name, SUM(sales) AS total_sales
FROM superstore
GROUP BY year, month, month_name
ORDER BY year, month;

-- Monthly Profit Trend
SELECT year, month, month_name, SUM(profit) AS total_profit
FROM superstore
GROUP BY year, month, month_name
ORDER BY year, month;

-- Sales by Category
SELECT category, SUM(sales) AS total_sales
FROM superstore
GROUP BY category
ORDER BY total_sales DESC;

-- Profit by Category
SELECT category, SUM(profit) AS total_profit
FROM superstore
GROUP BY category
ORDER BY total_profit DESC;

-- Sales by Region
SELECT region, SUM(sales) AS total_sales
FROM superstore
GROUP BY region
ORDER BY total_sales DESC;

-- Top 10 Products by Sales
SELECT product_name, SUM(sales) AS total_sales
FROM superstore
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;

-- =========================================================
-- 6. PROFITABILITY ANALYSIS
-- =========================================================

-- Profit by Sub-Category
SELECT sub_category, SUM(profit) AS total_profit
FROM superstore
GROUP BY sub_category
ORDER BY total_profit DESC;

-- Sales vs Profit by Sub-Category
SELECT sub_category,
       SUM(sales) AS total_sales,
       SUM(profit) AS total_profit
FROM superstore
GROUP BY sub_category
ORDER BY total_sales DESC;

-- Profit Margin by Category
SELECT category,
       ROUND(AVG(profit_margin) * 100, 2) AS avg_profit_margin_pct
FROM superstore
GROUP BY category
ORDER BY avg_profit_margin_pct DESC;

-- Loss-Making States
SELECT state, SUM(profit) AS total_profit
FROM superstore
GROUP BY state
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;

-- Top Loss-Making Products
SELECT product_name,
       SUM(sales) AS total_sales,
       SUM(profit) AS total_profit,
       AVG(discount) AS avg_discount,
       SUM(quantity) AS total_quantity
FROM superstore
GROUP BY product_name
HAVING SUM(profit) < 0
ORDER BY total_profit ASC
LIMIT 20;

-- Sub-categories with high sales but low profit
SELECT sub_category,
       SUM(sales) AS total_sales,
       SUM(profit) AS total_profit
FROM superstore
GROUP BY sub_category
ORDER BY total_sales DESC;

-- =========================================================
-- 7. CUSTOMER ANALYSIS
-- =========================================================

-- Top 10 Customers by Sales
SELECT customer_name, SUM(sales) AS total_sales
FROM superstore
GROUP BY customer_name
ORDER BY total_sales DESC
LIMIT 10;

-- Top 10 Customers by Profit
SELECT customer_name, SUM(profit) AS total_profit
FROM superstore
GROUP BY customer_name
ORDER BY total_profit DESC
LIMIT 10;

-- Sales by Segment
SELECT segment, SUM(sales) AS total_sales
FROM superstore
GROUP BY segment
ORDER BY total_sales DESC;

-- Average Order Value by Segment
SELECT segment,
       SUM(sales) / COUNT(DISTINCT order_id) AS avg_order_value
FROM superstore
GROUP BY segment
ORDER BY avg_order_value DESC;

-- Sales per Customer
SELECT customer_name,
       SUM(sales) AS total_sales,
       COUNT(DISTINCT order_id) AS total_orders,
       SUM(sales) / COUNT(DISTINCT order_id) AS avg_order_value
FROM superstore
GROUP BY customer_name
ORDER BY total_sales DESC;

-- =========================================================
-- 8. REGIONAL ANALYSIS
-- =========================================================

-- Profit by Region
SELECT region, SUM(profit) AS total_profit
FROM superstore
GROUP BY region
ORDER BY total_profit DESC;

-- Top 10 States by Sales
SELECT state, SUM(sales) AS total_sales
FROM superstore
GROUP BY state
ORDER BY total_sales DESC
LIMIT 10;

-- Sales and Profit by State
SELECT state,
       SUM(sales) AS total_sales,
       SUM(profit) AS total_profit
FROM superstore
GROUP BY state
ORDER BY total_sales DESC;

-- City level analysis
SELECT city,
       state,
       SUM(sales) AS total_sales,
       SUM(profit) AS total_profit
FROM superstore
GROUP BY city, state
ORDER BY total_sales DESC;

-- =========================================================
-- 9. DISCOUNT IMPACT ANALYSIS
-- =========================================================

-- Average profit by discount level
SELECT discount,
       AVG(profit) AS avg_profit,
       SUM(sales) AS total_sales
FROM superstore
GROUP BY discount
ORDER BY discount;

-- Orders with heavy discount and negative profit
SELECT order_id, product_name, sales, discount, profit
FROM superstore
WHERE discount > 0.20
  AND profit < 0
ORDER BY profit ASC;

-- =========================================================
-- 10. SHIPPING ANALYSIS
-- =========================================================

-- Average shipping days by region
SELECT region, AVG(shipping_days) AS avg_shipping_days
FROM superstore
GROUP BY region
ORDER BY avg_shipping_days DESC;

-- Average shipping days by ship mode
SELECT ship_mode, AVG(shipping_days) AS avg_shipping_days
FROM superstore
GROUP BY ship_mode
ORDER BY avg_shipping_days DESC;

-- Shipping days vs profit
SELECT ship_mode,
       AVG(shipping_days) AS avg_shipping_days,
       SUM(profit) AS total_profit
FROM superstore
GROUP BY ship_mode
ORDER BY total_profit DESC;