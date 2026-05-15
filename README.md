# EY Git Skill - Genie Code Skills

Custom skills for Databricks Genie Code, managed via Git. Edit skills in the Databricks workspace and commit back to GitHub.

## Skills

| Skill | Description |
|-------|-------------|
| `ey-data-quality` | Data quality checks and validation patterns for audit workflows |
| `ey-sql-helper` | SQL patterns for financial data analysis and reporting |

## Deployment

### Manual (CLI)

```bash
./deploy_skills.sh --profile my
```

### Automated (GitHub Actions)

Push to `main` triggers automatic deployment. Requires these repository secrets:

- `DATABRICKS_HOST` — e.g. `https://adb-xxxx.xx.azuredatabricks.net`
- `DATABRICKS_TOKEN` — Databricks personal access token

### Configuration

Workspace settings are in `databricks.yml`.
