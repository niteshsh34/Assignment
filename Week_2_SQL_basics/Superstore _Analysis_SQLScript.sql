CREATE DATABASE sales_analysis;
USE sales_analysis;

CREATE TABLE superstore (
    row_id INT,
    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code INT,
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(255),
    sales DECIMAL(12,2),
    quantity INT,
    discount DECIMAL(5,2),
    profit DECIMAL(12,2)
);

DROP TABLE IF EXISTS superstore;

CREATE TABLE superstore (
    row_id INT,
    order_id VARCHAR(50),
    order_date VARCHAR(20),
    ship_date VARCHAR(20),  # Date not formatted
    ship_mode VARCHAR(50),   # Date not formatted
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code INT,
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(255),
    sales DECIMAL(12,2),
    quantity INT,
    discount DECIMAL(5,2),
    profit DECIMAL(12,2)
);

ALTER TABLE superstore
ADD COLUMN order_date_new DATE,
ADD COLUMN ship_date_new DATE;

UPDATE superstore
SET
order_date_new = STR_TO_DATE(order_date,'%m/%d/%Y'),
ship_date_new = STR_TO_DATE(ship_date,'%m/%d/%Y');

SELECT
order_date,
order_date_new
FROM superstore
LIMIT 10;

## ----DATA EXPLORATION----
    ## Total records
Select count(*) as total_rows
from superstore
    ## Sample Data
Select *
from superstore
limit 10;
    ## Table Structure
DESCRIBE superstore;

## ----DATA QUALITY VALIDATION----
    ## Null Values Check
Select
    sum(case when order_id is null then 1 else 0 end) as null_orderid,
    sum(case when customer_name is null then 1 else 0 end) as null_customer,
    sum(case when sales is null then 1 else 0 end) as null_sales
from superstore;
    ## Duplicate Records
Select order_id,
count(*) as cnt
from superstore
group by order_id
having count(*) > 1;
    ## Negative Profit Orders
Select order_id, customer_name, profit
From superstore
where profit < 0;

## ----WHERE CLAUSE ANALYSIS----
    ## Orders from West Region
SELECT *
FROM superstore
WHERE region='West';
    ## Furniture Category
SELECT *
FROM superstore
WHERE category='Furniture';
    ## Sales Greater Than 1000
SELECT *
FROM superstore
WHERE sales > 1000;
    ## Orders in 2017
SELECT *
FROM superstore
WHERE YEAR(order_date_new)=2017;

## ----AGGREGATION ANALYSIS----
    ## Total Sales
SELECT ROUND(SUM(sales),2) AS total_sales
FROM superstore;
    ## Total Profit
SELECT ROUND(SUM(profit),2) AS total_profit
FROM superstore;
    ## Average Sales
SELECT ROUND(AVG(sales),2) AS avg_sales
FROM superstore;
    ## Total Quantity Sold
SELECT SUM(quantity) AS total_quantity
FROM superstore;

## ----GROUP BY ANALYSIS----
    ## Sales by Region
Select region,
       ROUND(SUM(sales),2) as total_sales
from superstore
group by region
order by total_sales desc;
    ## Profit by Region
SELECT
region,
ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY region
ORDER BY total_profit DESC;
    ## Sales by Category
SELECT
category,
ROUND(SUM(sales),2) AS sales
FROM superstore
GROUP BY category
ORDER BY sales DESC;
    ## Sales by Sub-Category
SELECT
sub_category,
ROUND(SUM(sales),2) AS sales
FROM superstore
GROUP BY sub_category
ORDER BY sales DESC;
    ## Average Order Value by Region
SELECT
region,
ROUND(AVG(sales),2) AS avg_order_value
FROM superstore
GROUP BY region;

## ----TOP PRODUCT ANALYSIS----
    ## Top 10 Products by Sales
SELECT
product_name,
ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;
    ## Top 10 Products by Profit
SELECT
product_name,
ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY product_name
ORDER BY total_profit DESC
LIMIT 10;
    ## Bottom 10 Products by Profit
SELECT
product_name,
ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY product_name
ORDER BY total_profit
LIMIT 10;

## ----Customer Analysis----
    ## Top 10 Customers by Sales
SELECT
customer_name,
ROUND(SUM(sales),2) AS sales
FROM superstore
GROUP BY customer_name
ORDER BY sales DESC
LIMIT 10;

    ## Top 10 Customers by Profit
SELECT
customer_name,
ROUND(SUM(profit),2) AS profit
FROM superstore
GROUP BY customer_name
ORDER BY profit DESC
LIMIT 10;
    ## Customer Count by Segment
SELECT
segment,
COUNT(DISTINCT customer_id) AS customers
FROM superstore
GROUP BY segment;

## ----STATE ANALYSIS----
    ## Top state by Sales
SELECT
state,
ROUND(SUM(sales),2) AS sales
FROM superstore
GROUP BY state
ORDER BY sales DESC
LIMIT 10;
    ## Top state by profit
SELECT
state,
ROUND(SUM(profit),2) AS profit
FROM superstore
GROUP BY state
ORDER BY profit DESC
LIMIT 10;
    ## States Making Loss
SELECT
state,
ROUND(SUM(profit),2) AS profit
FROM superstore
GROUP BY state
having SUM(profit) < 0;
    ## Monthly Sales Trend
SELECT
DATE_FORMAT(order_date_new,'%Y-%m') AS month,
ROUND(SUM(sales),2) AS sales
FROM superstore
GROUP BY month
ORDER BY month;
    ## Monthly Profit Trend
SELECT
DATE_FORMAT(order_date_new,'%Y-%m') AS month,
ROUND(SUM(profit),2) AS profit
FROM superstore
GROUP BY month
ORDER BY month;

## ----Use Cases----
    ## Which Category Generates Highest Revenue?
SELECT
category,
ROUND(SUM(sales),2) AS revenue
FROM superstore
GROUP BY category
ORDER BY revenue DESC;
    ## Which Category Generates Highest Profit?
SELECT
category,
ROUND(SUM(profit),2) AS profit
FROM superstore
GROUP BY category
ORDER BY profit DESC;
    ## Most Profitable Sub-Category
SELECT
sub_category,
ROUND(SUM(profit),2) AS profit
FROM superstore
GROUP BY sub_category
ORDER BY profit DESC
LIMIT 5;
    ## Loss Making Sub-Category
SELECT
sub_category,
ROUND(SUM(profit),2) AS profit
FROM superstore
GROUP BY sub_category
ORDER BY profit
LIMIT 5;
    ## Average Shipping Delay
SELECT
ROUND(AVG(DATEDIFF(ship_date_new,order_date_new)),2)
AS avg_shipping_days
FROM superstore;

1. The dataset contained 9,994 records.
2. The total quantity sold was 37,873 units.
3. Total profit was 286,396.62.
4. The average sale value was 229.86.
5. Total sales were 2,297,200.64.
6. The West region generated the highest sales and profit.
7. The Technology category contributed the highest revenue.
8. Chairs and Phones were among the best-selling products.
9. Some sub-categories, such as Tables, generated negative profit despite high sales.
10. Higher discounts generally reduced profitability.
11. The Consumer segment had the largest customer base.
12. California contributed the highest revenue and profit among all states.
13. The average shipping time was approximately 3.96 days.
14. The top 10 customers generated a significant share of total sales.
15. Monthly sales showed seasonal spikes, particularly during year-end periods.