# Data Dictionary — UAE FinPay
## Shared Across All 7 UAE FinPay Projects

| Field | Type | Description |
|-------|------|-------------|
| transaction_id | VARCHAR | Unique transaction ID — TXN_UAE_[ID] |
| customer_id | VARCHAR | Unique customer ID — UAE_CUST_[ID] |
| transaction_date | TIMESTAMP | Date and time of transaction |
| amount_aed | DECIMAL | Transaction amount in UAE Dirhams |
| emirate | VARCHAR | UAE emirate — Dubai, Abu Dhabi, Sharjah, Ajman, Ras Al Khaimah |
| kyc_status | VARCHAR | KYC verification status — verified, pending, rejected |
| payment_channel | VARCHAR | Payment method — card, wallet, bank_transfer |
| merchant_category | VARCHAR | Merchant type — retail, ecommerce, food_beverage, transport, electronics, travel |
| is_fraud | INTEGER | Fraud label — 1 = fraud, 0 = legitimate |
| internal_escalation_40k | INTEGER | Operational monitoring flag for transactions above AED 40,000 |
| internal_escalation_100k | INTEGER | Operational monitoring flag for transactions above AED 100,000 |
| product_type | VARCHAR | Product category from source data |
| card_network | VARCHAR | Card network — visa, mastercard, discover, amex |
| email_domain | VARCHAR | Customer email domain |
| risk_score | INTEGER | Customer risk score 0-100. Derived from fraud rate and KYC status |
| risk_tier | VARCHAR | Risk classification — HIGH, MEDIUM, LOW |
| activity_tier | VARCHAR | Transaction frequency — HIGH_ACTIVITY, MEDIUM_ACTIVITY, LOW_ACTIVITY |
| value_tier | VARCHAR | Spend level — HIGH_VALUE, MEDIUM_VALUE, LOW_VALUE |

## Critical Note on Escalation Flags
internal_escalation_40k and internal_escalation_100k are
INTERNAL OPERATIONAL MONITORING TRIGGERS only.

CBUAE SAR/STR filing has NO monetary threshold as of June 2026.
Reporting is triggered by reasonable suspicion per Federal
Decree-Law No.(10) of 2025 and Cabinet Resolution No.(134) of 2025.

A transaction of AED 1 is as reportable as AED 10,000,000
if reasonable suspicion exists.

## Risk Score Calculation
- Score 0-100 derived from customer fraud rate percentage
- KYC rejected adds 10 points
- KYC pending adds 5 points
- HIGH risk: score above 70 or KYC rejected
- MEDIUM risk: score 40-70 or KYC pending
- LOW risk: score below 40 with verified KYC