---
name: ey-data-quality
description: "Data quality validation patterns for financial and audit data. Use when checking data completeness, accuracy, consistency, or when building DQ rules for EY audit workflows."
---

# EY Data Quality Skill

## Overview

This skill provides data quality validation patterns commonly used in financial auditing and compliance workflows. Use it when you need to validate data completeness, check for anomalies, or build automated DQ rules.

## Quick Start

```sql
-- Check for null values in critical columns
SELECT
  COUNT(*) as total_rows,
  COUNT(account_id) as non_null_account,
  COUNT(transaction_date) as non_null_date,
  COUNT(amount) as non_null_amount,
  ROUND(COUNT(account_id) * 100.0 / COUNT(*), 2) as account_completeness_pct
FROM catalog.schema.transactions
```

## Common Patterns

### Pattern 1: Completeness Check

```sql
-- Measure completeness across all columns
SELECT
  'transactions' as table_name,
  COUNT(*) as total_rows,
  SUM(CASE WHEN account_id IS NULL THEN 1 ELSE 0 END) as null_account_id,
  SUM(CASE WHEN amount IS NULL THEN 1 ELSE 0 END) as null_amount,
  SUM(CASE WHEN transaction_date IS NULL THEN 1 ELSE 0 END) as null_date
FROM catalog.schema.transactions
```

### Pattern 2: Duplicate Detection

```sql
-- Find duplicate records based on business keys
SELECT
  account_id,
  transaction_date,
  amount,
  COUNT(*) as duplicate_count
FROM catalog.schema.transactions
GROUP BY account_id, transaction_date, amount
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
```

### Pattern 3: Referential Integrity

```sql
-- Check for orphan records
SELECT t.*
FROM catalog.schema.transactions t
LEFT JOIN catalog.schema.accounts a ON t.account_id = a.account_id
WHERE a.account_id IS NULL
```

### Pattern 4: Range and Outlier Detection

```sql
-- Statistical outlier detection using IQR method
WITH stats AS (
  SELECT
    PERCENTILE(amount, 0.25) as q1,
    PERCENTILE(amount, 0.75) as q3
  FROM catalog.schema.transactions
)
SELECT t.*
FROM catalog.schema.transactions t
CROSS JOIN stats s
WHERE t.amount < (s.q1 - 1.5 * (s.q3 - s.q1))
   OR t.amount > (s.q3 + 1.5 * (s.q3 - s.q1))
```

### Pattern 5: Timeliness Check

```sql
-- Check data freshness
SELECT
  MAX(transaction_date) as latest_record,
  DATEDIFF(CURRENT_DATE(), MAX(transaction_date)) as days_since_latest,
  CASE
    WHEN DATEDIFF(CURRENT_DATE(), MAX(transaction_date)) > 1 THEN 'STALE'
    ELSE 'FRESH'
  END as freshness_status
FROM catalog.schema.transactions
```

## Common Issues

| Issue | Solution |
|-------|----------|
| **High null percentage** | Check upstream data sources and ingestion pipeline |
| **Duplicate records** | Add deduplication logic in the ETL pipeline or use MERGE |
| **Orphan records** | Verify foreign key relationships and load order |
| **Outlier amounts** | Review with business team - may be valid large transactions |
