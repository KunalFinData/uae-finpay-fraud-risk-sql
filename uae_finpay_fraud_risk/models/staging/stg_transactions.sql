-- UAE FinPay Staging Layer
-- Cleans and standardises raw IEEE-CIS transactions
-- Adds UAE business context and internal escalation flags
-- CBUAE 2026: Internal escalation flags are operational
-- monitoring triggers only, NOT SAR/STR thresholds

WITH source AS (
    SELECT * FROM raw.transactions
),

cleaned AS (
    SELECT
        transaction_id,
        customer_id,
        transaction_date,
        CAST(amount_aed AS NUMERIC(12,2))    AS amount_aed,
        UPPER(emirate)                        AS emirate,
        LOWER(kyc_status)                     AS kyc_status,
        LOWER(payment_channel)                AS payment_channel,
        LOWER(merchant_category)              AS merchant_category,
        CAST(is_fraud AS INTEGER)             AS is_fraud,
        CAST(internal_escalation_40k
             AS INTEGER)                      AS internal_escalation_40k,
        CAST(internal_escalation_100k
             AS INTEGER)                      AS internal_escalation_100k,
        COALESCE(product_type, 'unknown')     AS product_type,
        COALESCE(card_network, 'unknown')     AS card_network,
        COALESCE(email_domain, 'unknown')     AS email_domain,
        DATE(transaction_date)                AS transaction_date_only,
        EXTRACT(HOUR FROM transaction_date)   AS transaction_hour,
        EXTRACT(MONTH FROM transaction_date)  AS transaction_month,
        TO_CHAR(transaction_date, 'YYYY-MM')  AS transaction_month_year
    FROM source
    WHERE transaction_id IS NOT NULL
      AND customer_id    IS NOT NULL
      AND amount_aed     > 0
)

SELECT * FROM cleaned