-- Business Problem 7
-- Monthly fraud trend with month on month change
-- Uses LAG() window function for MoM comparison
-- Identifies whether fraud is increasing or decreasing

WITH txn AS (
    SELECT * FROM {{ ref('stg_transactions') }}
),

monthly_stats AS (
    SELECT
        transaction_month_year,
        COUNT(*)                              AS total_transactions,
        SUM(is_fraud)                         AS fraud_transactions,
        SUM(amount_aed)                       AS total_volume_aed,
        ROUND(
            SUM(is_fraud)::NUMERIC
            / NULLIF(COUNT(*), 0) * 100
        , 2)                                  AS fraud_rate_pct
    FROM txn
    GROUP BY transaction_month_year
),

with_lag AS (
    SELECT
        transaction_month_year,
        total_transactions,
        fraud_transactions,
        total_volume_aed,
        fraud_rate_pct,
        LAG(fraud_rate_pct) OVER
        (ORDER BY transaction_month_year)     AS prev_month_fraud_rate,
        LAG(total_volume_aed) OVER
        (ORDER BY transaction_month_year)     AS prev_month_volume_aed
    FROM monthly_stats
)

SELECT
    transaction_month_year,
    total_transactions,
    fraud_transactions,
    ROUND(total_volume_aed::NUMERIC, 2)       AS total_volume_aed,
    fraud_rate_pct,
    prev_month_fraud_rate,
    ROUND(
        (fraud_rate_pct - prev_month_fraud_rate)
        ::NUMERIC
    , 2)                                      AS fraud_rate_mom_change,
    CASE
        WHEN fraud_rate_pct > prev_month_fraud_rate
        THEN 'INCREASING'
        WHEN fraud_rate_pct < prev_month_fraud_rate
        THEN 'DECREASING'
        ELSE 'STABLE'
    END                                       AS fraud_trend,
    ROUND(
        (total_volume_aed - prev_month_volume_aed)
        ::NUMERIC
    , 2)                                      AS volume_mom_change_aed
FROM with_lag
ORDER BY transaction_month_year