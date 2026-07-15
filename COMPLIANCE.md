
# Regulatory Compliance Framework

## UAE FinPay — Project 1: Payment Fraud Risk Analytics

---

## Executive Summary

This project implements a fraud detection and AML monitoring framework for UAE FinPay, aligned with CBUAE's 2026 AML/CFT/CPF guidance and Federal Decree-Law No. (10) of 2025. The methodology focuses on behavior-based detection, SAR/STR reporting readiness, and operational monitoring triggers — all designed to meet CBUAE's zero-tolerance expectations for data quality and timely reporting.

**Key Compliance Areas:**
- **SAR/STR Framework:** Reasonable suspicion-based reporting (no monetary threshold)
- **Behavior-Based Detection:** Structuring patterns, velocity anomalies, dormant account reactivation
- **goAML Reporting:** Timelines, report types, and FIU submission workflows
- **2026 Regulatory Updates:** TBML, PF, Dynamic CDD, FATF 5th Round preparation
- **Data Protection (PDPL):** Data minimization, purpose limitation, cross-border transfer (Azure UAE region)

---

## CBUAE SAR/STR Framework (June 2026)

### Legal Basis

This project aligns with the following CBUAE regulations and guidance:

| Regulation | Description |
|------------|-------------|
| **Federal Decree-Law No. (10) of 2025** | Primary AML/CFT/CPF legislation — criminalizes money laundering, terrorist financing, and proliferation financing |
| **Cabinet Resolution No. (134) of 2025** | Executive Regulations — operational requirements for SAR/STR reporting, CDD, record-keeping |
| **CBUAE AML/CFT/CPF Guidance Package — April 16, 2026** | Comprehensive guidance for licensed financial institutions (LFIs) and designated non-financial businesses and professions (DNFBPs) |

---


### Critical Clarification — No Monetary Threshold

> **SAR/STR filing is triggered by REASONABLE SUSPICION, not by transaction amount.**
>
> A transaction of **AED 1** is as reportable as **AED 1,000,000** if suspicion exists.

**Internal escalation flags (AED 40k and 100k) in this project are operational monitoring triggers only.** They are **NOT** SAR/STR thresholds per CBUAE 2026 guidance.

**Operational Context:**
- CBUAE emphasizes **risk-based monitoring** — higher-value transactions may trigger enhanced review, but the **actual SAR/STR trigger is suspicion**, not amount
- Internal thresholds (AED 40k/100k) help compliance teams **prioritize alerts** for analyst review — but they don't replace human judgment or regulatory obligations
- This project models AED 40k/100k flags as **operational tools** to focus analyst attention, not as regulatory filing triggers

---

### Behavior-Based Detection Applied in This Project

Per CBUAE's April 2026 guidance, this project implements **behavior-based fraud detection** aligned with regulatory expectations:

| Detection Type | Description | Implementation in Project |
|----------------|-------------|--------------------------|
| **Structuring Patterns** | Multiple transactions just below reporting thresholds designed to avoid detection | Flagged in `fct_behavior_risk_flags` model — detects customers with 3+ transactions between AED 40k-50k within 7 days |
| **Velocity Anomalies** | Sudden spike in transaction frequency or value vs customer's 90-day baseline | Modeled in `fct_fraud_risk_scorecard` — compares current 30-day activity to prior 90-day average |
| **Dormant Account Reactivation** | Inactive accounts suddenly showing high-value, high-frequency activity | Flagged in `fct_behavior_risk_flags` — accounts with 0 transactions for 180+ days, then 5+ transactions in 7 days |
| **KYC Failures / Pending Verification** | Customers with incomplete or failed KYC checks attempting high-value transactions | Modeled in `stg_customers` — `kyc_status` field (verified/pending/failed) used in risk scoring |
| **Unusual Time/Location Patterns** | Transactions at odd hours or from unexpected geographies | Flagged in `fct_behavior_risk_flags` — transactions between 2-5 AM local time, or from high-risk jurisdictions |

---

### Reporting Timelines

