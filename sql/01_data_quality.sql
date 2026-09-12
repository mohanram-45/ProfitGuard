-- ============================================================
-- ProfitGuard
-- 01_data_quality.sql
-- Purpose:
-- Validate key relationships, required fields, and numeric values
-- across the core e-commerce tables before analysis.
-- ============================================================


-- ============================================================
-- 1. Check for order_items referencing nonexistent orders
-- Expected result: 0 rows
-- ============================================================

SELECT
    oi.order_item_id,
    oi.order_id
FROM order_items AS oi
LEFT JOIN orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- ============================================================
-- 2. Check for order_items referencing nonexistent products
-- Expected result: 0 rows
-- ============================================================

SELECT
    oi.order_item_id,
    oi.product_id
FROM order_items AS oi
LEFT JOIN products AS p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- ============================================================
-- 3. Check for invalid order-item quantities
-- Quantity should always be greater than 0
-- Expected result: 0 rows
-- ============================================================

SELECT
    order_item_id,
    order_id,
    product_id,
    quantity
FROM order_items
WHERE quantity <= 0;


-- ============================================================
-- 4. Check for invalid product prices
-- Selling price and cost price should both be greater than 0
-- Expected result: 0 rows
-- ============================================================

SELECT
    product_id,
    product_name,
    selling_price,
    cost_price
FROM products
WHERE selling_price <= 0
   OR cost_price <= 0;


-- ============================================================
-- 5. Check for missing critical order fields
-- Expected result: 0 rows
-- ============================================================

SELECT
    order_id,
    customer_id,
    order_date,
    status
FROM orders
WHERE order_id IS NULL
   OR customer_id IS NULL
   OR order_date IS NULL
   OR status IS NULL;


-- ============================================================
-- 6. Check for orders referencing nonexistent customers
-- Expected result: 0 rows
-- ============================================================

SELECT
    o.order_id,
    o.customer_id
FROM orders AS o
LEFT JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- ============================================================
-- 7. Check for refunds referencing nonexistent orders
-- Expected result: 0 rows
-- ============================================================

SELECT
    r.refund_id,
    r.order_id
FROM refunds AS r
LEFT JOIN orders AS o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


-- ============================================================
-- 8A. Check for invalid refund amounts
-- Refund amount should always be greater than 0
-- Expected result: 0 rows
-- ============================================================

SELECT
    refund_id,
    order_id,
    refund_amount
FROM refunds
WHERE refund_amount <= 0;


-- ============================================================
-- 8B. Check whether any refund exceeds the gross order value
-- Gross order value = SUM(quantity * selling_price)
-- Expected result: 0 rows
-- ============================================================

WITH order_values AS (

    SELECT
        oi.order_id,
        ROUND(
            SUM(oi.quantity * p.selling_price),
            2
        ) AS gross_order_value

    FROM order_items AS oi

    LEFT JOIN products AS p
        ON oi.product_id = p.product_id

    GROUP BY oi.order_id
)

SELECT
    r.refund_id,
    r.order_id,
    r.refund_amount,
    ov.gross_order_value
FROM refunds AS r
JOIN order_values AS ov
    ON r.order_id = ov.order_id
WHERE r.refund_amount > ov.gross_order_value;