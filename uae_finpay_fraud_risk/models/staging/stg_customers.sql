-- UAE FinPay Customer Staging Layer
-- Aggregates customer-level metrics from transactions
-- Used for segmentation and risk profiling

WITH txn AS (
    SELECT * FROM {{ ref('stg_transactions') }}
),

customer_summary AS (
    SELECT
        customer_id,
        COUNT(*)                              AS total_transactions,
        SUM(amount_aed)                       AS total_spend_aed,
        AVG(amount_aed)                       AS avg_transaction_aed,
        MAX(amount_aed)                       AS max_transaction_aed,
        MIN(transaction_date)                 AS first_transaction_date,
        MAX(transaction_date)                 AS last_transaction_date,
        SUM(is_fraud)                         AS total_fraud_transactions,
        MAX(kyc_status)                       AS kyc_status,
        MAX(emirate)                          AS emirate,
        MAX(payment_channel)                  AS preferred_channel,
        SUM(internal_escalation_40k)          AS escalation_40k_count,
        SUM(internal_escalation_100k)         AS escalation_100k_count,
        ROUND(
            SUM(is_fraud)::NUMERIC
            / NULLIF(COUNT(*), 0) * 100
        , 2)                                  AS fraud_rate_pct
    FROM txn
    GROUP BY customer_id
)

SELECT * FROM customer_summary