#!/bin/bash
# Deploy skills from this repo to Databricks workspace .assistant/skills/ folder
# Usage: ./deploy_skills.sh --profile my

set -e

PROFILE="DEFAULT"
SKILLS_DIR="skills"

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

DEST_PATH="/Users/$USER_NAME/.assistant/skills"
echo "Deploying skills to: $DEST_PATH (profile: $PROFILE)"

# Create .assistant/skills directory
databricks workspace mkdirs "$DEST_PATH" --profile "$PROFILE" 2>/dev/null || true

# Upload each skill folder
for skill_dir in "$SKILLS_DIR"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")

  if [ ! -f "$skill_dir/SKILL.md" ]; then
    echo "  Skipping $skill_name (no SKILL.md)"
    continue
  fi

  echo "  Uploading $skill_name..."
  databricks workspace mkdirs "$DEST_PATH/$skill_name" --profile "$PROFILE" 2>/dev/null || true

  find "$skill_dir" -type f \( -name "*.md" -o -name "*.py" -o -name "*.sql" -o -name "*.yaml" -o -name "*.yml" \) | while read -r file; do
    rel_path="${file#$skill_dir}"
    dest="$DEST_PATH/$skill_name/$rel_path"
    parent_dir=$(dirname "$dest")
    if [ "$parent_dir" != "$DEST_PATH/$skill_name" ]; then
      databricks workspace mkdirs "$parent_dir" --profile "$PROFILE" 2>/dev/null || true
    fi
    databricks workspace import "$dest" --file "$file" --profile "$PROFILE" --format AUTO --overwrite 2>/dev/null || true
  done
done

echo ""
echo "Deployed skills:"
databricks workspace list "$DEST_PATH" --profile "$PROFILE" 2>/dev/null
echo ""
echo "Done! Skills are now available in Genie Code."
