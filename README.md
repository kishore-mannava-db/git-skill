# Git Skill - Genie Code Skills

Custom skills for Databricks Genie Code, deployed via DABs.

## Skills

| Skill | Description |
|-------|-------------|
| `ey-data-quality` | Data quality checks and validation patterns for audit workflows |
| `ey-sql-helper` | SQL patterns for financial data analysis and reporting |

## Deployment

### Manual (CLI)

```bash
databricks bundle deploy --target dev --profile my
```

### Automated (GitHub Actions)

Push to `main` triggers automatic deployment. Requires repository secrets:

- `DATABRICKS_HOST` — e.g. `https://adb-xxxx.xx.azuredatabricks.net`
- `DATABRICKS_TOKEN` — Databricks personal access token

## Adding a New Skill

1. Create a folder at the repo root (e.g. `my-new-skill/`)
2. Add a `SKILL.md` with frontmatter (`name`, `description`)
3. Push to `main` — DABs deploys it to `.assistant/skills/`
