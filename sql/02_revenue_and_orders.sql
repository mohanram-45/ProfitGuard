-- ============================================================
-- PROFITGUARD
-- SECTION 1: REVENUE & ORDERS
-- ============================================================


-- ------------------------------------------------------------
-- 1. GROSS REVENUE PER ORDER
-- Business question:
-- What is the value of each order before discounts?
-- ------------------------------------------------------------

SELECT
    oi.order_id,
    ROUND(
        SUM(oi.quantity * p.selling_price),
        2
    ) AS gross_revenue

FROM order_items AS oi

LEFT JOIN products AS p
    ON oi.product_id = p.product_id

GROUP BY
    oi.order_id

ORDER BY
    oi.order_id;



-- ------------------------------------------------------------
-- 2. NET REVENUE PER ORDER
-- Business question:
-- What is the value of each order after discounts?
-- ------------------------------------------------------------

SELECT
    ord.order_id,

    ROUND(
        SUM(oi.quantity * p.selling_price),
        2
    ) AS gross_revenue,

    ord.discount_amount,

    ROUND(
        SUM(oi.quantity * p.selling_price)
        - ord.discount_amount,
        2
    ) AS net_order_value

FROM orders AS ord

LEFT JOIN order_items AS oi
    ON ord.order_id = oi.order_id

LEFT JOIN products AS p
    ON oi.product_id = p.product_id

GROUP BY
    ord.order_id,
    ord.discount_amount

ORDER BY
    ord.order_id;



-- ------------------------------------------------------------
-- 3. TOTAL NUMBER OF ORDERS
-- Business question:
-- How many unique orders were placed?
-- ------------------------------------------------------------

SELECT
    COUNT(DISTINCT order_id) AS total_orders

FROM orders;



-- ------------------------------------------------------------
-- 4. AVERAGE ORDER VALUE
-- Business question:
-- What is the average net value of an order?
-- ------------------------------------------------------------

WITH order_value AS (

    SELECT
        ord.order_id,

        ROUND(
            SUM(oi.quantity * p.selling_price),
            2
        ) AS gross_revenue,

        ord.discount_amount,

        ROUND(
            SUM(oi.quantity * p.selling_price)
            - ord.discount_amount,
            2
        ) AS net_order_value

    FROM orders AS ord

    LEFT JOIN order_items AS oi
        ON ord.order_id = oi.order_id

    LEFT JOIN products AS p
        ON oi.product_id = p.product_id

    GROUP BY
        ord.order_id,
        ord.discount_amount
)

SELECT
    ROUND(
        AVG(net_order_value),
        2
    ) AS average_order_value

FROM order_value;



-- ------------------------------------------------------------
-- 5. MONTHLY NET REVENUE + MONTHLY ORDER VOLUME
-- Business question:
-- How much revenue was generated each month and how many
-- orders were placed?
-- ------------------------------------------------------------

WITH order_value AS (

    SELECT
        ord.order_id,

        DATE_TRUNC(
            'month',
            CAST(ord.order_date AS DATE)
        ) AS order_month,

        ROUND(
            SUM(oi.quantity * p.selling_price),
            2
        ) AS gross_revenue,

        ord.discount_amount,

        ROUND(
            SUM(oi.quantity * p.selling_price)
            - ord.discount_amount,
            2
        ) AS net_order_value

    FROM orders AS ord

    LEFT JOIN order_items AS oi
        ON ord.order_id = oi.order_id

    LEFT JOIN products AS p
        ON oi.product_id = p.product_id

    GROUP BY
        ord.order_id,
        ord.discount_amount,
        DATE_TRUNC(
            'month',
            CAST(ord.order_date AS DATE)
        )
)

SELECT
    DATE_FORMAT(
        CAST(order_month AS TIMESTAMP),
        '%b-%Y'
    ) AS month,

    ROUND(
        SUM(net_order_value),
        2
    ) AS net_revenue,

    COUNT(order_id) AS total_orders

FROM order_value

GROUP BY
    order_month

ORDER BY
    order_month;



-- ------------------------------------------------------------
-- 6. MONTH-OVER-MONTH REVENUE GROWTH
-- Business question:
-- How is revenue changing from one month to the next?
--
-- Demonstrates:
-- CTEs
-- Aggregation
-- DATE_TRUNC
-- Window function LAG()
-- MoM growth %
-- ------------------------------------------------------------

WITH order_value AS (

    SELECT
        ord.order_id,

        DATE_TRUNC(
            'month',
            CAST(ord.order_date AS DATE)
        ) AS order_month,

        ROUND(
            SUM(oi.quantity * p.selling_price),
            2
        ) AS gross_revenue,

        ord.discount_amount,

        ROUND(
            SUM(oi.quantity * p.selling_price)
            - ord.discount_amount,
            2
        ) AS net_order_value

    FROM orders AS ord

    LEFT JOIN order_items AS oi
        ON ord.order_id = oi.order_id

    LEFT JOIN products AS p
        ON oi.product_id = p.product_id

    GROUP BY
        ord.order_id,
        ord.discount_amount,
        DATE_TRUNC(
            'month',
            CAST(ord.order_date AS DATE)
        )
),

monthly_revenue AS (

    SELECT
        order_month,

        ROUND(
            SUM(net_order_value),
            2
        ) AS net_revenue,

        COUNT(order_id) AS total_orders

    FROM order_value

    GROUP BY
        order_month
)

SELECT
    DATE_FORMAT(
        CAST(order_month AS TIMESTAMP),
        '%b-%Y'
    ) AS month,

    net_revenue,

    total_orders,

    ROUND(
        (
            net_revenue
            - LAG(net_revenue) OVER (
                ORDER BY order_month
            )
        )
        /
        LAG(net_revenue) OVER (
            ORDER BY order_month
        )
        * 100,
        2
    ) AS mom_growth_pct

FROM monthly_revenue

ORDER BY
    order_month;