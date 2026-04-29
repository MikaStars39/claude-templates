# claude-skills

Shared Claude Code skills, agents, and commands — reusable across projects.

## Install

```bash
git clone <this-repo> ~/claude-skills
cd ~/claude-skills
chmod +x install.sh uninstall.sh
./install.sh
```

This symlinks all `.md` files into `~/.claude/{skills,agents,commands}/`, making them available in every project.

## How it works

Claude Code loads skills/agents/commands from two levels:

| Level | Path | Scope |
|-------|------|-------|
| **User** | `~/.claude/skills/` etc. | All projects |
| **Project** | `.claude/skills/` etc. | Current project only |

Both levels merge at runtime. This repo provides the **user-level** skills. Projects can add their own project-specific skills in `.claude/` alongside these.

## Adding project-specific skills

Keep project-specific skills in your project's `.claude/` directory. They will merge with these user-level skills automatically.

Example: a project `my-app` might have:
```
my-app/.claude/
├── skills/
│   └── run-tests.md       # project-specific
├── commands/
│   └── run-tests.md
└── settings.local.json
```

These coexist with the shared skills installed by this repo.

## Uninstall

```bash
cd ~/claude-skills
./uninstall.sh
```

Only removes symlinks pointing to this repo — project-level and other user-level files are untouched.

## Update

```bash
cd ~/claude-skills
git pull
```

Since files are symlinked (not copied), changes take effect immediately.
