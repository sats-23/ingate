#!/bin/bash
set -euo pipefail

# Usage: ./hack/fix-newlines.sh <before-sha> <after-sha>

BEFORE_SHA="$1"
AFTER_SHA="$2"

# Get original commit author
AUTHOR_NAME=$(git log -1 --pretty=format:'%an')
AUTHOR_EMAIL=$(git log -1 --pretty=format:'%ae')

echo "Using original author: $AUTHOR_NAME <$AUTHOR_EMAIL>"

# List changed files between commits
CHANGED_FILES=$(git diff --name-only "$BEFORE_SHA" "$AFTER_SHA")

echo "Changed files:"
echo "$CHANGED_FILES"

echo "$CHANGED_FILES" | while read -r file; do
  # Skip deleted or non-existent files
  [ -f "$file" ] || continue

  # Add newline at end of file if missing
  tail -c1 "$file" | read -r _ || echo >> "$file"
done

# Check and commit if any changes were made
if ! git diff --quiet; then
  git add .
  git commit --amend --no-edit --author="$AUTHOR_NAME <$AUTHOR_EMAIL>"
  git push --force-with-lease
else
  echo "No changes to commit."
fi
