# Data Dictionary — UAE FinPay
## Project 1: Payment Fraud Detection & Risk Intelligence Engine

---

## Core Transaction & Customer Fields

| Field | Type | Description |
|-------|------|-------------|
| transaction_id | VARCHAR | Unique transaction ID — format: TXN_UAE_[ID] |
| customer_id | VARCHAR | Unique customer ID — format: UAE_CUST_[ID] |
| transaction_date | TIMESTAMP | Date and time of transaction (UTC+4, UAE local time) |
| amount_aed | DECIMAL | Transaction amount in UAE Dirhams (AED) |
| emirate | VARCHAR | UAE emirate — Dubai, Abu Dhabi, Sharjah, Ajman, Ras Al Khaimah |
| kyc_status | VARCHAR | KYC verification status — verified, pending, rejected |
| payment_channel | VARCHAR | Payment method — card, wallet, bank_transfer |
| merchant_category | VARCHAR | Merchant type — retail, ecommerce, food_beverage, transport, electronics, travel |
| is_fraud | INTEGER | Fraud label — 1 = fraud, 0 = legitimate |
| internal_escalation_40k | INTEGER | Internal operational monitoring flag for transactions above AED 40,000. NOT a SAR/STR threshold — see COMPLIANCE.md |
| internal_escalation_100k | INTEGER | Internal operational monitoring flag for transactions above AED 100,000. NOT a SAR/STR threshold — see COMPLIANCE.md |
| product_type | VARCHAR | Product category from source data |
| card_network | VARCHAR | Card network — visa, mastercard, discover, amex |
| email_domain | VARCHAR | Customer email domain |

---

## Derived Risk & Segmentation Fields

| Field | Type | Description |
|-------|------|-------------|
| risk_score | INTEGER | Customer risk score 0-100 — derived from fraud rate and KYC status |
| risk_tier | VARCHAR | Risk classification — HIGH (score above 70 or KYC rejected), MEDIUM (score 40-70 or KYC pending), LOW (score below 40 with verified KYC) |
| activity_tier | VARCHAR | Transaction frequency — HIGH_ACTIVITY, MEDIUM_ACTIVITY, LOW_ACTIVITY |
| value_tier | VARCHAR | Spend level — HIGH_VALUE (top 20%), MEDIUM_VALUE, LOW_VALUE |

---

## Analytical Model Output Fields

| Field | Type | Description |
|-------|------|-------------|
| month | DATE | First day of reporting month for MoM trend analysis |
| fraud_rate | DECIMAL | Fraud transactions divided by total transactions expressed as percentage |
| mom_change_pct | DECIMAL | Month-over-month change in fraud rate calculated using LAG window function |
| false_positive_rate | DECIMAL | Legitimate transactions flagged as fraud divided by total flagged transactions |
| structuring_flag | VARCHAR | Behavior-based detection — STRUCTURING_PATTERN or NORMAL |
| velocity_flag | VARCHAR | Velocity anomaly detection — VELOCITY_ANOMALY_HIGH, VELOCITY_ANOMALY_MEDIUM, or NORMAL |
| dormant_flag | VARCHAR | Dormant account reactivation — DORMANT_REACTIVATION_HIGH_VALUE, DORMANT_REACTIVATION, or NORMAL |
| overall_alert_priority | VARCHAR | Combined alert priority — HIGH, MEDIUM, or LOW |

---

## Risk Score Calculation

Base Score = customer fraud rate percentage x 100
Adjusted Score = Base Score + KYC Adjustment
KYC rejected: +10 points
KYC pending:  +5 points
KYC verified: +0 points
Risk Tier Assignment:
HIGH:   score above 70 OR KYC rejected
MEDIUM: score 40-70 OR KYC pending
LOW:    score below 40 AND KYC verified

---

## Critical Note on Internal Escalation Flags

internal_escalation_40k and internal_escalation_100k are
INTERNAL OPERATIONAL MONITORING TRIGGERS only.

CBUAE SAR/STR filing has NO monetary threshold as of June 2026.
Reporting is triggered by reasonable suspicion per Federal
Decree-Law No.(10) of 2025 and Cabinet Resolution No.(134) of 2025.

For full regulatory context see COMPLIANCE.md

---

## Data Lineage Reference

- README.md — Project overview and dbt lineage diagram
- COMPLIANCE.md — CBUAE 2026 regulatory framework

---

Last Updated: July 2026
Maintained By: Kunal Sharma — Financial Data Analyst
