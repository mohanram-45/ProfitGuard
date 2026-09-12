-- ============================================================
-- PROFITGUARD
-- SECTION 7: PAYMENT ANALYSIS
-- ============================================================


-- ------------------------------------------------------------
-- 1. PAYMENT STATUS DISTRIBUTION
-- Business question:
-- How are payments distributed across different statuses?
-- ------------------------------------------------------------

SELECT
    payment_status,
    COUNT(*) AS payment_count

FROM payments

GROUP BY
    payment_status

ORDER BY
    payment_count DESC;



-- ------------------------------------------------------------
-- 2. PAYMENT METHOD DISTRIBUTION
-- Business question:
-- Which payment methods are used most often?
-- ------------------------------------------------------------

SELECT
    payment_method,
    COUNT(*) AS payment_count

FROM payments

GROUP BY
    payment_method

ORDER BY
    payment_count DESC;



-- ------------------------------------------------------------
-- 3. SUCCESSFUL PAYMENT RATE
-- Business question:
-- What percentage of payments were successful?
-- ------------------------------------------------------------

SELECT
    ROUND(
        SUM(
            CASE
                WHEN payment_status = 'Success' THEN 1
                ELSE 0
            END
        ) * 100.0
        / COUNT(*),
        2
    ) AS successful_payment_rate_pct

FROM payments;



-- ------------------------------------------------------------
-- 4. FAILED PAYMENT RATE
-- Business question:
-- What percentage of payments failed?
-- ------------------------------------------------------------

SELECT
    ROUND(
        SUM(
            CASE
                WHEN payment_status = 'Failed' THEN 1
                ELSE 0
            END
        ) * 100.0
        / COUNT(*),
        2
    ) AS failed_payment_rate_pct

FROM payments;



-- ------------------------------------------------------------
-- 5. TOTAL PAYMENT VALUE BY STATUS
-- Business question:
-- How much payment value is successful, failed, pending, etc.?
-- ------------------------------------------------------------

SELECT
    payment_status,

    ROUND(
        SUM(payment_amount),
        2
    ) AS total_payment_value

FROM payments

GROUP BY
    payment_status

ORDER BY
    total_payment_value DESC;



-- ------------------------------------------------------------
-- 6. REVENUE BY PAYMENT METHOD
-- Business question:
-- Which payment methods generate the most successful payment value?
-- ------------------------------------------------------------

SELECT
    payment_method,

    ROUND(
        SUM(payment_amount),
        2
    ) AS successful_payment_value

FROM payments

WHERE
    payment_status = 'Success'

GROUP BY
    payment_method

ORDER BY
    successful_payment_value DESC;



-- ------------------------------------------------------------
-- 7. PAYMENT METHOD SUCCESS RATE
-- Business question:
-- Which payment methods have the highest success rates?
-- ------------------------------------------------------------

SELECT
    payment_method,

    COUNT(*) AS total_payments,

    SUM(
        CASE
            WHEN payment_status = 'Success' THEN 1
            ELSE 0
        END
    ) AS successful_payments,

    ROUND(
        SUM(
            CASE
                WHEN payment_status = 'Success' THEN 1
                ELSE 0
            END
        ) * 100.0
        / COUNT(*),
        2
    ) AS success_rate_pct

FROM payments

GROUP BY
    payment_method

ORDER BY
    success_rate_pct DESC;



-- ------------------------------------------------------------
-- 8. AVERAGE PAYMENT VALUE BY METHOD
-- Business question:
-- What is the average payment amount for each payment method?
-- ------------------------------------------------------------

SELECT
    payment_method,

    ROUND(
        AVG(payment_amount),
        2
    ) AS avg_payment_value

FROM payments

GROUP BY
    payment_method

ORDER BY
    avg_payment_value DESC;



-- ------------------------------------------------------------
-- 9. FAILED PAYMENT VALUE BY METHOD
-- Business question:
-- Which payment methods are associated with the highest
-- failed payment value?
-- ------------------------------------------------------------

SELECT
    payment_method,

    COUNT(*) AS failed_payments,

    ROUND(
        SUM(payment_amount),
        2
    ) AS failed_payment_value

FROM payments

WHERE
    payment_status = 'Failed'

GROUP BY
    payment_method

ORDER BY
    failed_payment_value DESC;



-- ------------------------------------------------------------
-- 10. PAYMENT METHOD PERFORMANCE SUMMARY
-- Business question:
-- Compare volume, value, and success rate across payment methods.
-- ------------------------------------------------------------

SELECT
    payment_method,

    COUNT(*) AS total_payments,

    ROUND(
        SUM(payment_amount),
        2
    ) AS total_payment_value,

    ROUND(
        AVG(payment_amount),
        2
    ) AS avg_payment_value,

    SUM(
        CASE
            WHEN payment_status = 'Success' THEN 1
            ELSE 0
        END
    ) AS successful_payments,

    SUM(
        CASE
            WHEN payment_status = 'Failed' THEN 1
            ELSE 0
        END
    ) AS failed_payments,

    ROUND(
        SUM(
            CASE
                WHEN payment_status = 'Success' THEN 1
                ELSE 0
            END
        ) * 100.0
        / COUNT(*),
        2
    ) AS success_rate_pct

FROM payments

GROUP BY
    payment_method

ORDER BY
    success_rate_pct DESC;



-- ------------------------------------------------------------
-- 11. PAYMENT STATUS VS REFUNDS
-- Business question:
-- Are refunded orders concentrated in particular payment statuses?
-- ------------------------------------------------------------

SELECT
    p.payment_status,

    COUNT(DISTINCT p.order_id) AS total_orders,

    COUNT(DISTINCT r.order_id) AS refunded_orders,

    ROUND(
        COUNT(DISTINCT r.order_id) * 100.0
        / COUNT(DISTINCT p.order_id),
        2
    ) AS refund_rate_pct

FROM payments AS p

LEFT JOIN refunds AS r
    ON p.order_id = r.order_id

GROUP BY
    p.payment_status

ORDER BY
    refund_rate_pct DESC;



-- ------------------------------------------------------------
-- 12. PAYMENT METHOD VS REFUNDS
-- Business question:
-- Which payment methods are associated with higher refund rates?
-- ------------------------------------------------------------

SELECT
    p.payment_method,

    COUNT(DISTINCT p.order_id) AS total_orders,

    COUNT(DISTINCT r.order_id) AS refunded_orders,

    ROUND(
        COUNT(DISTINCT r.order_id) * 100.0
        / COUNT(DISTINCT p.order_id),
        2
    ) AS refund_rate_pct

FROM payments AS p

LEFT JOIN refunds AS r
    ON p.order_id = r.order_id

GROUP BY
    p.payment_method

ORDER BY
    refund_rate_pct DESC;