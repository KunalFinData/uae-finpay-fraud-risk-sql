
import pandas as pd
import numpy as np
from sqlalchemy import create_engine
import warnings
warnings.filterwarnings('ignore')

print("=" * 50)
print("UAE FinPay Data Preparation Script")
print("=" * 50)

print("\nStep 1: Loading IEEE-CIS dataset...")
print("This may take 1-2 minutes due to file size...")

df = pd.read_csv(
    r'C:\Users\kunal\projects\uae-finpay-fraud-risk-sql\raw_data\train_transaction.csv'
)
print(f"Full dataset loaded: {len(df):,} rows, {len(df.columns)} columns")
print(f"Fraud rate in full dataset: {df['isFraud'].mean()*100:.1f}%")

print("\nStep 2: Sampling 100,000 rows (stratified)...")
fraud_rows = df[df['isFraud'] == 1]
clean_rows = df[df['isFraud'] == 0]
print(f"Total fraud rows available: {len(fraud_rows):,}")
print(f"Total clean rows available: {len(clean_rows):,}")

fraud_sample = fraud_rows.sample(
    n=min(8000, len(fraud_rows)),
    random_state=42
)
clean_sample = clean_rows.sample(
    n=min(92000, len(clean_rows)),
    random_state=42
)

sample = pd.concat(
    [fraud_sample, clean_sample]
).reset_index(drop=True)

sample = sample.sample(
    frac=1,
    random_state=42
).reset_index(drop=True)

print(f"Sample created: {len(sample):,} rows")
print(f"Fraud rate in sample: {sample['isFraud'].mean()*100:.1f}%")

print("\nStep 3: Adding UAE staging columns...")
np.random.seed(42)

sample['emirate'] = np.random.choice(
    ['Dubai', 'Abu Dhabi', 'Sharjah', 'Ajman', 'Ras Al Khaimah'],
    size=len(sample),
    p=[0.45, 0.25, 0.15, 0.10, 0.05]
)

sample['amount_aed'] = (sample['TransactionAmt'] * 3.67).round(2)

sample['kyc_status'] = np.random.choice(
    ['verified', 'pending', 'rejected'],
    size=len(sample),
    p=[0.82, 0.13, 0.05]
)

sample['payment_channel'] = np.random.choice(
    ['card', 'wallet', 'bank_transfer'],
    size=len(sample),
    p=[0.55, 0.30, 0.15]
)

sample['internal_escalation_40k'] = (
    sample['amount_aed'] >= 40000
).astype(int)

sample['internal_escalation_100k'] = (
    sample['amount_aed'] >= 100000
).astype(int)

sample['customer_id'] = (
    'UAE_CUST_' + sample['card1'].astype(str)
)

sample['merchant_category'] = np.random.choice(
    ['retail', 'ecommerce', 'food_beverage',
     'transport', 'electronics', 'travel'],
    size=len(sample),
    p=[0.25, 0.30, 0.15, 0.10, 0.12, 0.08]
)

sample['transaction_date'] = pd.date_range(
    start='2026-01-01',
    periods=len(sample),
    freq='10min'
)

sample['transaction_id'] = (
    'TXN_UAE_' + sample['TransactionID'].astype(str)
)

print("UAE columns added successfully")
print(f"Emirates distribution:")
print(sample['emirate'].value_counts())
print(f"\nKYC status distribution:")
print(sample['kyc_status'].value_counts())
print(f"\nInternal escalation flags (40k+): "
      f"{sample['internal_escalation_40k'].sum():,}")
print(f"Internal escalation flags (100k+): "
      f"{sample['internal_escalation_100k'].sum():,}")

print("\nStep 4: Selecting and renaming final columns...")

final_df = sample[[
    'transaction_id',
    'customer_id',
    'transaction_date',
    'amount_aed',
    'emirate',
    'kyc_status',
    'payment_channel',
    'merchant_category',
    'isFraud',
    'internal_escalation_40k',
    'internal_escalation_100k',
    'ProductCD',
    'card4',
    'P_emaildomain'
]].copy()

final_df.columns = [
    'transaction_id',
    'customer_id',
    'transaction_date',
    'amount_aed',
    'emirate',
    'kyc_status',
    'payment_channel',
    'merchant_category',
    'is_fraud',
    'internal_escalation_40k',
    'internal_escalation_100k',
    'product_type',
    'card_network',
    'email_domain'
]

final_df['is_fraud'] = (
    final_df['is_fraud'].fillna(0).astype(int)
)
final_df['internal_escalation_40k'] = (
    final_df['internal_escalation_40k'].fillna(0).astype(int)
)
final_df['internal_escalation_100k'] = (
    final_df['internal_escalation_100k'].fillna(0).astype(int)
)
final_df['product_type'] = (
    final_df['product_type'].fillna('unknown')
)
final_df['card_network'] = (
    final_df['card_network'].fillna('unknown')
)
final_df['email_domain'] = (
    final_df['email_domain'].fillna('unknown')
)

print(f"\nFinal dataset shape: {final_df.shape}")
print(f"Columns: {list(final_df.columns)}")
print(f"\nSample of first 3 rows:")
print(final_df.head(3).to_string())

print("\nStep 5: Connecting to PostgreSQL...")
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

connection_url = URL.create(
    drivername="postgresql+psycopg2",
    username="postgres",
    password="Hellboy@0404",
    host="localhost",
    port=5432,
    database="payment_risk_db"
)
engine = create_engine(connection_url)
print("Connection established")

print("\nStep 6: Loading data into raw.transactions...")
print("This may take 2-3 minutes...")

final_df.to_sql(
    name='transactions',
    schema='raw',
    con=engine,
"""
UAE FinPay Data Preparation Script
===================================
Purpose: Samples 100,000 rows from IEEE-CIS Fraud Detection
         dataset and creates UAE staging layer with:
         - AED currency conversion (USD x 3.67)
         - UAE emirate distribution
         - KYC status classification
         - Internal escalation flags (operational monitoring only)
         - Payment channel categorisation

Dataset: IEEE-CIS Fraud Detection (Kaggle)
Output:  raw.transactions table in payment_risk_db PostgreSQL

CBUAE Note: Internal escalation flags (AED 40k/100k) are
operational monitoring triggers only. NOT SAR/STR thresholds.
Per Federal Decree-Law No.10/2025 reporting is suspicion-based.

Author: Kunal Sharma
Date:   June 2026
"""    



if_exists='replace',
    index=False,
    chunksize=5000
)

print(f"\nSuccessfully loaded {len(final_df):,} rows")
print("Table: payment_risk_db → raw → transactions")

print("\nStep 7: Verifying load...")
result = pd.read_sql(
    "SELECT COUNT(*) as total_rows FROM raw.transactions",
    engine
)
print(f"Rows in database: {result['total_rows'][0]:,}")

fraud_check = pd.read_sql(
    """SELECT is_fraud,
              COUNT(*) as count
       FROM raw.transactions
       GROUP BY is_fraud
       ORDER BY is_fraud""",
    engine
)
print(f"\nFraud distribution in database:")
print(fraud_check.to_string())

print("\n" + "=" * 50)
print("SUCCESS! Data is ready.")
print("Open DBeaver and run:")
print("SELECT COUNT(*) FROM raw.transactions;")
print("=" * 50)