Per Cabinet Resolution No. (134) of 2025, SAR/STR reports must be filed within these deadlines:

| Category | Deadline | Application in This Project |
|----------|----------|----------------------------|
| **Terrorist Financing (TF)** | 24 hours from detection | Modeled via `tf_flag` field — immediate escalation to MLRO |
| **Standard Alert** | 35 business days from alert generation | Modeled via `alert_generated_date` and `alert_resolved_date` fields |
| **Complex Investigation (Initial)** | 15 business days from escalation | Modeled for high-risk cases requiring extended review |
| **Complex Investigation (Supplemental)** | 30 business days from initial report | Modeled for cases with evolving suspicion patterns |

**Note:** These timelines are **regulatory maximums** — best practice is to file as soon as reasonable suspicion is confirmed.

---

### Reporting Channel

All SAR/STR reports are filed via the **goAML portal** — the official system of the UAE Financial Intelligence Unit (FIU).

**Report Types Supported:**

| Report Type | Description |
|-------------|-------------|
| **SAR (Suspicious Activity Report)** | Filed when customer behavior suggests money laundering, terrorist financing, or other financial crime |
| **STR (Suspicious Transaction Report)** | Filed when a specific transaction (or series of transactions) appears suspicious |
| **CNMR (Confirmed Name Match Report)** | Filed when a customer matches a sanctioned individual/entity on UAE or UN sanctions lists |
| **PNMR (Partial Name Match Report)** | Filed when a customer partially matches a sanctioned name — requires further investigation |

**Applied in This Project:**
- `fct_behavior_risk_flags` model generates alerts that would trigger SAR/STR filing in production
- `fct_fraud_risk_scorecard` assigns risk scores that inform MLRO escalation decisions
- Internal escalation flags (AED 40k/100k) prioritize alerts for compliance team review

---

### Key 2026 Regulatory Updates

CBUAE's April 2026 guidance introduced several critical updates that impact this project:

| Update | Description | Applied in This Project |
|--------|-------------|------------------------|
| **TBML (Trade-Based Money Laundering)** | First standalone guidance — focuses on over/under-invoicing, multiple invoicing, phantom shipments | Modeled via `merchant_category` analysis — high-risk categories (import/export, wholesale trade) flagged for enhanced monitoring |
| **PF (Proliferation Financing)** | Mandatory standalone risk assessment — financing of weapons of mass destruction (WMD) programs | Modeled via `high_risk_jurisdiction` flag — transactions linked to countries on UAE PF risk list |
| **Dynamic CDD (Customer Due Diligence)** | Continuous monitoring, not one-time onboarding — requires ongoing risk reassessment | Implemented via `fct_customer_segments` — customers re-scored monthly based on transaction behavior |
| **RegTech Focus** | Zero tolerance for poor data quality in goAML submissions — automated validation required | Modeled via dbt tests — unique key constraints, non-null checks, referential integrity ensure data quality |
| **FATF 5th Round Mutual Evaluation** | UAE preparing for 2026 FATF assessment — enhanced AML/CFT controls expected | Project demonstrates compliance-ready framework for fraud detection, SAR/STR reporting, and behavioral monitoring |

---

## UAE Data Protection Law (PDPL)

### Legal Basis

- **Federal Decree-Law No. (45) of 2021** — Protection of Personal Data (PDPL)
- **CBUAE Guidance on Data Protection for Financial Institutions — January 2026**

### Compliance Applied

| PDPL Principle | Implementation in This Project |
|----------------|-------------------------------|
| **Data Minimisation** | Only necessary fields collected (customer_id, transaction_id, amount, timestamp, channel, merchant_category, fraud_flag) — no sensitive personal data (e.g., Emirates ID, passport) stored |
| **Purpose Limitation** | Data used solely for fraud detection and AML monitoring — documented in model descriptions and data dictionary |
| **Storage Limitation** | 5-year retention for payment/fraud data (per CBUAE record-keeping requirements) — modeled via `data_retention_date` field |
| **Cross-Border Transfer** | Azure cloud resources configured in UAE region (UAE North, Dubai) — no data leaves UAE jurisdiction |
| **Data Subject Rights** | Framework for customer data access, correction, deletion requests (not implemented in prototype — would require integration with core banking system) |
| **Security Safeguards** | Modeled via role-based access control (RBAC) — only authorized fraud analysts can access raw transaction data |

