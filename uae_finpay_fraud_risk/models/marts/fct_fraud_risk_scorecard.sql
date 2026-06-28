-- Business Problem 1 and 2
-- Fraud velocity detection and risk scoring
-- Customers with 3+ fraud transactions in 24 hours
-- Risk score 0-100 per customer

WITH txn AS (
    SELECT * FROM {{ ref('stg_transactions') }}
),

daily_fraud AS (
    SELECT
        customer_id,
        transaction_date_only,
        COUNT(*)                          AS total_txns,
        SUM(is_fraud)                     AS fraud_txns,
        SUM(amount_aed)                   AS daily_spend_aed
    FROM txn
    GROUP BY customer_id, transaction_date_only
),

customer_stats AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

risk_scored AS (
    SELECT
        cs.customer_id,
        cs.total_transactions,
        cs.total_spend_aed,
        cs.total_fraud_transactions,
        cs.fraud_rate_pct,
        cs.kyc_status,
        cs.emirate,
        cs.preferred_channel,
        cs.escalation_40k_count,
        CASE
            WHEN cs.fraud_rate_pct >= 50  THEN 90
            WHEN cs.fraud_rate_pct >= 30  THEN 75
            WHEN cs.fraud_rate_pct >= 15  THEN 60
            WHEN cs.fraud_rate_pct >= 5   THEN 40
            WHEN cs.fraud_rate_pct >= 1   THEN 20
            ELSE 5
        END
        +
        CASE
            WHEN cs.kyc_status = 'rejected' THEN 10
            WHEN cs.kyc_status = 'pending'  THEN 5
            ELSE 0
        END                               AS risk_score,
        CASE
            WHEN cs.fraud_rate_pct >= 30
              OR cs.kyc_status = 'rejected' THEN 'HIGH'
            WHEN cs.fraud_rate_pct >= 10
              OR cs.kyc_status = 'pending'  THEN 'MEDIUM'
            ELSE 'LOW'
        END                               AS risk_tier
    FROM customer_stats cs
)

SELECT * FROM risk_scored
ORDER BY risk_score DESC