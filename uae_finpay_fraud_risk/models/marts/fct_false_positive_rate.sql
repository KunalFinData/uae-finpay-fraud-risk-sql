-- Business Problem 3
-- False positive rate calculation
-- Legitimate transactions incorrectly flagged
-- Key metric for fraud model performance

WITH txn AS (
    SELECT * FROM {{ ref('stg_transactions') }}
),

flagged_analysis AS (
    SELECT
        emirate,
        payment_channel,
        merchant_category,
        COUNT(*)                              AS total_transactions,
        SUM(is_fraud)                         AS confirmed_fraud,
        SUM(internal_escalation_40k)          AS flagged_40k,
        SUM(
            CASE
                WHEN internal_escalation_40k = 1
                 AND is_fraud = 0
                THEN 1 ELSE 0
            END
        )                                     AS false_positives_40k,
        ROUND(
            SUM(
                CASE
                    WHEN internal_escalation_40k = 1
                     AND is_fraud = 0
                    THEN 1 ELSE 0
                END
            )::NUMERIC
            / NULLIF(SUM(internal_escalation_40k), 0) * 100
        , 2)                                  AS false_positive_rate_pct
    FROM txn
    GROUP BY emirate, payment_channel, merchant_category
)

SELECT * FROM flagged_analysis
ORDER BY false_positive_rate_pct DESC