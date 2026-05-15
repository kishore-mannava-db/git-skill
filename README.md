# Git Skill - Genie Code Skills

Custom skills for Databricks Genie Code, deployed as a Git-linked folder.

## Skills

| Skill | Description |
|-------|-------------|
| `data-quality` | Data quality checks and validation patterns for audit workflows |
| `sql-helper` | SQL patterns for financial data analysis and reporting |

## Architecture

```
GitHub Repo (git-skill)
    ├── data-quality/SKILL.md
    ├── sql-helper/SKILL.md
    ├── SKILL.md (root — combines all skills)
    ├── .assistant_instructions.md
    └── .github/workflows/deploy-skills.yml
            │
            ▼  (on push to main)
    GitHub Action
            │
            ├── databricks repos update → pulls latest into workspace Git folder
            └── workspace import → syncs .assistant_instructions.md to user-level path
            │
            ▼
    Databricks Workspace
        └── .assistant/skills/git-skill  (Git-linked folder)
```

## Key Features

| Feature | How It Works |
|---------|-------------|
| **Version-controlled skills** | Skills are stored in a GitHub repo with full commit history |
| **Edit anywhere** | Edit skills locally, in GitHub, or directly in the Databricks workspace |
| **Bidirectional sync** | Push from GitHub deploys to workspace. Edit in workspace and commit back to GitHub |
| **Auto-deploy on push** | GitHub Action triggers on every push to `main`, pulling latest into the workspace |
| **Git-linked folder** | Skills appear as a Git folder in the workspace — not a static copy |
| **Instructions as code** | `.assistant_instructions.md` is also Git-managed and auto-synced |

## Workflow

**Developer flow (local or GitHub):**
1. Edit or add a skill in the repo
2. Push to `main`
3. GitHub Action auto-syncs to the workspace
4. Genie Code picks up updated skills immediately

**Workspace flow (Databricks UI):**
1. Open the Git-linked `git-skill` folder in `.assistant/skills/`
2. Edit any skill file directly
3. Commit and push from the workspace Git UI
4. GitHub Action triggers, ensuring workspace stays in sync

## Deployment

Push to `main` triggers automatic deployment via GitHub Actions. Requires repository secrets:

- `DATABRICKS_HOST` — e.g. `https://adb-xxxx.xx.azuredatabricks.net`
- `DATABRICKS_TOKEN` — Databricks personal access token

## Adding a New Skill

1. Create a folder at the repo root (e.g. `my-new-skill/`)
2. Add a `SKILL.md` with frontmatter (`name`, `description`)
3. Push to `main` — GitHub Action syncs the Git folder in the workspace
