# obsidian-session-log

A Claude Code skill that appends a structured session log entry to today's Obsidian daily note when a session wraps up.

Invoke with `/obsidian-session-log`, ask Claude to "log this session", or make it a standing instruction in `CLAUDE.md`.

## What it does

- Resolves today's daily note in the vault's journal folder, creating the note if it does not exist
- Adds a `## Claude Sessions` heading once per note, so multiple sessions in a day append under the same heading
- Tags each entry with `#project/repo-name`, derived from the git root (falling back to the working directory name)
- Keeps entries to a fixed shape: goal, outcome, and unresolved items (the last one omitted when there is nothing open)

All of it runs through a single piped command into `scripts/append_log.sh`, which means one `allowedTools` pattern is enough to avoid confirmation prompts.

## Install

```sh
git clone git@github.com:svale/obsidian-session-log.git ~/tools/agent-skills/obsidian-session-log
ln -s ~/tools/agent-skills/obsidian-session-log ~/.claude/skills/obsidian-session-log
```

Then point the script at your own vault by editing `VAULT_PATH` and `JOURNAL_DIR` at the top of `scripts/append_log.sh`, and update the vault table in `SKILL.md` to match. The defaults assume an iCloud-synced vault with daily notes in a `0_ Journal` subfolder.

To skip permission prompts, add this to `~/.claude/settings.json`:

```json
{
  "allowedTools": [
    "Bash(echo * | bash *obsidian-session-log/scripts/append_log.sh)"
  ]
}
```
