-- ============================================================
-- PROFITGUARD
-- SECTION 8: MARKETING ANALYSIS
-- ============================================================


-- ------------------------------------------------------------
-- 1. TOTAL MARKETING SPEND
-- Business question:
-- How much has the business spent on marketing?
-- ------------------------------------------------------------

SELECT
    ROUND(
        SUM(marketing_spend),
        2
    ) AS total_marketing_spend

FROM marketing;



-- ------------------------------------------------------------
-- 2. TOTAL CUSTOMERS ACQUIRED
-- Business question:
-- How many customers were acquired through marketing?
-- ------------------------------------------------------------

SELECT
    SUM(customers_acquired) AS total_customers_acquired

FROM marketing;



-- ------------------------------------------------------------
-- 3. OVERALL CUSTOMER ACQUISITION COST
-- Business question:
-- How much does it cost, on average, to acquire one customer?
-- ------------------------------------------------------------

SELECT
    ROUND(
        SUM(marketing_spend)
        / SUM(customers_acquired),
        2
    ) AS overall_cac

FROM marketing;



-- ------------------------------------------------------------
-- 4. MARKETING SPEND BY CHANNEL
-- Business question:
-- Which marketing channels receive the most investment?
-- ------------------------------------------------------------

SELECT
    channel,

    ROUND(
        SUM(marketing_spend),
        2
    ) AS total_marketing_spend

FROM marketing

GROUP BY
    channel

ORDER BY
    total_marketing_spend DESC;



-- ------------------------------------------------------------
-- 5. CUSTOMERS ACQUIRED BY CHANNEL
-- Business question:
-- Which channels acquire the most customers?
-- ------------------------------------------------------------

SELECT
    channel,

    SUM(customers_acquired) AS total_customers_acquired

FROM marketing

GROUP BY
    channel

ORDER BY
    total_customers_acquired DESC;



-- ------------------------------------------------------------
-- 6. CUSTOMER ACQUISITION COST BY CHANNEL
-- Business question:
-- Which marketing channels acquire customers most efficiently?
-- ------------------------------------------------------------

SELECT
    channel,

    ROUND(
        SUM(marketing_spend),
        2
    ) AS total_spend,

    SUM(customers_acquired) AS customers_acquired,

    ROUND(
        SUM(marketing_spend)
        / SUM(customers_acquired),
        2
    ) AS calculated_cac

FROM marketing

GROUP BY
    channel

ORDER BY
    calculated_cac ASC;



-- ------------------------------------------------------------
-- 7. CHANNEL PERFORMANCE SUMMARY
-- Business question:
-- Compare spend, acquisition volume, and acquisition efficiency
-- across marketing channels.
-- ------------------------------------------------------------

SELECT
    channel,

    ROUND(
        SUM(marketing_spend),
        2
    ) AS total_spend,

    SUM(customers_acquired) AS customers_acquired,

    ROUND(
        AVG(customer_acquisition_cost),
        2
    ) AS avg_recorded_cac,

    ROUND(
        SUM(marketing_spend)
        / SUM(customers_acquired),
        2
    ) AS calculated_cac

FROM marketing

GROUP BY
    channel

ORDER BY
    calculated_cac ASC;



-- ------------------------------------------------------------
-- 8. MONTHLY MARKETING PERFORMANCE
-- Business question:
-- How do marketing spend and customer acquisition change over time?
-- ------------------------------------------------------------

SELECT
    month,

    ROUND(
        SUM(marketing_spend),
        2
    ) AS monthly_marketing_spend,

    SUM(customers_acquired) AS monthly_customers_acquired,

    ROUND(
        SUM(marketing_spend)
        / SUM(customers_acquired),
        2
    ) AS monthly_cac

FROM marketing

GROUP BY
    month

ORDER BY
    month;



-- ------------------------------------------------------------
-- 9. BEST CHANNEL BY CUSTOMER ACQUISITION
-- Business question:
-- Which channel acquired the highest number of customers?
-- ------------------------------------------------------------

SELECT
    channel,

    SUM(customers_acquired) AS total_customers_acquired

FROM marketing

