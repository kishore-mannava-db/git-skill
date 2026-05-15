# Git Skill - Genie Code Skills

Custom skills for Databricks Genie Code, deployed as a Git-linked folder.

## Skills

| Skill | Description |
|-------|-------------|
| `data-quality` | Data quality checks and validation patterns for audit workflows |
| `sql-helper` | SQL patterns for financial data analysis and reporting |

## Deployment

Push to `main` triggers automatic deployment via GitHub Actions. Requires repository secrets:

- `DATABRICKS_HOST` — e.g. `https://adb-xxxx.xx.azuredatabricks.net`
- `DATABRICKS_TOKEN` — Databricks personal access token

## Adding a New Skill

1. Create a folder at the repo root (e.g. `my-new-skill/`)
2. Add a `SKILL.md` with frontmatter (`name`, `description`)
3. Push to `main` — GitHub Action syncs the Git folder in the workspace
