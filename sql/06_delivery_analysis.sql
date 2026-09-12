-- ============================================================
-- PROFITGUARD
-- SECTION 6: DELIVERY ANALYSIS
-- ============================================================


-- ------------------------------------------------------------
-- 1. DELIVERY STATUS DISTRIBUTION
-- Business question:
-- How are deliveries distributed across different statuses?
-- ------------------------------------------------------------

SELECT
    delivery_status,
    COUNT(*) AS delivery_count

FROM deliveries

GROUP BY
    delivery_status

ORDER BY
    delivery_count DESC;



-- ------------------------------------------------------------
-- 2. DELIVERY SUCCESS RATE
-- Business question:
-- What percentage of deliveries were successfully delivered?
-- ------------------------------------------------------------

SELECT
    ROUND(
        SUM(
            CASE
                WHEN delivery_status = 'Delivered' THEN 1
                ELSE 0
            END
        ) * 100.0
        / COUNT(*),
        2
    ) AS delivery_success_rate_pct

FROM deliveries;



-- ------------------------------------------------------------
-- 3. DELIVERY FAILURE RATE
-- Business question:
-- What percentage of deliveries failed?
-- ------------------------------------------------------------

SELECT
    ROUND(
        SUM(
            CASE
                WHEN delivery_status = 'Failed' THEN 1
                ELSE 0
            END
        ) * 100.0
        / COUNT(*),
        2
    ) AS delivery_failure_rate_pct

FROM deliveries;



-- ------------------------------------------------------------
-- 4. AVERAGE DELIVERY DELAY
-- Business question:
-- On average, how many days late are deliveries?
-- ------------------------------------------------------------

SELECT
    ROUND(
        AVG(delay_days),
        2
    ) AS avg_delay_days

FROM deliveries;



-- ------------------------------------------------------------
-- 5. LATE DELIVERY RATE
-- Business question:
-- What percentage of deliveries arrived late?
--
-- delay_days > 0 means the delivery was late.
-- ------------------------------------------------------------

SELECT
    ROUND(
        SUM(
            CASE
                WHEN delay_days > 0 THEN 1
                ELSE 0
            END
        ) * 100.0
        / COUNT(*),
        2
    ) AS late_delivery_rate_pct

FROM deliveries;



-- ------------------------------------------------------------
-- 6. ON-TIME VS LATE DELIVERY COUNTS
-- Business question:
-- How many deliveries were on time versus late?
-- ------------------------------------------------------------

SELECT
    CASE
        WHEN delay_days > 0 THEN 'Late'
        ELSE 'On Time'
    END AS delivery_type,

    COUNT(*) AS delivery_count

FROM deliveries

GROUP BY
    CASE
        WHEN delay_days > 0 THEN 'Late'
        ELSE 'On Time'
    END

ORDER BY
    delivery_count DESC;



-- ------------------------------------------------------------
-- 7. REFUND RATE: LATE VS ON-TIME DELIVERIES
-- Business question:
-- Are late deliveries more likely to result in refunds?
-- ------------------------------------------------------------

WITH delivery_summary AS (

    SELECT
        order_id,

        CASE
            WHEN delay_days > 0 THEN 'Late'
            ELSE 'On Time'
        END AS delivery_type

    FROM deliveries
)

SELECT
    ds.delivery_type,

    COUNT(DISTINCT ds.order_id) AS total_orders,

    COUNT(DISTINCT r.order_id) AS refunded_orders,

    ROUND(
        COUNT(DISTINCT r.order_id) * 100.0
        / COUNT(DISTINCT ds.order_id),
        2
    ) AS refund_rate_pct

FROM delivery_summary AS ds

LEFT JOIN refunds AS r
    ON ds.order_id = r.order_id

GROUP BY
    ds.delivery_type

ORDER BY
    refund_rate_pct DESC;



-- ------------------------------------------------------------
-- 8. REFUND VALUE: LATE VS ON-TIME DELIVERIES
-- Business question:
-- Do late deliveries create higher refund losses?
-- ------------------------------------------------------------

WITH delivery_summary AS (

    SELECT
        order_id,

        CASE
            WHEN delay_days > 0 THEN 'Late'
            ELSE 'On Time'
        END AS delivery_type

    FROM deliveries
)

SELECT
    ds.delivery_type,

    COUNT(DISTINCT ds.order_id) AS total_orders,

    COUNT(DISTINCT r.order_id) AS refunded_orders,

    ROUND(
        COALESCE(SUM(r.refund_amount), 0),
        2
    ) AS total_refund_value,

    ROUND(
        COALESCE(AVG(r.refund_amount), 0),
        2
    ) AS avg_refund_value

FROM delivery_summary AS ds

LEFT JOIN refunds AS r
    ON ds.order_id = r.order_id

GROUP BY
    ds.delivery_type

ORDER BY
    total_refund_value DESC;



-- ------------------------------------------------------------
-- 9. DELIVERY STATUS + DELAY PERFORMANCE
-- Business question:
-- Which delivery statuses are associated with the most delay?
-- ------------------------------------------------------------

SELECT
    delivery_status,

    COUNT(*) AS total_deliveries,

    ROUND(
        AVG(delay_days),
        2
    ) AS avg_delay_days,

    SUM(
        CASE
            WHEN delay_days > 0 THEN 1
            ELSE 0
        END
    ) AS late_deliveries,

    ROUND(
        SUM(
            CASE
                WHEN delay_days > 0 THEN 1
                ELSE 0
            END
        ) * 100.0
        / COUNT(*),
        2
    ) AS late_delivery_rate_pct

FROM deliveries

GROUP BY
    delivery_status

ORDER BY
    avg_delay_days DESC;



-- ------------------------------------------------------------
-- 10. MOST DELAYED DELIVERIES
-- Business question:
-- Which orders experienced the highest delivery delays?
-- ------------------------------------------------------------

SELECT
    delivery_id,
    order_id,
    promised_date,
    delivery_date,
    delay_days,
    delivery_status

FROM deliveries

ORDER BY
    delay_days DESC

LIMIT 10;