#!/usr/bin/env bash
# append_log.sh — Append a Claude session log entry to today's Obsidian daily note
#
# Usage:
#   echo "<log entry text>" | bash append_log.sh
#   bash append_log.sh "<log entry text>"
#   bash append_log.sh  # reads from stdin if no argument
#
# The script:
#   1. Resolves today's daily note path in the vault's "0_ Journal" folder
#   2. Creates the note file if it doesn't exist
#   3. Appends a "## Claude Sessions" heading if not already present
#   4. Detects repo name and injects `#project/repo-name` tag after the heading line
#   5. Appends the provided log entry

set -euo pipefail

VAULT_PATH=~/Library/Mobile\ Documents/com~apple~CloudDocs/Obsidian/Work
JOURNAL_DIR="0_ Journal"   # daily notes live here, NOT in the vault root
DATE=$(date +%Y-%m-%d)
NOTE_PATH="${VAULT_PATH}/${JOURNAL_DIR}/${DATE}.md"

# Expand ~ manually for reliability
NOTE_PATH="${NOTE_PATH/#\~/$HOME}"

# Fail loudly if the journal folder is missing. Without this the script would
# create today's note somewhere unexpected (or die on a cryptic touch error),
# silently detaching the entry from the daily-note series.
JOURNAL_PATH=$(dirname "$NOTE_PATH")
if [ ! -d "$JOURNAL_PATH" ]; then
  echo "❌ Journal folder not found: $JOURNAL_PATH" >&2
  echo "   Check the vault path / JOURNAL_DIR, or that iCloud has synced the folder." >&2
  exit 1
fi

# Detect repo/project name (git root basename, or PWD basename as fallback)
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [ -n "$GIT_ROOT" ]; then
  REPO_NAME=$(basename "$GIT_ROOT")
else
  REPO_NAME=$(basename "$PWD")
fi
REPO_NAME=$(echo "$REPO_NAME" | tr '[:upper:]' '[:lower:]')

# Create the note if it doesn't exist
if [ ! -f "$NOTE_PATH" ]; then
  touch "$NOTE_PATH"
  echo "Created: $NOTE_PATH"
fi

# Add the Claude Sessions heading if not present
if ! grep -q "^## Claude Sessions" "$NOTE_PATH"; then
  printf "\n## Claude Sessions\n" >> "$NOTE_PATH"
fi

# Read log entry from argument or stdin
if [ $# -ge 1 ]; then
  LOG_ENTRY="$1"
else
  LOG_ENTRY=$(cat)
fi

# Inject the project tag after the first line (the ### heading)
FIRST_LINE=$(echo "$LOG_ENTRY" | head -1)
REST=$(echo "$LOG_ENTRY" | tail -n +2)
TAGGED_ENTRY="${FIRST_LINE}
#project/${REPO_NAME}
${REST}"

# Append the entry with a trailing separator (extra blank line before ---)
printf "\n%s\n\n---\n" "$TAGGED_ENTRY" >> "$NOTE_PATH"

echo "✅ Session logged to Obsidian: ${JOURNAL_DIR}/${DATE}.md"
