#!/usr/bin/env bash
# append_log.sh — Append a Claude session log entry to today's Obsidian daily note
#
# Usage:
#   echo "<log entry text>" | bash append_log.sh
#   bash append_log.sh "<log entry text>"
#   bash append_log.sh  # reads from stdin if no argument
#
# The script:
#   1. Resolves today's daily note path from $OBSIDIAN_VAULT_PATH / $OBSIDIAN_JOURNAL_DIR
#   2. Creates the note file if it doesn't exist
#   3. Appends a "## Claude Sessions" heading if not already present
#   4. Detects repo name and injects `#project/repo-name` tag after the heading line
#   5. Appends the provided log entry

set -euo pipefail

# Configuration comes from the environment, so no personal vault path lives in
# this file. Set these in ~/.claude/settings.json ("env" block), in your shell
# profile, or in the optional config file sourced below.
CONFIG_FILE="${OBSIDIAN_SESSION_LOG_CONFIG:-$HOME/.config/obsidian-session-log/config}"
if [ -f "$CONFIG_FILE" ]; then
  # shellcheck disable=SC1090
  . "$CONFIG_FILE"
fi

VAULT_PATH="${OBSIDIAN_VAULT_PATH:-}"
JOURNAL_DIR="${OBSIDIAN_JOURNAL_DIR:-Journal}"   # daily notes live here, relative to the vault root

if [ -z "$VAULT_PATH" ]; then
  echo "❌ OBSIDIAN_VAULT_PATH is not set." >&2
  echo "   Point it at your Obsidian vault, e.g. in ~/.claude/settings.json:" >&2
  echo '     "env": { "OBSIDIAN_VAULT_PATH": "/path/to/Vault", "OBSIDIAN_JOURNAL_DIR": "Journal" }' >&2
  echo "   or write those two lines into $CONFIG_FILE as shell assignments." >&2
  exit 1
fi

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
  echo "   Check OBSIDIAN_VAULT_PATH / OBSIDIAN_JOURNAL_DIR, or that the vault has synced." >&2
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
