

-- 1 Create Database
DROP DATABASE IF EXISTS bikestore;
CREATE DATABASE bikestore;
USE bikestore;

-- 2 Create Tables
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    city VARCHAR(50),
    join_date DATE
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 3 Insert Sample Data
INSERT INTO customers VALUES
(1, 'John', 'Smith', 'New York', '2022-01-15'),
(2, 'Alice', 'Brown', 'Los Angeles', '2022-02-10'),
(3, 'Mark', 'Taylor', 'Chicago', '2022-03-05'),
(4, 'Sophia', 'Johnson', 'Houston', '2022-04-20'),
(5, 'David', 'Williams', 'Phoenix', '2022-05-18');

INSERT INTO products VALUES
(101, 'Mountain Bike', 'Bikes', 800.00),
(102, 'Road Bike', 'Bikes', 1200.00),
(103, 'Helmet', 'Accessories', 50.00),
(104, 'Gloves', 'Accessories', 20.00),
(105, 'Cycling Jersey', 'Clothing', 60.00);

INSERT INTO orders VALUES
(1001, 1, '2022-03-01', 850.00),
(1002, 2, '2022-03-15', 1200.00),
(1003, 3, '2022-04-10', 1280.00),
(1004, 4, '2022-05-05', 70.00),
(1005, 5, '2022-05-25', 60.00);

INSERT INTO order_items VALUES
(1, 1001, 101, 1, 800.00),
(2, 1001, 103, 1, 50.00),
(3, 1002, 102, 1, 1200.00),
(4, 1003, 102, 1, 1200.00),
(5, 1003, 104, 4, 20.00),
(6, 1004, 103, 1, 50.00),
(7, 1004, 104, 1, 20.00),
(8, 1005, 105, 1, 60.00);

-- 4 Complex Queries

-- a) Monthly Revenue by Category
SELECT
  DATE_FORMAT(o.order_date, '%Y-%m') AS month,
  p.category,
  SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
GROUP BY month, p.category
ORDER BY month, revenue DESC;

-- b) Top 5 Customers by Spend
SELECT
  c.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY total_spent DESC
LIMIT 5;

-- c) Unsold Products
SELECT
  p.product_id,
  p.product_name
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE oi.order_item_id IS NULL;

-- d) Rank Products by Category Revenue
SELECT
  category,
  product_id,
  product_name,
  total_revenue,
  RANK() OVER (PARTITION BY category ORDER BY total_revenue DESC) AS category_rank
FROM (
  SELECT
    p.category,
    p.product_id,
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
  FROM products p
  JOIN order_items oi ON oi.product_id = p.product_id
  GROUP BY p.category, p.product_id, p.product_name
) AS sub
ORDER BY category, category_rank;

-- 5 Stored Procedure: Get Customer Spend
DELIMITER //

CREATE PROCEDURE GetCustomerSpend(IN p_customer_id INT)
BEGIN
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        SUM(o.total_amount) AS total_spend
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE c.customer_id = p_customer_id
    GROUP BY c.customer_id, customer_name;
END //

DELIMITER ;

-- Example Call:
-- CALL GetCustomerSpend(1);
