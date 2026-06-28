-- Business Problem 9, 10, 11
-- Behavior-based detection per CBUAE 2026 guidance
-- Structuring patterns, velocity anomalies,
-- dormant account reactivation
-- NO fixed monetary threshold for SAR/STR
-- Suspicion-based per Federal Decree-Law No.10/2025

WITH txn AS (
    SELECT * FROM {{ ref('stg_transactions') }}
),

daily_customer AS (
    SELECT
        customer_id,
        transaction_date_only,
        COUNT(*)                              AS daily_txn_count,
        SUM(amount_aed)                       AS daily_total_aed,
        AVG(amount_aed)                       AS daily_avg_aed,
        MAX(amount_aed)                       AS daily_max_aed,
        SUM(is_fraud)                         AS daily_fraud_count
    FROM txn
    GROUP BY customer_id, transaction_date_only
),

customer_baseline AS (
    SELECT
        customer_id,
        AVG(daily_total_aed)                  AS baseline_avg_aed,
        STDDEV(daily_total_aed)               AS baseline_std_aed,
        COUNT(DISTINCT transaction_date_only) AS active_days,
        MIN(transaction_date_only)            AS first_active_date,
        MAX(transaction_date_only)            AS last_active_date
    FROM daily_customer
    GROUP BY customer_id
),

risk_flags AS (
    SELECT
        dc.customer_id,
        dc.transaction_date_only,
        dc.daily_txn_count,
        ROUND(dc.daily_total_aed::NUMERIC, 2) AS daily_total_aed,
        ROUND(dc.daily_avg_aed::NUMERIC, 2)   AS daily_avg_aed,
        ROUND(cb.baseline_avg_aed::NUMERIC, 2) AS baseline_avg_aed,
        cb.active_days,
        CASE
            WHEN dc.daily_txn_count >= 5
             AND dc.daily_avg_aed    < 40000
             AND dc.daily_total_aed  > 100000
             AND dc.daily_max_aed    < 40000
            THEN 'STRUCTURING_PATTERN'
            ELSE 'NORMAL'
        END                                   AS structuring_flag,
        CASE
            WHEN cb.baseline_std_aed > 0
             AND dc.daily_total_aed  >
                 cb.baseline_avg_aed
                 + (3 * cb.baseline_std_aed)
            THEN 'VELOCITY_ANOMALY_HIGH'
            WHEN cb.baseline_std_aed > 0
             AND dc.daily_total_aed  >
                 cb.baseline_avg_aed
                 + (2 * cb.baseline_std_aed)
            THEN 'VELOCITY_ANOMALY_MEDIUM'
            ELSE 'NORMAL'
        END                                   AS velocity_flag,
        CASE
            WHEN cb.active_days <= 2
             AND dc.daily_total_aed > 10000
            THEN 'DORMANT_REACTIVATION_HIGH_VALUE'
            WHEN cb.active_days <= 2
            THEN 'DORMANT_REACTIVATION'
            ELSE 'NORMAL'
        END                                   AS dormant_flag
    FROM daily_customer dc
    JOIN customer_baseline cb
      ON dc.customer_id = cb.customer_id
)

SELECT
    *,
    CASE
        WHEN structuring_flag != 'NORMAL'
          OR velocity_flag     = 'VELOCITY_ANOMALY_HIGH'
          OR dormant_flag      = 'DORMANT_REACTIVATION_HIGH_VALUE'
        THEN 'HIGH'
        WHEN velocity_flag = 'VELOCITY_ANOMALY_MEDIUM'
          OR dormant_flag  = 'DORMANT_REACTIVATION'
        THEN 'MEDIUM'
        ELSE 'LOW'
    END                                       AS overall_alert_priority
FROM risk_flags
WHERE structuring_flag  != 'NORMAL'
   OR velocity_flag     != 'NORMAL'
   OR dormant_flag      != 'NORMAL'
ORDER BY overall_alert_priority,
         daily_total_aed DESC