GROUP BY
    channel

ORDER BY
    total_customers_acquired DESC

LIMIT 1;



-- ------------------------------------------------------------
-- 10. MOST COST-EFFICIENT CHANNEL
-- Business question:
-- Which channel has the lowest customer acquisition cost?
-- ------------------------------------------------------------

SELECT
    channel,

    ROUND(
        SUM(marketing_spend)
        / SUM(customers_acquired),
        2
    ) AS calculated_cac

FROM marketing

GROUP BY
    channel

ORDER BY
    calculated_cac ASC

LIMIT 1;



-- ------------------------------------------------------------
-- 11. LEAST COST-EFFICIENT CHANNEL
-- Business question:
-- Which channel has the highest customer acquisition cost?
-- ------------------------------------------------------------

SELECT
    channel,

    ROUND(
        SUM(marketing_spend)
        / SUM(customers_acquired),
        2
    ) AS calculated_cac

FROM marketing

GROUP BY
    channel

ORDER BY
    calculated_cac DESC

LIMIT 1;



-- ------------------------------------------------------------
-- 12. MARKETING SPEND SHARE BY CHANNEL
-- Business question:
-- What percentage of total marketing budget goes to each channel?
-- ------------------------------------------------------------

WITH channel_spend AS (

    SELECT
        channel,

        ROUND(
            SUM(marketing_spend),
            2
        ) AS channel_spend

    FROM marketing

    GROUP BY
        channel
)

SELECT
    channel,
    channel_spend,

    ROUND(
        channel_spend
        / SUM(channel_spend) OVER ()
        * 100,
        2
    ) AS spend_share_pct

FROM channel_spend

ORDER BY
    spend_share_pct DESC;



-- ------------------------------------------------------------
-- 13. CUSTOMER ACQUISITION SHARE BY CHANNEL
-- Business question:
-- What percentage of acquired customers comes from each channel?
-- ------------------------------------------------------------

WITH channel_acquisition AS (

    SELECT
        channel,

        SUM(customers_acquired) AS acquired_customers

    FROM marketing

    GROUP BY
        channel
)

SELECT
    channel,
    acquired_customers,

    ROUND(
        acquired_customers * 100.0
        / SUM(acquired_customers) OVER (),
        2
    ) AS acquisition_share_pct

FROM channel_acquisition

ORDER BY
    acquisition_share_pct DESC;



-- ------------------------------------------------------------
-- 14. MONTH-OVER-MONTH MARKETING SPEND CHANGE
-- Business question:
-- How is marketing spend changing from month to month?
-- ------------------------------------------------------------

WITH monthly_marketing AS (

    SELECT
        month,

        ROUND(
            SUM(marketing_spend),
            2
        ) AS monthly_spend

    FROM marketing

    GROUP BY
        month
)

SELECT
    month,
    monthly_spend,

    LAG(monthly_spend) OVER (
        ORDER BY month
    ) AS previous_month_spend,

    ROUND(
        (
            monthly_spend
            - LAG(monthly_spend) OVER (ORDER BY month)
        )
        /
        LAG(monthly_spend) OVER (ORDER BY month)
        * 100,
        2
    ) AS mom_spend_change_pct

FROM monthly_marketing

ORDER BY
    month;



-- ------------------------------------------------------------
-- 15. MONTH-OVER-MONTH CUSTOMER ACQUISITION CHANGE
-- Business question:
-- How is customer acquisition changing from month to month?
-- ------------------------------------------------------------

WITH monthly_acquisition AS (

    SELECT
        month,

        SUM(customers_acquired) AS customers_acquired

    FROM marketing

    GROUP BY
        month
)

SELECT
    month,
    customers_acquired,

    LAG(customers_acquired) OVER (
        ORDER BY month
    ) AS previous_month_customers,

    ROUND(
        (
            customers_acquired
            - LAG(customers_acquired) OVER (ORDER BY month)
        )
        * 100.0
        /
        LAG(customers_acquired) OVER (ORDER BY month),
        2
    ) AS mom_acquisition_change_pct

FROM monthly_acquisition

ORDER BY
    month;