# UAE FinPay Payment Analytics & Fraud Risk Intelligence Engine

## Business Problem
UAE FinPay processes thousands of daily payment transactions
across card, wallet, and bank transfer channels. This project
delivers SQL-driven fraud detection, customer risk segmentation,
and payment channel intelligence to reduce fraud exposure and
improve operational efficiency.

## Data Lineage

Raw Layer (IEEE-CIS Fraud Detection — Kaggle)

↓

UAE Staging Layer (AED conversion, emirate, KYC, escalation flags)

↓

dbt Staging Models (stg_transactions, stg_customers)

↓

dbt Mart Models (8 analytical models with dbt tests)

↓

GitHub (version controlled, documented, tested)

## Tech Stack
PostgreSQL 17 | dbt Core 1.11 | Python | GitHub

## Business Outcomes
- High-value customers (top 20%) represent 89.69% of total fraud exposure
  while being only 20% of customers — critical concentration risk
- Bank transfer channel shows highest fraud rate at 8.14% in Abu Dhabi
  vs wallet at 7.40% — contradicts card-first fraud assumptions
- Ecommerce merchants show highest fraud concentration by category
- Behavior-based detection flags structuring patterns and velocity
  anomalies per CBUAE 2026 guidance
- Monthly fraud trend analysis with month-on-month change tracking
- HIGH_VALUE segment total fraud transactions: 7,175
  vs STANDARD segment: 825 — 8.7x higher absolute fraud volume
  s
## Key Models
| Model | Business Question |
|-------|------------------|
| fct_fraud_risk_scorecard | Risk score per customer 0-100 |
| fct_false_positive_rate | Fraud model accuracy by channel |
| fct_customer_segments | Activity and value tiering |
| fct_high_value_fraud_exposure | Premium segment risk concentration |
| fct_payment_channel_performance | Channel fraud vs revenue analysis |
| fct_monthly_fraud_trend | MoM fraud rate with LAG window function |
| fct_merchant_category_analysis | Category risk ranking |
| fct_behavior_risk_flags | CBUAE 2026 behavior-based detection |

## Regulatory Framework
See COMPLIANCE.md for full CBUAE 2026 regulatory references
including Federal Decree-Law No.10/2025 and Cabinet Resolution No.134/2025.

## dbt Lineage Diagram
![dbt Lineage](lineage.png)

## GitHub
https://github.com/KunalFinData/uae-finpay-fraud-risk-sql

## LinkedIn
www.linkedin.com/in/kunalsharma0425