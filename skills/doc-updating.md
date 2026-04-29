---
name: doc-updating
description: "Update or create README.md in directories affected by recent code changes. Documents what changed and why — the stuff code alone doesn't tell you."
user_invocable: true
---

# Doc Updating — Update READMEs After Code Changes

After code changes, update the README.md in affected directories to document what changed and why.

## When to Use

- After fixing a bug, adding a feature, or refactoring in a directory
- When a directory has no README.md yet
- When existing README.md is missing info about recent changes

## How to Run

- `/doc-updating` — auto-detect changed directories from git diff
- `/doc-updating recipes/foo` — update README for a specific directory

## What Goes in the README

Only things you **can't derive from reading the code**:

- Design intent — why this approach, not the simpler one
- Upstream/downstream coupling — what breaks if you change this
- Known pitfalls — gotchas that bit someone before
- Recent notable changes — one-liner per change, not a changelog

**Never** restate function signatures or rewrite what the code already says.

## What It Does NOT Do

- Does NOT fix broken references in existing docs (use `/doc-gardening` for that)
