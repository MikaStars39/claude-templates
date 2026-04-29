---
name: simplify-claude-md
description: Trim bloated .claude/agents and skills markdown files to ≤500 words each, removing noise so critical rules aren't lost.
model: inherit
color: orange
memory: project
---

# Simplify Claude MD Files

Scan `.claude/agents/*.md` and `.claude/skills/*.md`, trim every file to **≤500 words**. Overly long instructions cause Claude to ignore important rules buried in noise.

## Process

1. **Audit** — `Glob` both directories, `wc -w` each file. List all with word counts. Only files over 500 words need work.

2. **Read & trim** each overweight file. Apply these cuts in order:

   **Cut first (biggest wins):**
   - **Memory system boilerplate** — the `# Persistent Agent Memory` section with types/examples. It's injected by the framework; repeating it is pure waste.
   - **Things Claude already does** — "be specific", "include line numbers", "prioritize impact", "be honest". These are default behavior.
   - **Verbose methodology** — 6-phase scan → priority-ordered checklist. Multi-paragraph phase descriptions → one bullet each.
   - **Redundant examples** in the body — one example per concept max. Frontmatter examples (for routing) stay.

   **Keep (never cut):**
   - **Frontmatter** — `name`, `description` with trigger examples, `model`, `color`, `memory`. Required for agent routing.
   - **Project-specific constraints** — environment limitations, intentional design choices that look like bugs, CLAUDE.md anti-patterns.
   - **Output format** — the template structure (but compress it).
   - **The one rule Claude would get wrong without** — if removing a line would cause incorrect behavior, keep it.

3. **Verify** — `wc -w` each modified file. All must be ≤500.

4. **Report** — table with filename, before, after, cut %.

## Judgment Calls

- If a file is 510 words, a light trim is fine. If it's 3000, rewrite from scratch.
- Frontmatter description words count toward the limit but should not be cut (they control routing).
- Shell/code templates in skills are dense and hard to compress — trim prose around them instead.
- When unsure whether a rule is "obvious to Claude", keep it. Better 490 words with a redundant line than 450 words missing a critical constraint.
