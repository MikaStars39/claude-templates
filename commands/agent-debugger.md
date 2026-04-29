# Agent Debugger — Adversarial Bug Audit

Two-phase process: discover bugs with parallel agents, then adversarially verify each finding yourself.

## Phase 1: Discovery

**Determine scope** — ask via `AskUserQuestion`: full repo, specific directory, or recent changes? If user provides scope argument (e.g., `/agent-debugger src/`), use it directly.

**Launch 3-4 parallel Explore agents**, each covering a different area of the codebase. Split by module boundaries or directory structure as appropriate for the project.

Collect all findings into a numbered list with file:line, description, severity.

## Phase 2: Verification (mandatory — never skip)

**You must do this yourself** — do not delegate. For each claim:

1. Read the actual code at the cited line (don't trust quotes)
2. Trace callers — if "X can be None", check if callers guarantee it
3. Check API contracts — standardized formats may guarantee fields
4. Verify concurrency model — asyncio is single-threaded
5. Grep the entire repo before declaring anything "unused"
6. Distinguish bugs from style preferences

Classify: **TRUE BUG** / **CODE SMELL** / **FALSE ALARM**

## Output

```
## Audit Results
**Scope**: [what was scanned]
**Phase 1**: N claims → **After verification**: X true bugs, Y code smells, Z false alarms

### Confirmed Bugs
| # | File | Line | Issue | Severity |
|---|------|------|-------|----------|

### Code Smells
| # | File | Line | Issue |
|---|------|------|-------|

### False Alarms Eliminated
| # | Claim | Why Not a Bug |
|---|-------|--------------|
```

Then ask user if they want to fix confirmed bugs.
