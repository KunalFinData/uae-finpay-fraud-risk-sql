-- Business Problem 5
-- High value customers fraud exposure analysis
-- Top 20% spenders — what % of fraud do they represent?
-- Key insight: premium segment risk concentration

WITH customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

percentile_calc AS (
    SELECT
        PERCENTILE_CONT(0.80) WITHIN GROUP
        (ORDER BY total_spend_aed)            AS p80_spend
    FROM customers
),

segmented AS (
    SELECT
        c.customer_id,
        c.emirate,
        c.total_spend_aed,
        c.total_fraud_transactions,
        c.fraud_rate_pct,
        c.kyc_status,
        CASE
            WHEN c.total_spend_aed >= p.p80_spend
            THEN 'HIGH_VALUE'
            ELSE 'STANDARD'
        END                                   AS customer_segment
    FROM customers c
    CROSS JOIN percentile_calc p
),

summary AS (
    SELECT
        customer_segment,
        COUNT(*)                              AS customer_count,
        ROUND(SUM(total_spend_aed)::NUMERIC
              , 2)                            AS total_spend_aed,
        SUM(total_fraud_transactions)         AS total_fraud_txns,
        ROUND(AVG(fraud_rate_pct)::NUMERIC
              , 2)                            AS avg_fraud_rate_pct,
        ROUND(
            COUNT(*)::NUMERIC
            / SUM(COUNT(*)) OVER () * 100
        , 2)                                  AS pct_of_customers,
        ROUND(
            SUM(total_fraud_transactions)::NUMERIC
            / SUM(SUM(total_fraud_transactions)) OVER () * 100
        , 2)                                  AS pct_of_total_fraud
    FROM segmented
    GROUP BY customer_segment
)

SELECT * FROM summary