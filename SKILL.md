---
name: git-skill
description: "Data quality validation and financial SQL patterns. Use for data completeness checks, duplicate detection, outlier analysis, trial balances, aging analysis, reconciliation, and KPI calculations."
---

# Git Skill

This skill provides data quality validation and financial SQL patterns for audit and analytics workflows.

## Sub-skills

- [Data Quality Patterns](data-quality/SKILL.md) — completeness, duplicates, referential integrity, outliers, freshness
- [SQL Helper Patterns](sql-helper/SKILL.md) — trial balance, period comparison, aging, reconciliation, running balance

## Data Quality Patterns

### Completeness Check

```sql
SELECT
  COUNT(*) as total_rows,
  SUM(CASE WHEN account_id IS NULL THEN 1 ELSE 0 END) as null_account_id,
  SUM(CASE WHEN amount IS NULL THEN 1 ELSE 0 END) as null_amount,
  SUM(CASE WHEN transaction_date IS NULL THEN 1 ELSE 0 END) as null_date
FROM catalog.schema.transactions
```

### Duplicate Detection

```sql
SELECT
  account_id, transaction_date, amount,
  COUNT(*) as duplicate_count
FROM catalog.schema.transactions
GROUP BY account_id, transaction_date, amount
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
```

### Referential Integrity

```sql
SELECT t.*
FROM catalog.schema.transactions t
LEFT JOIN catalog.schema.accounts a ON t.account_id = a.account_id
WHERE a.account_id IS NULL
```

### Outlier Detection (IQR)

```sql
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

### Data Freshness

```sql
SELECT
  MAX(transaction_date) as latest_record,
  DATEDIFF(CURRENT_DATE(), MAX(transaction_date)) as days_since_latest,
  CASE
    WHEN DATEDIFF(CURRENT_DATE(), MAX(transaction_date)) > 1 THEN 'STALE'
    ELSE 'FRESH'
  END as freshness_status
FROM catalog.schema.transactions
```

## Financial SQL Patterns

### Trial Balance

```sql
SELECT
  account_type,
  SUM(CASE WHEN entry_type = 'DEBIT' THEN amount ELSE 0 END) as total_debits,
  SUM(CASE WHEN entry_type = 'CREDIT' THEN amount ELSE 0 END) as total_credits,
  SUM(CASE WHEN entry_type = 'DEBIT' THEN amount ELSE -amount END) as net_balance
FROM catalog.schema.general_ledger
WHERE posting_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY account_type
```

### Period-over-Period Comparison

```sql
WITH monthly_revenue AS (
  SELECT
    DATE_TRUNC('month', transaction_date) as month,
    SUM(amount) as revenue
  FROM catalog.schema.revenue
  GROUP BY DATE_TRUNC('month', transaction_date)
)
SELECT
  month, revenue,
  LAG(revenue) OVER (ORDER BY month) as prev_month_revenue,
  ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0
    / LAG(revenue) OVER (ORDER BY month), 2) as mom_growth_pct
FROM monthly_revenue
ORDER BY month
```

### Aging Analysis

```sql
SELECT
  customer_id, customer_name,
  SUM(CASE WHEN DATEDIFF(CURRENT_DATE(), invoice_date) <= 30 THEN outstanding_amount ELSE 0 END) as current_0_30,
  SUM(CASE WHEN DATEDIFF(CURRENT_DATE(), invoice_date) BETWEEN 31 AND 60 THEN outstanding_amount ELSE 0 END) as past_due_31_60,
  SUM(CASE WHEN DATEDIFF(CURRENT_DATE(), invoice_date) BETWEEN 61 AND 90 THEN outstanding_amount ELSE 0 END) as past_due_61_90,
  SUM(CASE WHEN DATEDIFF(CURRENT_DATE(), invoice_date) > 90 THEN outstanding_amount ELSE 0 END) as past_due_over_90,
  SUM(outstanding_amount) as total_outstanding
FROM catalog.schema.accounts_receivable
WHERE status = 'OPEN'
GROUP BY customer_id, customer_name
ORDER BY total_outstanding DESC
```

### Reconciliation

```sql
SELECT
  COALESCE(s.transaction_id, t.transaction_id) as transaction_id,
  s.amount as source_amount, t.amount as target_amount,
  ABS(COALESCE(s.amount, 0) - COALESCE(t.amount, 0)) as difference,
  CASE
    WHEN s.transaction_id IS NULL THEN 'MISSING_IN_SOURCE'
    WHEN t.transaction_id IS NULL THEN 'MISSING_IN_TARGET'
    WHEN s.amount != t.amount THEN 'AMOUNT_MISMATCH'
    ELSE 'MATCHED'
  END as match_status
FROM catalog.schema.source_data s
FULL OUTER JOIN catalog.schema.target_data t ON s.transaction_id = t.transaction_id
WHERE s.transaction_id IS NULL OR t.transaction_id IS NULL OR s.amount != t.amount
```

### Running Balance

```sql
SELECT
  transaction_date, description,
  CASE WHEN entry_type = 'DEBIT' THEN amount ELSE 0 END as debit,
  CASE WHEN entry_type = 'CREDIT' THEN amount ELSE 0 END as credit,
  SUM(CASE WHEN entry_type = 'DEBIT' THEN amount ELSE -amount END)
    OVER (PARTITION BY account_id ORDER BY transaction_date, transaction_id) as running_balance
FROM catalog.schema.general_ledger
WHERE account_id = '1000'
ORDER BY transaction_date, transaction_id
```

## Common Issues

| Issue | Solution |
|-------|----------|
| **High null percentage** | Check upstream data sources and ingestion pipeline |
| **Duplicate records** | Add deduplication logic or use MERGE |
| **Orphan records** | Verify foreign key relationships and load order |
| **Outlier amounts** | Review with business team - may be valid |
| **Precision loss** | Use `DECIMAL(18,2)` for financial amounts, avoid FLOAT |
| **Timezone issues** | Standardize to UTC, use `TIMESTAMP` not `STRING` |
| **Slow period queries** | Partition tables by date, use Z-ORDER on date columns |
