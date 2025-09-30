-- 1. Drop existing table if present (safe reset)
DROP TABLE IF EXISTS orders;

-- 2. Create the orders table
CREATE TABLE SALEdata (
    order_id varchar(50),
    order_date DATE,
    amount DECIMAL(12,2),        -- revenue for the order (may be NULL)
    product_id INT,
    customer_id INT,
    PRIMARY KEY (order_id)
) ENGINE=InnoDB;
-- Insert sample orders across months & years
INSERT INTO orders (order_id, order_date, amount, product_id, customer_id) VALUES
('OR001', '2024-01-05', 120.50, 101, 1001),
('OR002', '2024-01-20', 75.00, 102, 1002),
('OR003', '2024-02-02', 250.00, 103, 1003),
('OR004', '2024-02-15', 0.00, 104, 1004),
('OR005', '2024-02-28', NULL, 105, 1005),    -- missing amount example
('OR006', '2024-03-10', 300.75, 101, 1001),
('OR007', '2024-03-22', 50.00, 106, 1006),
('OR008', '2024-03-25', 150.00, 107, 1007),
('OR009', '2024-04-11', 500.00, 101, 1001),
('OR010', '2024-12-30', 25.00, 108, 1008),
('OR011', '2025-01-03', 400.00, 109, 1009),
('OR012', '2025-01-20', 200.00, 101, 1001);
-- Final monthly report: Year, Month, Revenue (sum of amount), Order Volume (distinct order count)
SELECT
  YEAR(order_date) AS year,
  MONTH(order_date) AS month,
  SUM(COALESCE(amount, 0)) AS total_revenue,         -- handle NULLs by treating them as 0
  COUNT(DISTINCT order_id) AS order_volume,
  COUNT(*) AS rows_count
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);
SELECT
  EXTRACT(YEAR FROM order_date) AS year,
  EXTRACT(MONTH FROM order_date) AS month,
  SUM(COALESCE(amount, 0)) AS total_revenue,
  COUNT(DISTINCT order_id) AS order_volume
FROM orders
GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
ORDER BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date);
-- Drop if exists, then create a stored table containing the aggregated results
DROP TABLE IF EXISTS monthly_sales_report;

CREATE TABLE monthly_sales_report AS
SELECT
  YEAR(order_date) AS year,
  MONTH(order_date) AS month,
  SUM(COALESCE(amount, 0)) AS total_revenue,
  COUNT(DISTINCT order_id) AS order_volume
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);
SELECT
  YEAR(order_date) AS year,
  MONTH(order_date) AS month,
  SUM(COALESCE(amount,0)) / NULLIF(COUNT(DISTINCT order_id), 0) AS avg_order_value
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date);
-- Top 3 month/year combos by total_revenue
SELECT year, month, total_revenue, order_volume
FROM (
  SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    SUM(COALESCE(amount, 0)) AS total_revenue,
    COUNT(DISTINCT order_id) AS order_volume
  FROM orders
  GROUP BY YEAR(order_date), MONTH(order_date)
) t
ORDER BY total_revenue DESC
LIMIT 3;
SELECT
  YEAR(order_date) AS year,
  MONTH(order_date) AS month,
  SUM(COALESCE(amount, 0)) AS total_revenue,
  COUNT(DISTINCT order_id) AS order_volume
FROM orders
WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);
