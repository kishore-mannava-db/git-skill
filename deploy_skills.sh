#!/bin/bash
# Deploy skills as a Git folder inside .assistant/skills/ in Databricks workspace
# This allows editing skills in the workspace and committing back to GitHub.
#
# Usage: ./deploy_skills.sh --profile my

set -e

PROFILE="DEFAULT"

while [[ $# -gt 0 ]]; do
  case $1 in
    --profile) PROFILE="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Get current user
USER_NAME=$(databricks current-user me --profile "$PROFILE" --output json 2>/dev/null | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('userName', ''))" 2>/dev/null)
if [ -z "$USER_NAME" ]; then
  echo "Error: Could not determine workspace user. Check --profile."
  exit 1
fi

# Get repo URL from git remote
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "")
if [ -z "$REPO_URL" ]; then
  echo "Error: Not a git repo or no remote 'origin' configured."
  exit 1
fi
# Normalize SSH URL to HTTPS
if [[ "$REPO_URL" == git@* ]]; then
  REPO_URL=$(echo "$REPO_URL" | sed 's|git@github.com:|https://github.com/|')
fi
REPO_NAME=$(basename "$REPO_URL" .git)

DEST_PATH="/Users/$USER_NAME/.assistant/skills"
FOLDER_PATH="$DEST_PATH/$REPO_NAME"

echo "Deploying Git folder to: $FOLDER_PATH"
echo "  Remote: $REPO_URL"
echo "  Profile: $PROFILE"

# Check if Git folder already exists
EXISTING=$(databricks repos list --profile "$PROFILE" --output json 2>/dev/null | python3 -c "
import sys, json
for r in json.load(sys.stdin):
    if r.get('path','') == '$FOLDER_PATH':
        print(r['id'])
        break
" 2>/dev/null || echo "")

if [ -n "$EXISTING" ]; then
  echo "  Git folder already exists (id: $EXISTING). Pulling latest..."
  databricks repos update "$EXISTING" --branch main --profile "$PROFILE" 2>/dev/null
else
  echo "  Creating Git folder..."
  databricks workspace mkdirs "$DEST_PATH" --profile "$PROFILE" 2>/dev/null || true
  databricks repos create "$REPO_URL" gitHub --path "$FOLDER_PATH" --profile "$PROFILE"
fi

echo ""
echo "Deployed:"
databricks workspace list "$DEST_PATH" --profile "$PROFILE" 2>/dev/null
echo ""
echo "Done! Edit skills in the workspace and commit back to GitHub."
