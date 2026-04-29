# Doc Gardening — Documentation Maintenance

Orchestrate two documentation health agents. Default: run both. Pass `refs` or `readme` to run only one.

## Mode Selection

Parse the user's argument:
- `/doc-gardening` or `/doc-gardening both` → run both agents
- `/doc-gardening refs` → run only doc-ref-audit
- `/doc-gardening readme` → run only doc-readme-sync

## Phase 1 — Launch Agents

Spawn selected agent(s) **in parallel** via the Agent tool:

- `subagent_type: "doc-ref-audit"` — prompt: "Scan all markdown files in this repo for stale code references (file paths, function names, CLI args, cross-links). Verify each against the codebase. Auto-fix high-confidence issues, flag the rest."
- `subagent_type: "doc-readme-sync"` — prompt: "Scan all directories for README coverage gaps and index table drift. Check CLAUDE.md project map and documentation index for accuracy. Auto-fix high-confidence issues, flag the rest."

If running only one mode, launch just that agent.

## Phase 2 — Unified Report

Collect results from both agents. Present a combined report:

```
## Doc Gardening Report

### Reference Audit (doc-ref-audit)
- Files scanned: N | Anchors checked: N
- Issues: N auto-fixed, N flagged
[issues list]

### README Sync (doc-readme-sync)
- Directories scanned: N | READMEs checked: N
- Coverage gaps: N | Table drift: N | Map drift: N
[issues list]
```

If only one mode was run, show only that section.

## Phase 3 — User Action

Ask the user: "Want me to apply the flagged fixes? You can also pick specific items."

## Constraints

- Never auto-create new README files — coverage gaps are flagged for user decision.
