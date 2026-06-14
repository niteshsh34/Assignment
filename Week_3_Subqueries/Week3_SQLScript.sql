CREATE DATABASE sales_analysis;
USE sales_analysis;

CREATE TABLE superstore_raw (
    row_id INT,
    order_id VARCHAR(30),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(30),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(255),
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(5,2),
    profit DECIMAL(10,2)
);

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.7/Uploads/superstore.csv'
    INTO TABLE superstore_raw
    CHARACTER SET latin1
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (
     row_id,
     order_id,
     @order_date,
     @ship_date,
     ship_mode,
     customer_id,
     customer_name,
     segment,
     country,
     city,
     state,
     postal_code,
     region,
     product_id,
     category,
     sub_category,
     product_name,
     sales,
     quantity,
     discount,
     profit
        )
    SET
        order_date = STR_TO_DATE(@order_date, '%m/%d/%Y'),
        ship_date = STR_TO_DATE(@ship_date, '%m/%d/%Y');

select count(*)
from superstore_raw;

DESCRIBE superstore_raw;

CREATE TABLE customers
(
    customer_id   VARCHAR(30) PRIMARY KEY,
    customer_name VARCHAR(100),
    segment       VARCHAR(50),
    country       VARCHAR(100),
    city          VARCHAR(100),
    state         VARCHAR(100),
    postal_code   VARCHAR(20),
    region        VARCHAR(50)
);

SELECT customer_id, COUNT(*)
FROM superstore_raw
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Multiple records were found for the same customer_id in the source dataset.
-- Since customer_id alone could not uniquely identify complete customer details
-- (city, state, postal code varied across records)

DROP TABLE IF EXISTS customers;


CREATE TABLE customers(
customer_id varchar(20) primary key,
customer_name varchar(100),
segment varchar(55)
);

insert into customers(	customer_id ,customer_name ,segment)
(
SELECT DISTINCT
	customer_id ,
	customer_name ,
	segment
from superstore_raw
);



select *
from customers;

SELECT product_id, COUNT(*)
FROM superstore_raw
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Some product_ids were associated with multiple product names

CREATE TABLE products(
product_id varchar(20) ,
category varchar(30),
sub_category varchar(30),
product_name varchar(255)
);

insert into products(product_id, category, sub_category, product_name )
(
SELECT DISTINCT
	product_id, category, sub_category, product_name
from superstore_raw
);



CREATE TABLE orders(
order_id varchar(20) ,
customer_id varchar(20) ,
product_id varchar(20) ,
order_date date,
ship_date date,
ship_mode varchar(30),
order_country varchar(55),
order_city varchar(55),
order_state varchar(55),
order_postal_code varchar(10),
order_region varchar(10),
sales DECIMAL(9,4),
quantity integer,
discount decimal(5,2),
profit DECIMAL(9,4)
);

insert into orders
(
select
order_id  ,
customer_id  ,
product_id ,
order_date ,
ship_date ,
ship_mode ,
country ,
city,
state ,
postal_code ,
region ,
sales,
quantity ,
discount ,
profit
from superstore_raw
);

select count(*)
from customers;

select count(*)
from products;

select count(*)
from orders;

-- 1. Orders where Sales are Greater than Average Sales (Subquery)
SELECT *,
       (SELECT AVG(sales) FROM orders) AS avg_sales
FROM orders
WHERE sales > (
    SELECT AVG(sales)
    FROM orders
);
-- The inner query calculates the average sales value of all orders.
-- The outer query returns only those orders whose sales are greater than the average.

-- 2. Find the highest sales order for each customer
WITH max_sales AS (
    SELECT
        customer_id,
        MAX(sales) AS max_sale
    FROM orders
    GROUP BY customer_id
)
SELECT
    o.customer_id,
    o.order_id,
    o.sales
FROM orders o
JOIN max_sales m
    ON o.customer_id = m.customer_id
   AND o.sales = m.max_sale;
-- For each customer, the cte finds the maximum sales value.
-- The lower query returns the corresponding order.

-- 3 Calculate Total Sales for Each Customer (CTE)
WITH customer_sales AS
(
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)
SELECT *
FROM customer_sales;

-- 4. Find customers whose total sales are above average
WITH customer_sales AS
(
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)
SELECT *
FROM customer_sales
WHERE total_sales >
(
    SELECT AVG(total_sales)
    FROM customer_sales
);
-- First calculate total sales per customer.
-- Calculate average of all customer totals.
-- Return customers whose sales exceed that average.


-- 5 Rank All Customers Based on Total Sales (Window Function) + CTE

WITH customer_sales AS
(
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)
SELECT
    customer_id,
    total_sales,
    RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM customer_sales;
-- Highest sales customer gets Rank 1.
-- Same sales receive same rank.

-- 6 Assign Row Numbers to Each Order Within a Customer

SELECT
    customer_id,
    order_id,
    sales,
    ROW_NUMBER() OVER
    (
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS row_num
FROM orders;
-- PARTITION BY creates separate groups for each customer.
-- Numbering restarts from 1 for every customer.

-- 7. Display top 3 customers based on total sales
WITH customer_sales AS
(
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)
SELECT *
FROM
(
    SELECT
        customer_id,
        total_sales,
        RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
    FROM customer_sales
) ranked_customers
WHERE sales_rank <= 3;
-- Rank customers according to total sales.
-- Select top 3 ranks.


-- Final Query:
-- Display Customer Name, Total Sales, and Rank
-- Uses JOIN + CTE + Window Function
WITH customer_sales AS
(
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)
SELECT DISTINCT
    c.customer_name,
    cs.total_sales,
    RANK() OVER (ORDER BY cs.total_sales DESC) AS sales_rank
FROM customer_sales cs
JOIN customers c
    ON cs.customer_id = c.customer_id
ORDER BY sales_rank;


-- Mini Project
-- 1. Top 5 Customers Based on Total Sales

WITH customer_sales AS (
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)
SELECT distinct
    c.customer_name,
    cs.total_sales
FROM customer_sales cs
JOIN customers c
    ON cs.customer_id = c.customer_id
ORDER BY cs.total_sales DESC
LIMIT 5;

-- 2. Bottom 5 Customers Based on Total Sales
WITH customer_sales AS (
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)
SELECT DISTINCT
    c.customer_name,
    cs.total_sales
FROM customer_sales cs
JOIN customers c
    ON cs.customer_id = c.customer_id
ORDER BY cs.total_sales ASC
LIMIT 5;

-- 3. Customers Who Made Only One Order
SELECT
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_name
HAVING COUNT(DISTINCT o.order_id) = 1;

-- 4. Customers With Above-Average Sales
WITH customer_sales AS (
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)

SELECT
    cs.customer_id,
    c.customer_name,
    cs.total_sales
FROM customer_sales cs
JOIN customers c
    ON cs.customer_id = c.customer_id
WHERE cs.total_sales >
(
    SELECT AVG(total_sales)
    FROM customer_sales
);

-- 5. Highest Order Value Per Customer
SELECT
    c.customer_name,
    MAX(o.sales) AS highest_order_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_name
ORDER BY highest_order_value DESC;
