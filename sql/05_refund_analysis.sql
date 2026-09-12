-- ============================================================
-- PROFITGUARD
-- SECTION 5: REFUND ANALYSIS
-- ============================================================


-- ------------------------------------------------------------
-- 1. TOTAL REFUNDED AMOUNT
-- Business question:
-- How much money has been refunded in total?
-- ------------------------------------------------------------

SELECT
    ROUND(
        SUM(refund_amount),
        2
    ) AS total_refund_amount

FROM refunds;



-- ------------------------------------------------------------
-- 2. NUMBER OF REFUNDED ORDERS
-- Business question:
-- How many unique orders were refunded?
-- ------------------------------------------------------------

SELECT
    COUNT(DISTINCT order_id) AS refunded_orders

FROM refunds;



-- ------------------------------------------------------------
-- 3. REFUND RATE
-- Business question:
-- What percentage of all orders resulted in a refund?
-- ------------------------------------------------------------

SELECT
    ROUND(
        COUNT(DISTINCT r.order_id) * 100.0
        / COUNT(DISTINCT o.order_id),
        2
    ) AS refund_rate_pct

FROM orders AS o

LEFT JOIN refunds AS r
    ON o.order_id = r.order_id;



-- ------------------------------------------------------------
-- 4. REFUNDED ORDER PRODUCT INSPECTION
-- Business question:
-- Which products are present inside refunded orders?
--
-- This is an inspection query.
-- Do NOT directly sum refund_amount by product here because
-- one refunded order can contain multiple products.
-- ------------------------------------------------------------

SELECT
    r.order_id,
    r.refund_amount,
    p.product_name,

    ROUND(
        oi.quantity * p.selling_price,
        2
    ) AS line_value

FROM refunds AS r

LEFT JOIN order_items AS oi
    ON r.order_id = oi.order_id

LEFT JOIN products AS p
    ON oi.product_id = p.product_id;



-- ------------------------------------------------------------
-- 5. REFUND ALLOCATION BY PRODUCT LINE
-- Business question:
-- How much of each order-level refund should be attributed
-- to each product line?
--
-- Refunds are allocated proportionally based on each product
-- line's share of the gross order value.
-- ------------------------------------------------------------

WITH order_value AS (

    SELECT
        r.order_id,
        r.refund_amount,
        p.product_id,
        p.product_name,

        ROUND(
            oi.quantity * p.selling_price,
            2
        ) AS line_value,

        ROUND(
            SUM(oi.quantity * p.selling_price)
            OVER (
                PARTITION BY r.order_id
            ),
            2
        ) AS order_total

    FROM refunds AS r

    LEFT JOIN order_items AS oi
        ON r.order_id = oi.order_id

    LEFT JOIN products AS p
        ON oi.product_id = p.product_id
)

SELECT
    order_id,
    product_id,
    product_name,
    line_value,
    order_total,

    ROUND(
        line_value * 100.0 / order_total,
        2
    ) AS line_share_pct,

    ROUND(
        refund_amount * line_value / order_total,
        2
    ) AS allocated_refund

FROM order_value;



-- ------------------------------------------------------------
-- 6. TOP 10 PRODUCTS BY REFUND LOSS
-- Business question:
-- Which products are associated with the highest refund losses?
--
-- Important:
-- The full refund amount is NOT duplicated across every product.
-- It is allocated proportionally to each line's order value.
-- ------------------------------------------------------------

WITH order_value AS (

    SELECT
        r.order_id,
        r.refund_amount,
        p.product_id,
        p.product_name,

        ROUND(
            oi.quantity * p.selling_price,
            2
        ) AS line_value,

        ROUND(
            SUM(oi.quantity * p.selling_price)
            OVER (
                PARTITION BY r.order_id
            ),
            2
        ) AS order_total

    FROM refunds AS r

    LEFT JOIN order_items AS oi
        ON r.order_id = oi.order_id

    LEFT JOIN products AS p
        ON oi.product_id = p.product_id
),

allocated_refunds AS (

    SELECT
        order_id,
        product_id,
        product_name,

        ROUND(
            refund_amount * line_value / order_total,
            2
        ) AS allocated_refund

    FROM order_value
)

SELECT
    product_id,
    product_name,

    ROUND(
        SUM(allocated_refund),
        2
    ) AS total_refund_value

FROM allocated_refunds

GROUP BY
    product_id,
    product_name

ORDER BY
    total_refund_value DESC

LIMIT 10;



-- ------------------------------------------------------------
-- 7. REFUND LOSS BY CATEGORY
-- Business question:
-- Which product categories are associated with the highest
-- refund losses?
-- ------------------------------------------------------------

WITH order_value AS (

    SELECT
        r.order_id,
        r.refund_amount,
        p.category,

        ROUND(
            oi.quantity * p.selling_price,
            2
        ) AS line_value,

        ROUND(
            SUM(oi.quantity * p.selling_price)
            OVER (
                PARTITION BY r.order_id
            ),
            2
        ) AS order_total

    FROM refunds AS r

    LEFT JOIN order_items AS oi
        ON r.order_id = oi.order_id

    LEFT JOIN products AS p
        ON oi.product_id = p.product_id
),

allocated_refunds AS (

    SELECT
        order_id,
        category,

        ROUND(
            refund_amount * line_value / order_total,
            2
        ) AS allocated_refund

    FROM order_value
)

SELECT
    category,

    ROUND(
        SUM(allocated_refund),
        2
    ) AS total_refund_value

FROM allocated_refunds

GROUP BY
    category

ORDER BY
    total_refund_value DESC;