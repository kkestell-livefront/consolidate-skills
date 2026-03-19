# consolidate-skills

Consolidate SKILL.md-compatible assistant skill folders into `~/.skills`, then replace each assistant-specific skills directory with a symlink.

## What This Does

The `consolidate-skills.sh` script:

1. Creates `~/.skills` if it does not exist.
2. Scans each supported assistant skills directory.
3. Copies each skill folder into `~/.skills`.
4. Prompts on conflicts (`overwrite` or `skip`).
5. Prompts before deleting the assistant-specific directory.
6. Replaces that directory with a symlink to `~/.skills`.

## Supported Assistants

| Assistant | Personal Skills Path |
|-----------|----------------------|
| Claude Code | `~/.claude/skills` |
| Cline | `~/.cline/skills` |
| OpenCode | `~/.opencode/skills` |
| Gemini CLI | `~/.gemini/skills` |
| Codex (OpenAI) | `~/.codex/skills` |
| Windsurf | `~/.windsurf/skills` |
| Cursor | `~/.cursor/skills` |
| Antigravity | `~/.antigravity/skills` |

## Usage

```bash
chmod +x consolidate-skills.sh
./consolidate-skills.sh
```

The script is interactive and will prompt you to:

- choose whether to overwrite or skip conflicting skill names
- confirm deletion/replacement for each assistant directory

## Notes

- Existing paths that already point to `~/.skills` are skipped.
- Missing assistant directories are skipped.
- Symlink target is always `~/.skills`.
