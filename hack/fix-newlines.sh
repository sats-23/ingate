#!/bin/bash
set -euo pipefail

# Get the base branch to compare against (e.g., "main")
BASE_BRANCH="${BASE_BRANCH:-origin/main}"

# Fetch base branch
git fetch origin "$BASE_BRANCH"

# Get author of latest commit
AUTHOR_NAME=$(git log -1 --pretty=format:'%an')
AUTHOR_EMAIL=$(git log -1 --pretty=format:'%ae')
echo "Using author: $AUTHOR_NAME <$AUTHOR_EMAIL>"

# Get list of files changed between base branch and latest commit in PR
CHANGED_FILES=$(git diff --name-only "$BASE_BRANCH"...HEAD)

echo "Changed files:"
echo "$CHANGED_FILES"

echo "$CHANGED_FILES" | while read -r file; do
  [ -f "$file" ] || continue
  tail -c1 "$file" | read -r _ || echo >> "$file"
done

# Amend commit if there are changes
if ! git diff --quiet; then
  git add .
  git commit --amend --no-edit --author="$AUTHOR_NAME <$AUTHOR_EMAIL>"
  git push --force-with-lease
else
  echo "No changes to commit."
fi
