-- Business Problem 4
-- Customer transaction frequency segmentation
-- Low / Medium / High activity tiers
-- Foundation for targeted fraud intervention

WITH customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

segmented AS (
    SELECT
        customer_id,
        emirate,
        kyc_status,
        preferred_channel,
        total_transactions,
        total_spend_aed,
        avg_transaction_aed,
        fraud_rate_pct,
        risk_score_segment,
        CASE
            WHEN total_transactions >= 20  THEN 'HIGH_ACTIVITY'
            WHEN total_transactions >= 10  THEN 'MEDIUM_ACTIVITY'
            ELSE                                'LOW_ACTIVITY'
        END                               AS activity_tier,
        CASE
            WHEN total_spend_aed >= 50000  THEN 'HIGH_VALUE'
            WHEN total_spend_aed >= 10000  THEN 'MEDIUM_VALUE'
            ELSE                                'LOW_VALUE'
        END                               AS value_tier
    FROM (
        SELECT *,
            CASE
                WHEN fraud_rate_pct >= 30 THEN 'HIGH_RISK'
                WHEN fraud_rate_pct >= 10 THEN 'MEDIUM_RISK'
                ELSE 'LOW_RISK'
            END AS risk_score_segment
        FROM customers
    ) sub
)

SELECT * FROM segmented
ORDER BY total_spend_aed DESC