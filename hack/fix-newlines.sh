#!/bin/bash
set -euo pipefail

# Required: pass full path to the base branch checkout (clean copy of origin/main or base)
BASE_BRANCH_DIR="$1"

# Save current working directory (which is the PR branch)
PR_BRANCH_DIR=$(pwd)

# Compare PR branch to base branch to get changed files
CHANGED_FILES=$(git diff --name-only --no-renames --diff-filter=ACMRT "$BASE_BRANCH_DIR" "$PR_BRANCH_DIR")

echo "Changed files:"
echo "$CHANGED_FILES"

# Get author info of latest commit on PR branch
AUTHOR_NAME=$(git -C "$PR_BRANCH_DIR" log -1 --pretty=format:'%an')
AUTHOR_EMAIL=$(git -C "$PR_BRANCH_DIR" log -1 --pretty=format:'%ae')

# Apply newline fixes
echo "$CHANGED_FILES" | while read -r file; do
  FILE_PATH="$PR_BRANCH_DIR/$file"
  [ -f "$FILE_PATH" ] || continue
  tail -c1 "$FILE_PATH" | read -r _ || echo >> "$FILE_PATH"
done

# Check for any changes and amend commit
cd "$PR_BRANCH_DIR"
if ! git diff --quiet; then
  git add .
  git commit --amend --no-edit --author="$AUTHOR_NAME <$AUTHOR_EMAIL>"
  git push --force-with-lease
else
  echo "No changes to commit."
fi
