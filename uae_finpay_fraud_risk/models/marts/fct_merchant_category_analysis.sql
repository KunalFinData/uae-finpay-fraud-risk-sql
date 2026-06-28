-- Business Problem 8
-- Merchant category fraud concentration
-- Identifies highest risk merchant categories
-- Guides fraud investment decisions

WITH txn AS (
    SELECT * FROM {{ ref('stg_transactions') }}
),

merchant_stats AS (
    SELECT
        merchant_category,
        COUNT(*)                              AS total_transactions,
        SUM(amount_aed)                       AS total_volume_aed,
        ROUND(AVG(amount_aed)::NUMERIC, 2)    AS avg_transaction_aed,
        SUM(is_fraud)                         AS fraud_transactions,
        ROUND(
            SUM(is_fraud)::NUMERIC
            / NULLIF(COUNT(*), 0) * 100
        , 2)                                  AS fraud_rate_pct,
        ROUND(
            SUM(CASE WHEN is_fraud = 1
                THEN amount_aed ELSE 0 END)
            ::NUMERIC
        , 2)                                  AS fraud_volume_aed,
        RANK() OVER
        (ORDER BY
            SUM(is_fraud)::NUMERIC
            / NULLIF(COUNT(*), 0) DESC
        )                                     AS fraud_rate_rank
    FROM txn
    GROUP BY merchant_category
)

SELECT
    merchant_category,
    total_transactions,
    ROUND(total_volume_aed::NUMERIC, 2)       AS total_volume_aed,
    avg_transaction_aed,
    fraud_transactions,
    fraud_rate_pct,
    fraud_volume_aed,
    fraud_rate_rank,
    CASE
        WHEN fraud_rate_pct >= 15 THEN 'CRITICAL_RISK'
        WHEN fraud_rate_pct >= 10 THEN 'HIGH_RISK'
        WHEN fraud_rate_pct >= 5  THEN 'MEDIUM_RISK'
        ELSE 'LOW_RISK'
    END                                       AS risk_category
FROM merchant_stats
ORDER BY fraud_rate_rank