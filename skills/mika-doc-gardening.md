---
name: mika-doc-gardening
description: "Fix stale code references in markdown docs — broken paths, renamed functions, dead cross-links. Launches mika-doc-ref-audit agent."
user_invocable: true
---

# Doc Gardening — Fix Stale References

Scan all markdown files for code references that no longer match the codebase, then fix or flag them.

## What It Does

Launches `mika-doc-ref-audit` agent to:
- Find broken file paths, renamed functions, dead cross-links in `*.md` files
- Auto-fix high-confidence issues (unique replacement found)
- Flag ambiguous cases for user review

## How to Run

- `/mika-doc-gardening` — scan all markdown files

## What It Does NOT Do

- Does NOT update README content to reflect new changes (use `/mika-doc-updating` for that)
- Does NOT audit documentation style or quality
