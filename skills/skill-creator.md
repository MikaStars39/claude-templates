---
name: skill-creator
description: "Create, test, and iteratively improve Claude Code skills. Use when the user wants to create a skill from scratch, edit an existing skill, run test cases, benchmark performance, or optimize a skill's triggering description."
user_invocable: true
---

# Skill Creator — Draft, Test, Iterate

Create new skills or improve existing ones through a draft → test → evaluate → iterate loop. Determine where the user is in the process and jump in at the right phase.

## Phase 1 — Capture Intent

If the user already has a draft, skip to Phase 2. If the conversation contains a workflow to capture ("turn this into a skill"), extract answers from context first.

Clarify with the user:

1. What should the skill enable Claude to do?
2. When should it trigger? (user phrases, contexts)
3. What's the expected output format?
4. Should we set up test cases? Recommend yes for objectively verifiable outputs (file transforms, data extraction, code generation). Skip for subjective outputs (writing style, art).

Probe edge cases, input/output formats, and dependencies before writing anything.

## Phase 2 — Write the Skill

### Frontmatter

| Field | Required | Notes |
|-------|----------|-------|
| `name` | yes | Skill identifier |
| `description` | yes | Primary triggering mechanism. Include what it does AND when to use it. Lean slightly "pushy" to prevent under-triggering |

### Body guidelines

- Keep SKILL.md under 500 lines. Beyond that, split into `references/` with clear pointers.
- Use imperative form. Explain **why** things matter rather than piling on rigid rules.
- Include 1-2 examples when the output format isn't obvious.
- For multi-domain skills, organize variants in `references/` — Claude reads only the relevant file.

### Directory layout

```
skill-name/
├── SKILL.md          # required
├── scripts/          # optional — deterministic/repetitive tasks
├── references/       # optional — docs loaded as needed
└── assets/           # optional — templates, icons, fonts
```

## Phase 3 — Test

Write 2-3 realistic test prompts. Share with the user for confirmation before running. Save to `evals/evals.json`:

```json
{
  "skill_name": "example-skill",
  "evals": [
    {"id": 1, "prompt": "User's task prompt", "expected_output": "Description of expected result", "files": []}
  ]
}
```

For each test case, spawn **two parallel subagents** in the same turn:

- **With-skill**: execute the task with the skill loaded → save to `<workspace>/iteration-<N>/eval-<ID>/with_skill/outputs/`
- **Baseline**: same prompt, no skill → save to `without_skill/outputs/`

If improving an existing skill, baseline = snapshot of the old version.

Create `eval_metadata.json` per test case with a descriptive `eval_name`.

## Phase 4 — Evaluate

### While runs are in progress

Draft quantitative assertions — objectively verifiable, with descriptive names. Update `eval_metadata.json` and `evals/evals.json`. See `references/schemas.md` for the assertion schema.

### When runs complete

Capture `total_tokens` and `duration_ms` from each task notification → save to `timing.json` per run directory. This data is only available at notification time.

### Grade, aggregate, launch viewer

1. **Grade** — evaluate assertions against outputs. Save to `grading.json` using fields `text`, `passed`, `evidence`. Prefer scripted checks over manual inspection.
2. **Aggregate** — `python -m scripts.aggregate_benchmark <workspace>/iteration-N --skill-name <name>` → produces `benchmark.json` and `benchmark.md`.
3. **Analyze** — check for non-discriminating assertions, high-variance evals, time/token tradeoffs. See `agents/analyzer.md`.
4. **Launch viewer**:
   ```bash
   nohup python <skill-creator-path>/eval-viewer/generate_review.py \
     <workspace>/iteration-N \
     --skill-name "my-skill" \
     --benchmark <workspace>/iteration-N/benchmark.json \
     > /dev/null 2>&1 &
   ```
   For iteration 2+, add `--previous-workspace <workspace>/iteration-<N-1>`.
   In headless environments, use `--static <output_path>` for standalone HTML.

5. Tell the user to review in browser. The "Outputs" tab shows test cases with feedback boxes; the "Benchmark" tab shows quantitative comparison.

## Phase 5 — Iterate

Read `feedback.json` after the user finishes reviewing. Empty feedback = looks good. Focus on test cases with specific complaints.

### Improvement principles

- **Generalize** — don't overfit to the test examples. Fiddly, example-specific fixes produce useless skills.
- **Keep it lean** — read the run transcripts. If the skill wastes time on unproductive steps, cut those instructions.
- **Explain why** — reasoning beats rigid rules. If you're writing ALWAYS/NEVER in caps, reframe as an explanation of why it matters.
- **Bundle repeated work** — if all runs independently wrote similar helper scripts, put that script in `scripts/`.

### Loop

1. Apply improvements to the skill
2. Rerun all test cases into `iteration-<N+1>/`
3. Launch viewer with `--previous-workspace`
4. Wait for user feedback
5. Repeat until: user is happy, feedback is all empty, or no meaningful progress

## Phase 6 — Optimize Description (optional)

After the skill is finalized, offer to optimize the description for better triggering.

1. **Generate 20 trigger eval queries** — 8-10 should-trigger, 8-10 should-not-trigger. Queries must be realistic with concrete detail (file paths, context, backstory). Negative cases should be near-misses, not obviously irrelevant.
2. **Review with user** — render via `assets/eval_review.html` template, user edits and exports `eval_set.json`.
3. **Run optimization**:
   ```bash
   python -m scripts.run_loop \
     --eval-set <path-to-trigger-eval.json> \
     --skill-path <path-to-skill> \
     --model <current-model-id> \
     --max-iterations 5 --verbose
   ```
4. **Apply** — update SKILL.md frontmatter with `best_description` from output. Show the user before/after and scores.

## Constraints

- Generate the eval viewer **before** making your own corrections — get human eyes on outputs first.
- Never create skills containing malware, exploit code, or content for unauthorized access.
- Do not write test cases until Phase 1 is complete.
- Process each timing notification as it arrives — the data is not persisted elsewhere.
- For Claude.ai or Cowork-specific adjustments, see `references/platform-notes.md`.

## Reference Files

- `agents/grader.md` — assertion evaluation
- `agents/comparator.md` — blind A/B comparison
- `agents/analyzer.md` — benchmark analysis
- `references/schemas.md` — JSON schemas for evals, grading, benchmark
