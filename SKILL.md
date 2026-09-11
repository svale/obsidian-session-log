---
name: obsidian-session-log
description: "Appends a structured session log entry to today's Obsidian daily note at the end of every Claude Code session. Use this skill whenever a session is ending, when the user asks to log this session, write session notes, or update Obsidian. Always use this skill — never write the log freehand — to ensure consistent formatting and correct vault path handling."
---

# Obsidian Session Log Skill

Appends a concise, structured log entry to the user's Obsidian daily note at session end.

## Vault Configuration

| Setting | Value |
|---|---|
| Vault path | `~/Library/Mobile Documents/com~apple~CloudDocs/Obsidian/Work` |
| Daily notes folder | `0_ Journal/` (note the space after `0_`) — **not** the vault root |
| Daily note format | `YYYY-MM-DD.md` (e.g. `2026-03-17.md`) |
| Log heading | `## Claude Sessions` |

Daily notes live in the `0_ Journal` subfolder. The script builds its path from
`JOURNAL_DIR` and aborts if that folder is missing, rather than creating a stray note
elsewhere in the vault.

## When to Run

This skill is invoked manually — when the user says "log this session", "update Obsidian", etc.

## Log Entry Format

Each session gets one entry appended under `## Claude Sessions`. Keep it tight — 5–10 lines max.

```markdown
## Claude Sessions

### HH:MM — <one-line goal summary>
#project/repo-name
**Goal:** What the session set out to accomplish.
**Outcome:** Key decisions made, solutions found, or conclusions reached.
**Unresolved:** Any open questions or follow-up tasks (omit section if none).

---
```

- Use 24h time (`14:32`) in the local timezone
- The `#project/repo-name` tag is injected automatically by `append_log.sh` — do NOT include it in the entry text. The script derives it from `git rev-parse --show-toplevel` (falls back to `$PWD` basename).
- Goal summary in the heading should be ≤8 words
- Each field is 1–2 sentences max
- Omit `**Unresolved:**` entirely if there's nothing outstanding
- Multiple sessions in one day append sequentially under the same `## Claude Sessions` heading

## Step-by-Step Instructions

### 1. Compose the log entry

Reflect on the session and write:
- **Goal**: What the user was trying to accomplish at the start
- **Outcome**: The key decisions, code written, problems solved, or conclusions reached
- **Unresolved**: Anything left open, outstanding questions, or next steps (skip if none)

### 2. Append via the helper script

Pipe the entry to `scripts/append_log.sh` in a **single Bash command**. The script handles everything: date resolution, file creation, heading injection, repo name detection, and tag insertion. Do NOT run separate commands for date, basename, or git — the script does it all.

```bash
echo '### 14:32 — Fixed Typesense indexing bug
**Goal:** Debug why search results were returning stale data after content updates.
**Outcome:** Identified missing `indexNow` call in the Craft CMS queue job; added it and confirmed results update correctly.
**Unresolved:** Need to check if the fix applies to the staging environment too.' | bash ~/.claude/skills/obsidian-session-log/scripts/append_log.sh
```

The script automatically inserts `#project/repo-name` (without backticks — a bare Obsidian tag) on a line between the heading and the body.

### 3. Confirm

After the script runs, output its confirmation message to the user (e.g. `✅ Session logged to Obsidian: 2026-03-18.md`).

## Helper Script

See `scripts/append_log.sh` — handles vault path resolution, file creation, heading injection, repo name detection, tag insertion, and appending.

## Pre-approved Permissions

To avoid manual confirmation prompts, add this `allowedTools` entry to `~/.claude/settings.json`:

```json
{
  "allowedTools": [
    "Bash(echo * | bash *obsidian-session-log/scripts/append_log.sh)"
  ]
}
```

Only one pattern is needed — everything runs through `append_log.sh` in a single piped command. The pattern only matches commands that pipe into the specific script path.
