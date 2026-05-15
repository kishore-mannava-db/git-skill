---
name: git-skill
description: "Data quality validation and financial SQL patterns. Use for data completeness checks, duplicate detection, outlier analysis, trial balances, aging analysis, reconciliation, and KPI calculations. Detailed SQL and patterns live in sub-skills—open the linked files for full examples."
---

# Git Skill

Umbrella skill for audit and finance analytics on Databricks. **Concrete SQL, quick starts, and troubleshooting** are maintained in the sub-skills below—avoid duplicating them here so Genie and humans have a single source of truth.

## When to use which

| Topic | Sub-skill |
|-------|-----------|
| Completeness, duplicates, referential integrity, outliers, freshness, DQ rules | [data-quality/SKILL.md](data-quality/SKILL.md) |
| Trial balance, period-over-period, aging, reconciliation, running balance, window KPIs | [sql-helper/SKILL.md](sql-helper/SKILL.md) |

## Sub-skills

- **[Data Quality](data-quality/SKILL.md)** — validation patterns for financial and audit data.
- **[SQL Helper](sql-helper/SKILL.md)** — reporting and ledger-style SQL patterns.

Follow [.assistant_instructions.md](.assistant_instructions.md) for global defaults (e.g. `DECIMAL(18,2)`, UTC timestamps, row counts in results).
