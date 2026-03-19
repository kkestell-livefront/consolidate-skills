# Consolidate Skills

Consolidate SKILL.md-compatible assistant skill directories into one shared location (default: `~/.skills`), then replace each with a symlink.

## What This Does

The `consolidate-skills.sh` script:

1. Uses a target skills directory (default: `~/.skills`).
2. Creates that target directory if it does not exist.
3. Prompts for each supported assistant before processing it (so you can skip any assistant).
4. Scans each selected assistant skills directory.
5. Copies each skill folder into the selected target directory.
6. Prompts on conflicts (`overwrite` or `skip`).
7. Prompts before deleting the assistant-specific directory.
8. Replaces that directory with a symlink to the selected target directory.

## Supported Assistants

| Assistant      | Personal Skills Path    |
| -------------- | ----------------------- |
| Claude Code    | `~/.claude/skills`      |
| Cline          | `~/.cline/skills`       |
| OpenCode       | `~/.opencode/skills`    |
| Gemini CLI     | `~/.gemini/skills`      |
| Codex (OpenAI) | `~/.codex/skills`       |
| Windsurf       | `~/.windsurf/skills`    |
| Cursor         | `~/.cursor/skills`      |
| Antigravity    | `~/.antigravity/skills` |

## Usage

```bash
chmod +x consolidate-skills.sh
./consolidate-skills.sh
```

Use a custom consolidated path:

```bash
./consolidate-skills.sh --target ~/.my-skills
```

You can also use:

```bash
./consolidate-skills.sh --skills-dir ~/.my-skills
SKILLS_DIR=~/.my-skills ./consolidate-skills.sh
```

## Notes

- Existing paths that already point to the selected target directory are skipped.
- Missing assistant directories are skipped.
- Symlink target is the selected target directory.
- Each assistant is prompted with `Process <Agent>? [Y/n]` before any work for that agent.
