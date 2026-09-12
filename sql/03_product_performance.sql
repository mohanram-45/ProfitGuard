-- ============================================================
-- PROFITGUARD
-- SECTION 3: PRODUCT PERFORMANCE
-- ============================================================


-- ------------------------------------------------------------
-- 1. REVENUE BY PRODUCT
-- Business question:
-- Which products generate the most revenue?
-- ------------------------------------------------------------

SELECT
    p.product_id,
    p.product_name,

    ROUND(
        SUM(oi.quantity * p.selling_price),
        2
    ) AS product_revenue

FROM products AS p

LEFT JOIN order_items AS oi
    ON p.product_id = oi.product_id

GROUP BY
    p.product_id,
    p.product_name

ORDER BY
    product_revenue DESC;



-- ------------------------------------------------------------
-- 2. REVENUE BY CATEGORY
-- Business question:
-- Which product categories generate the most revenue?
-- ------------------------------------------------------------

SELECT
    p.category,

    ROUND(
        SUM(oi.quantity * p.selling_price),
        2
    ) AS category_revenue

FROM products AS p

LEFT JOIN order_items AS oi
    ON p.product_id = oi.product_id

GROUP BY
    p.category

ORDER BY
    category_revenue DESC;



-- ------------------------------------------------------------
-- 3. UNITS SOLD BY PRODUCT
-- Business question:
-- Which products sell the highest quantity?
-- ------------------------------------------------------------

SELECT
    p.product_id,
    p.product_name,

    SUM(oi.quantity) AS units_sold

FROM products AS p

LEFT JOIN order_items AS oi
    ON p.product_id = oi.product_id

GROUP BY
    p.product_id,
    p.product_name

ORDER BY
    units_sold DESC;



-- ------------------------------------------------------------
-- 4. TOP 10 PRODUCTS BY REVENUE
-- Business question:
-- Which are the top 10 highest revenue generating products?
-- ------------------------------------------------------------

SELECT
    p.product_id,
    p.product_name,

    ROUND(
        SUM(oi.quantity * p.selling_price),
        2
    ) AS product_revenue

FROM products AS p

LEFT JOIN order_items AS oi
    ON p.product_id = oi.product_id

GROUP BY
    p.product_id,
    p.product_name

ORDER BY
    product_revenue DESC

LIMIT 10;



-- ------------------------------------------------------------
-- 5. BOTTOM 10 PRODUCTS BY REVENUE
-- Business question:
-- Which products generate the least revenue?
-- ------------------------------------------------------------

SELECT
    p.product_id,
    p.product_name,

    ROUND(
        SUM(oi.quantity * p.selling_price),
        2
    ) AS product_revenue

FROM products AS p

LEFT JOIN order_items AS oi
    ON p.product_id = oi.product_id

GROUP BY
    p.product_id,
    p.product_name

ORDER BY
    product_revenue ASC

LIMIT 10;



-- ------------------------------------------------------------
-- 6. PRODUCT REVENUE RANKING
-- Business question:
-- How does each product rank based on revenue?
--
-- Demonstrates:
-- CTE
-- Aggregation
-- Window function RANK()
-- ------------------------------------------------------------

WITH product_rev AS (

    SELECT
        p.product_id,
        p.product_name,

        ROUND(
            SUM(oi.quantity * p.selling_price),
            2
        ) AS product_revenue

    FROM products AS p

    LEFT JOIN order_items AS oi
        ON p.product_id = oi.product_id

    GROUP BY
        p.product_id,
        p.product_name
)

SELECT
    product_id,
    product_name,
    product_revenue,

    RANK() OVER (
        ORDER BY product_revenue DESC
    ) AS revenue_rank

FROM product_rev

ORDER BY
    revenue_rank;



-- ------------------------------------------------------------
-- 7. CATEGORY CONTRIBUTION TO TOTAL REVENUE
-- Business question:
-- What percentage of total product revenue is contributed
-- by each category?
--
-- Demonstrates:
-- CTE
-- Aggregation
-- Window function SUM() OVER()
-- Percentage calculation
-- ------------------------------------------------------------

WITH category_rev AS (

    SELECT
        p.category,

        ROUND(
            SUM(oi.quantity * p.selling_price),
            2
        ) AS category_revenue

    FROM products AS p

    LEFT JOIN order_items AS oi
        ON p.product_id = oi.product_id

    GROUP BY
        p.category
)

SELECT
    category,
    category_revenue,

    ROUND(
        category_revenue
        / SUM(category_revenue) OVER ()
        * 100,
        2
    ) AS revenue_share_pct

FROM category_rev

ORDER BY
    revenue_share_pct DESC;