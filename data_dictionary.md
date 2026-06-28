\# Data Dictionary — UAE FinPay

\## Shared Across All 7 UAE FinPay Projects



| Field | Type | Description |

|-------|------|-------------|

| transaction\_id | VARCHAR | Unique transaction ID — TXN\_UAE\_\[ID] |

| customer\_id | VARCHAR | Unique customer ID — UAE\_CUST\_\[ID] |

| transaction\_date | TIMESTAMP | Date and time of transaction |

| amount\_aed | DECIMAL | Transaction amount in UAE Dirhams |

| emirate | VARCHAR | UAE emirate — Dubai, Abu Dhabi, Sharjah, Ajman, Ras Al Khaimah |

| kyc\_status | VARCHAR | KYC verification status — verified, pending, rejected |

| payment\_channel | VARCHAR | Payment method — card, wallet, bank\_transfer |

| merchant\_category | VARCHAR | Merchant type — retail, ecommerce, food\_beverage, transport, electronics, travel |

| is\_fraud | INTEGER | Fraud label — 1 = fraud, 0 = legitimate |

| internal\_escalation\_40k | INTEGER | Operational monitoring flag for transactions above AED 40,000 |

| internal\_escalation\_100k | INTEGER | Operational monitoring flag for transactions above AED 100,000 |

| product\_type | VARCHAR | Product category from source data |

| card\_network | VARCHAR | Card network — visa, mastercard, discover, amex |

| email\_domain | VARCHAR | Customer email domain |

| risk\_score | INTEGER | Customer risk score 0-100. Derived from fraud rate and KYC status |

| risk\_tier | VARCHAR | Risk classification — HIGH, MEDIUM, LOW |

| activity\_tier | VARCHAR | Transaction frequency — HIGH\_ACTIVITY, MEDIUM\_ACTIVITY, LOW\_ACTIVITY |

| value\_tier | VARCHAR | Spend level — HIGH\_VALUE, MEDIUM\_VALUE, LOW\_VALUE |



\## Critical Note on Escalation Flags

internal\_escalation\_40k and internal\_escalation\_100k are

INTERNAL OPERATIONAL MONITORING TRIGGERS only.



CBUAE SAR/STR filing has NO monetary threshold as of June 2026.

Reporting is triggered by reasonable suspicion per Federal

Decree-Law No.(10) of 2025 and Cabinet Resolution No.(134) of 2025.



A transaction of AED 1 is as reportable as AED 10,000,000

if reasonable suspicion exists.



\## Risk Score Calculation

\- Score 0-100 derived from customer fraud rate percentage

\- KYC rejected adds 10 points

\- KYC pending adds 5 points

\- HIGH risk: score above 70 or KYC rejected

\- MEDIUM risk: score 40-70 or KYC pending

\- LOW risk: score below 40 with verified KYC

