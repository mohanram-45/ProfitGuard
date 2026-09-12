-- ============================================================
-- PROFITGUARD
-- SECTION 4: CUSTOMER ANALYSIS
-- ============================================================


-- ------------------------------------------------------------
-- 1. REVENUE BY CUSTOMER
-- Business question:
-- Which customers generate the most revenue?
-- ------------------------------------------------------------

SELECT 
    c.customer_id, 
    c.customer_name,

    ROUND(
        SUM(oi.quantity * p.selling_price),
        2
    ) AS customer_revenue

FROM customers AS c 

LEFT JOIN orders AS ord
    ON c.customer_id = ord.customer_id

LEFT JOIN order_items AS oi
    ON ord.order_id = oi.order_id

LEFT JOIN products AS p 
    ON oi.product_id = p.product_id 

GROUP BY 
    c.customer_id,
    c.customer_name

ORDER BY
    customer_revenue DESC;



-- ------------------------------------------------------------
-- 2. ORDERS PER CUSTOMER + CUSTOMER REVENUE
-- Business question:
-- How many orders has each customer placed and how much
-- revenue have they generated?
-- ------------------------------------------------------------

SELECT 
    c.customer_id, 
    c.customer_name,

    COUNT(DISTINCT ord.order_id) AS total_orders,

    ROUND(
        SUM(oi.quantity * p.selling_price),
        2
    ) AS customer_revenue

FROM customers AS c 

LEFT JOIN orders AS ord
    ON c.customer_id = ord.customer_id

LEFT JOIN order_items AS oi
    ON ord.order_id = oi.order_id

LEFT JOIN products AS p 
    ON oi.product_id = p.product_id 

GROUP BY 
    c.customer_id,
    c.customer_name

ORDER BY
    customer_revenue DESC;



-- ------------------------------------------------------------
-- 3. AVERAGE ORDER SPEND PER CUSTOMER
-- Business question:
-- What is the average value of each customer's orders?
-- ------------------------------------------------------------

WITH customer_summary AS (

    SELECT 
        c.customer_id, 
        c.customer_name,

        COUNT(DISTINCT ord.order_id) AS total_orders,

        ROUND(
            SUM(oi.quantity * p.selling_price),
            2
        ) AS customer_revenue

    FROM customers AS c 

    LEFT JOIN orders AS ord
        ON c.customer_id = ord.customer_id

    LEFT JOIN order_items AS oi
        ON ord.order_id = oi.order_id

    LEFT JOIN products AS p 
        ON oi.product_id = p.product_id 

    GROUP BY 
        c.customer_id, 
        c.customer_name
)

SELECT
    customer_id,
    customer_name,
    total_orders,
    customer_revenue,

    ROUND(
        customer_revenue / total_orders,
        2
    ) AS average_order_spend

FROM customer_summary

ORDER BY
    customer_revenue DESC;



-- ------------------------------------------------------------
-- 4. REPEAT VS ONE-TIME CUSTOMER CLASSIFICATION
-- Business question:
-- Which customers purchased once and which customers returned?
-- ------------------------------------------------------------

WITH customer_orders AS (

    SELECT
        c.customer_id,
        c.customer_name,

        COUNT(DISTINCT ord.order_id) AS total_orders

    FROM customers AS c

    LEFT JOIN orders AS ord
        ON c.customer_id = ord.customer_id

    GROUP BY
        c.customer_id,
        c.customer_name
)

SELECT
    customer_id,
    customer_name,
    total_orders,

    CASE
        WHEN total_orders = 1 THEN 'One-time Customer'
        WHEN total_orders > 1 THEN 'Repeat Customer'
        ELSE 'No Orders'
    END AS customer_type

FROM customer_orders

ORDER BY
    total_orders DESC;



-- ------------------------------------------------------------
-- 5. TOP 10 CUSTOMERS BY REVENUE
-- Business question:
-- Which 10 customers generate the highest revenue?
-- ------------------------------------------------------------

WITH customer_summary AS (

    SELECT 
        c.customer_id, 
        c.customer_name,

        COUNT(DISTINCT ord.order_id) AS total_orders,

        ROUND(
            SUM(oi.quantity * p.selling_price),
            2
        ) AS customer_revenue

    FROM customers AS c 

    LEFT JOIN orders AS ord
        ON c.customer_id = ord.customer_id

    LEFT JOIN order_items AS oi
        ON ord.order_id = oi.order_id

    LEFT JOIN products AS p 
        ON oi.product_id = p.product_id 

    GROUP BY 
        c.customer_id, 
        c.customer_name
)

SELECT
    customer_id,
    customer_name,
    total_orders,
    customer_revenue,

    ROUND(
        customer_revenue / total_orders,
        2
    ) AS average_order_spend

FROM customer_summary

ORDER BY
    customer_revenue DESC

LIMIT 10;



-- ------------------------------------------------------------
-- 6. CUSTOMER VALUE SEGMENTATION
-- Business question:
-- Which customers are high, medium, or low value?
-- ------------------------------------------------------------

WITH customer_summary AS (

    SELECT 
        c.customer_id, 
        c.customer_name,

        COUNT(DISTINCT ord.order_id) AS total_orders,

        ROUND(
            SUM(oi.quantity * p.selling_price),
            2
        ) AS customer_revenue

    FROM customers AS c 

    LEFT JOIN orders AS ord
        ON c.customer_id = ord.customer_id

    LEFT JOIN order_items AS oi
        ON ord.order_id = oi.order_id

    LEFT JOIN products AS p 
        ON oi.product_id = p.product_id 

    GROUP BY 
        c.customer_id, 
        c.customer_name
)

SELECT
    customer_id,
    customer_name,
    total_orders,
    customer_revenue,

    ROUND(
        customer_revenue / total_orders,
        2
    ) AS average_order_spend,

    CASE
        WHEN customer_revenue >= 10000 THEN 'High Value'
        WHEN customer_revenue >= 5000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment

FROM customer_summary

ORDER BY
    customer_revenue DESC;



-- ------------------------------------------------------------
-- 7. REPEAT VS ONE-TIME CUSTOMER PERCENTAGE
-- Business question:
-- What percentage of customers are repeat customers versus
-- one-time customers?
--
-- Demonstrates:
-- Multiple CTEs
-- COUNT(DISTINCT)
-- CASE
-- GROUP BY
-- Window function
-- Percentage calculation
-- ------------------------------------------------------------

WITH customer_orders AS (

    SELECT
        c.customer_id,

        COUNT(DISTINCT ord.order_id) AS total_orders

    FROM customers AS c

    LEFT JOIN orders AS ord
        ON c.customer_id = ord.customer_id

    GROUP BY
        c.customer_id
),

customer_type AS (

    SELECT
        customer_id,
        total_orders,

        CASE
            WHEN total_orders = 1 THEN 'One-time Customer'
            WHEN total_orders > 1 THEN 'Repeat Customer'
            ELSE 'No Orders'
        END AS customer_type

    FROM customer_orders
)

SELECT
    customer_type,

    COUNT(*) AS customer_count,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage

FROM customer_type

WHERE
    customer_type != 'No Orders'

GROUP BY
    customer_type;