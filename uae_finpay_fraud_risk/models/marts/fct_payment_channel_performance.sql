-- Business Problem 6
-- Payment channel adoption and fraud analysis
-- Card vs wallet vs bank transfer
-- Which channel has highest fraud AND highest revenue?

WITH txn AS (
    SELECT * FROM {{ ref('stg_transactions') }}
),

channel_stats AS (
    SELECT
        payment_channel,
        emirate,
        COUNT(*)                              AS total_transactions,
        SUM(amount_aed)                       AS total_volume_aed,
        ROUND(AVG(amount_aed)::NUMERIC, 2)    AS avg_transaction_aed,
        SUM(is_fraud)                         AS fraud_transactions,
        ROUND(
            SUM(is_fraud)::NUMERIC
            / NULLIF(COUNT(*), 0) * 100
        , 2)                                  AS fraud_rate_pct,
        ROUND(
            COUNT(*)::NUMERIC
            / SUM(COUNT(*)) OVER
            (PARTITION BY emirate) * 100
        , 2)                                  AS channel_share_pct
    FROM txn
    GROUP BY payment_channel, emirate
)

SELECT * FROM channel_stats
ORDER BY emirate, total_volume_aed DESC