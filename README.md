# EY Git Skill - Sample Genie Code Skills

This repository contains sample skills for Databricks Genie Code (AI Assistant).
Skills are deployed to the workspace `.assistant/skills/` folder to extend the Genie Code agent with custom capabilities.

## Skills Included

| Skill | Description |
|-------|-------------|
| `ey-data-quality` | Data quality checks and validation patterns for EY audit workflows |
| `ey-sql-helper` | Common SQL patterns for financial data analysis and reporting |

## Deployment

### Deploy to Databricks Workspace

```bash
# Clone this repo
git clone <repo-url>
cd ey-git-skill

# Deploy skills to your workspace .assistant/skills/ folder
./deploy_skills.sh --profile my
```

### Manual Deployment

```bash
# Upload a single skill
databricks workspace import-dir skills/ey-data-quality /Users/<you>/.assistant/skills/ey-data-quality --profile my --overwrite
```
