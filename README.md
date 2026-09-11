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

## Configure

The vault path lives in the environment, not in the script. Add it to `~/.claude/settings.json` along with the `allowedTools` pattern that skips permission prompts:

```json
{
  "env": {
    "OBSIDIAN_VAULT_PATH": "/absolute/path/to/your/Vault",
    "OBSIDIAN_JOURNAL_DIR": "Journal"
  },
  "allowedTools": [
    "Bash(echo * | bash *obsidian-session-log/scripts/append_log.sh)"
  ]
}
```

| Variable | Required | Default | Meaning |
|---|---|---|---|
| `OBSIDIAN_VAULT_PATH` | yes | — | Absolute path to the vault |
| `OBSIDIAN_JOURNAL_DIR` | no | `Journal` | Daily-notes folder, relative to the vault root |
| `OBSIDIAN_SESSION_LOG_CONFIG` | no | `~/.config/obsidian-session-log/config` | Optional config file, sourced when present |

Setting them in your shell profile works too, as does writing the two assignments into the config file if you also want to run the script outside Claude Code.
