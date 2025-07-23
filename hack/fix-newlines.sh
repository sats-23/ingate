#!/bin/bash
set -euo pipefail

# Fix line endings for only selected file types, and squash changes into the last commit

# Get original commit author
AUTHOR_NAME=$(git log -1 --pretty=format:'%an')
AUTHOR_EMAIL=$(git log -1 --pretty=format:'%ae')

echo "Using original author: $AUTHOR_NAME <$AUTHOR_EMAIL>"

git config user.name "$AUTHOR_NAME"
git config user.email "$AUTHOR_EMAIL"

# Find only relevant files, excluding .git
FILES=$(find . \
  \( -name "*.go" -o \
     -name "*.yaml" -o \
     -name "*.yml" -o \
     -name "*.sh" -o \
     -name "*.md" -o \
     -name "*.txt" -o \
     -name "*.py" -o \
     -name "Dockerfile" -o \
     -name "Makefile" \) \
  -not -path "./.git/*" \
  -type f)

echo "Checking files:"
echo "$FILES"

# Add newline if missing
while IFS= read -r file; do
  # Skip binary files (optional, but useful for .bin or weird encodings)
  if file "$file" | grep -q 'text'; then
    tail -c1 "$file" | read -r _ || echo >> "$file"
  fi
done <<< "$FILES"

# Check and commit if changes were made
if ! git diff --quiet; then
  git add .
  git commit --amend --no-edit --author="$AUTHOR_NAME <$AUTHOR_EMAIL>"
  git push --force-with-lease
else
  echo "No newline fixes needed."
fi