---

## VARA (Virtual Assets Regulatory Authority)

### Virtual Asset Transaction Monitoring

While this project focuses on traditional payment transactions (fiat currency), the framework includes capability notes for:

- **Virtual asset transaction reporting** — if UAE FinPay extends services to crypto-asset purchases or transfers
- **Stablecoin payment integration** — compliance with VARA Rulebook for Virtual Asset Activities (2025 Edition)
- **Crypto-adjacent monitoring** — flagging payment transactions linked to virtual asset exchanges (e.g., Binance, Bybit, Coinbase)

**Applied in This Project:**
- `merchant_category` includes "Virtual Asset Exchange" as a high-risk category
- `fct_behavior_risk_flags` can be extended to flag crypto-related transactions for enhanced monitoring
- **Note:** VARA licensing required if payment services are used to purchase virtual assets — not implemented in this prototype

---

## goAML Portal — UAE FIU Reporting Workflow

### Report Filing Process

```
Alert Generated
(via fct_behavior_risk_flags or fct_fraud_risk_scorecard)
↓
Compliance Analyst Review
(within 3-5 business days)
↓
Escalation to MLRO
(if reasonable suspicion confirmed)
↓
SAR/STR Preparation
(within 10 business days)
↓
Submission via goAML Portal
(within regulatory deadlines)
↓
FIU Acknowledgment and Case Number Assignment
```

### Data Quality Requirements (goAML)

Per CBUAE's 2026 RegTech focus, goAML submissions must meet these standards:

| Requirement | Enforcement in This Project |
|-------------|----------------------------|
| **Unique Transaction Identifiers** | Modeled via `transaction_id` (primary key, unique constraint) |
| **Complete Customer Information** | Modeled via `customer_id`, `kyc_status`, `emirate` fields |
| **Accurate Amounts and Timestamps** | Modeled via `amount_aed`, `transaction_timestamp` (non-null, validated) |
| **Consistent Categorization** | Modeled via `payment_channel`, `merchant_category` (accepted values enforced via dbt tests) |
| **Audit Trail** | Modeled via `alert_generated_date`, `alert_resolved_date`, `escalation_flag` |

---

## Compliance Limitations (Prototype Scope)

This project is an **analytical prototype** for fraud detection and AML monitoring. Production deployment would require:

- **Integration with core banking/payment system** for real-time transaction ingestion
- **goAML API integration** for automated SAR/STR filing (currently manual in prototype)
- **MLRO dashboard** for alert review, escalation, and case management
- **Customer communication workflows** for KYC remediation and enhanced due diligence
- **VARA licensing** if virtual asset transactions are added to the product suite

---

## Sources

| Source | Description |
|--------|-------------|
| **Federal Decree-Law No. (10) of 2025** | Primary AML/CFT/CPF legislation — criminalizes money laundering, terrorist financing, proliferation financing |
| **Cabinet Resolution No. (134) of 2025** | Executive Regulations — SAR/STR reporting requirements, CDD obligations, record-keeping mandates |
| **CBUAE AML/CFT/CPF Guidance Package — April 16, 2026** | Comprehensive guidance for LFIs and DNFBPs — includes TBML, PF, Dynamic CDD updates |
| **goAML Portal — UAE Financial Intelligence Unit (FIU)** | Official reporting system for SARs, STRs, CNMRs, PNMRs |
| **Federal Decree-Law No. (45) of 2021 (PDPL)** | UAE data protection law — governs personal data processing, cross-border transfer, data subject rights |
| **VARA Rulebook for Virtual Asset Activities — 2025 Edition** | Regulatory framework for virtual asset service providers (VASPs) in Dubai |
| **FATF Mutual Evaluation Methodology (2026)** | 5th Round assessment framework — UAE preparing for 2026 evaluation |

---